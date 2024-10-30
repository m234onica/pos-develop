<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/menu', ['as' => 'menu.index', 'uses' => '\App\Http\Controllers\MenuController@index']);
Route::post('/menu', ['as' => 'menu.store', 'uses' => '\App\Http\Controllers\MenuController@store']);
Route::get('/menu/{id}', ['as' => 'menu.show', 'uses' => '\App\Http\Controllers\MenuController@show']);
Route::post('/menu/{id}', ['as' => 'menu.show', 'uses' => '\App\Http\Controllers\MenuController@store']);

Route::get('/order', ['as' => 'order.index', 'uses' => '\App\Http\Controllers\OrderController@index']);
Route::get('/order/create', ['as' => 'order.index', 'uses' => '\App\Http\Controllers\OrderController@create']);
Route::post('/order', ['as' => 'order.show', 'uses' => '\App\Http\Controllers\OrderController@store']);
Route::post('/order/{id}', ['as' => 'order.show', 'uses' => '\App\Http\Controllers\OrderController@store']);
