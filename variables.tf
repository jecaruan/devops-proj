# variable "instance_name" {
#   description = "Name of EC2 instance"
#   type = string
# }

variable "ami" {
  description = "AMI to use for EC2 instance"
  type = string
  default = "ami-0198a868663199764"
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t2.micro"
}

variable "web_port" {
  description = "The web app port"
  type = number
  default = 8080
}

variable "db_user" {
  description = "username for database"
  type = string
  default = "user1"
}

variable "db_pass" {
  description = "password for database"
  type = string
  sensitive = true
}
