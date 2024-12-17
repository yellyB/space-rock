extends Area2D

@export var speed = 1000

var velocity = Vector2.ZERO

# 새 총알 리스폰 시 호출될 함수
func start(_transform):
	transform = _transform
	velocity = transform.x * speed
	
func _process(delta):
	position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

# 총알 body entered 시그널 연결
func _on_body_entered(body):
	if body.is_in_group("rocks"):
		body.explode()
		queue_free()

# enemy를 사격하는 경우, enemy는 Area2D라 위의 body_entered 트리거 하지 않는다. 때문에 area_entered 따로 만들어줌
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.take_damage(1)
