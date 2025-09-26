class_name DirectionUtils

static func vector2_to_direction(v: Vector2) -> String:
	if v == Vector2.ZERO:
		return "none"

	if abs(v.x) > abs(v.y):
		return "right" if v.x > 0 else "left"
	else:
		return "down" if v.y > 0 else "up"
