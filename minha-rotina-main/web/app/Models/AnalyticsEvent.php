<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class AnalyticsEvent extends Model
{
    protected $connection = 'mongodb';

    protected $table = 'analytics_events';

    protected $fillable = [
        'event_type',
        'user_id',
        'metadata',
        'created_at',
    ];
}
