<?php

use App\Http\Controllers\AnalyticsController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::prefix('/v1')->group(function () {
    Route::get('/analytics', [AnalyticsController::class, 'index'])->name('v1.analytics.index');
    Route::post('/analytics', [AnalyticsController::class, 'store'])->name('v1.analytics.store');
});
