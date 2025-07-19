<?php

use App\Http\Controllers\TaskController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect()->route('tasks.index');
});

Route::resource('tasks', TaskController::class);

Route::put('/tasks/{task}/toggle-complete', [TaskController::class, 'toggleComplete'])
    ->name('tasks.toggle-complete');
