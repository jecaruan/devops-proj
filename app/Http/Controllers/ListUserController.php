<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use DB;
class ListUserController extends Controller
{
     public function index(Request $request)
    {
       

        $listUsers= DB::connection('mysql')->select('SELECT `id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at` FROM `users`;');
       
        return view('users.index', compact('listUsers'));    //
    }
}
