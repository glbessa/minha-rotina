extends Resource

class_name Analytics

@export var analytics = []

func _init():
	pass

func add_event(event_type: String, user_id: String, event_data: Array):
	var event = {
		"event_type": event_type,
		"user_id": user_id,
		"event_data": event_data,
		"created_at": Time.get_datetime_string_from_system(true),
	}
	analytics.append(event)

func clear_events():
	analytics.clear()

func to_json(filepath: String) -> void:
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	file.store_string(JSON.stringify((analytics)))
	file.close()
	
func to_csv():
	pass
