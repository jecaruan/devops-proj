terraform {

  backend "s3" {
      bucket = "devops-s3-terra"
      key = "tf-infra/terraform.tfstate"
      region = "ap-southeast-1"
      dynamodb_table = "terraform_locks_terra"
      encrypt = true
  }




  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.84.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-southeast-1"
}


resource "aws_security_group" "instances" {
  name = "instance-security-group-new"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.instances.id

  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "apache2_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.instances.id

  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.instances.id

  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type = "egress"
  security_group_id = aws_security_group.instances.id

  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}



resource "aws_db_instance" "db-sample" {
  identifier = "db-sample"
  allocated_storage = 10
  storage_type = "gp2"
  engine = "mysql"
  instance_class = "db.t3.micro"
  username = var.db_user
  password = var.db_pass
  publicly_accessible    = true
  skip_final_snapshot    = true
  tags = {
    Name = "mydb"
  }
}

# web app
resource "aws_instance" "ubuntu" { #EC2
    ami = "ami-0672fd5b9210aa093"
    instance_type = "t2.micro"
    key_name = "jeff-key-pair"

    provisioner "file" {
      source      = "laravel.conf"
      destination = "/home/ubuntu/laravel.conf"
   
      connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = "${file("jeff-key-pair.pem")}"
        host        = "${self.public_ip}"
      }   
    }
  

    user_data = <<-EOF
        #!/bin/bash
        apt update

        apt install -y \
          apache2 \
          php8.3 \
          libapache2-mod-php8.3 \
          php8.3-dom \
          php8.3-sqlite3 \
          php-zip \
          php-curl \
          git

        apt clean

        mv /home/ubuntu/laravel.conf /etc/apache2/sites-available/laravel.conf
        sudo a2ensite laravel
        sudo a2dissite 000-default

        sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        sudo php composer-setup.php
        sudo php -r "unlink('composer-setup.php');"
        sudo mv composer.phar /usr/local/bin/composer

        cd /var
        mkdir www
        cd www
        mkdir laravel

        cd laravel
        git clone https://github.com/jecaruan/devops-proj.git

        cd devops-proj

        sudo chown -R $USER:$USER /var/www/laravel
        sudo chmod -R guo+w /var/www/laravel
        sudo composer install
        cp .env.example .env

        echo "Writing new content to .env file..."
        echo "DB_HOST=${aws_db_instance.db-sample.address}"  >> /var/www/laravel/devops-proj/.env
        echo "DB_PORT=${aws_db_instance.db-sample.port}"  >> /var/www/laravel/devops-proj/.env
        echo "DB_DATABASE=db-users"  >> /var/www/laravel/devops-proj/.env
        echo "DB_USERNAME=${var.db_user}"  >> /var/www/laravel/devops-proj/.env
        echo "DB_PASSWORD=${aws_db_instance.db-sample.password}"  >> /var/www/laravel/devops-proj/.env

        php artisan key:generate
        php artisan migrate 
        php artisan db:seed
        
        sudo chown -R $USER:$USER /var/www/laravel
        sudo chmod -R guo+w /var/www/laravel
        php artisan optimize
        sudo systemctl restart apache2

        EOF
        
    tags = {
        Name = "DevOps - Presentation"
    }

    vpc_security_group_ids = [aws_security_group.instances.id]


}