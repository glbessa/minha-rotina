<?php

namespace App\Http\Controllers;

use App\Models\AnalyticsEvent;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AnalyticsController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $event_type = $request->query('event_type');
        $user_id = $request->query('user_id');
        $min_date = $request->query('min_date', Carbon::now()->subDays(7));
        $max_date = $request->query('max_date');

        $events = AnalyticsEvent::when($event_type, fn($query) => $query->where('event_type', $event_type))
            ->when($user_id, fn($query) => $query->where('user_id', $user_id))
            ->when($min_date, fn($query) => $query->where('created_at', '>=', $min_date))
            ->when($max_date, fn($query) => $query->where('created_at', '<=', $max_date))
            ->get();

        return response()->json($events);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'event_type' => 'required|string',
            'metadata' => 'required|array',
            'user_id' => 'nullable|integer',
        ]);

        $event = AnalyticsEvent::create($validated);

        return response()->json($event);
    }
}
