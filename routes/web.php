<?php

use Illuminate\Support\Facades\Route;
use  App\Http\Controllers\ListUserController;

Route::get('/', function () {
    return view('welcome');
});
Route::get('/users/getAll', [ListUserController::class, 'index']);