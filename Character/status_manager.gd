extends Object
class_name StatusManager

var max_health := 100.0
var statuses : Dictionary = {"health": 100.0, "consumed_stamina" : 0.0, "damage" : 0.0}

func get_status_value(status_name : String) -> float:
	if statuses.keys().has(status_name):
		return statuses[status_name]
	return 0.0

func add_status(status_name : String, value : float) -> void:
	if statuses.keys().has(status_name):
		statuses[status_name] = max(0, statuses[status_name] + value)
		print("changed " + str(statuses[status_name]))
	else:
		statuses[status_name] = value
	var non_health_total = 0.0
	for s in statuses.keys():
		if s != "health":
			non_health_total += statuses[s]
	statuses["health"] = max(0, max_health - non_health_total)
	if statuses["health"] == 0:
		print("dead")


func get_status_ratios() -> Array:
	var res = []
	for sv in statuses.values():
		res.append(sv/100.0)
	return res
	
