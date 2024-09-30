extends RigidBody2D

var screensize = Vector2.ZERO
var size
var radius
var scale_factor = 0.2  # size를 곱해 Sprite2D 스케일, 콜리전 반지름 등 설정
signal exploded

func start(_position, _velocity, _size):
	position = _position
	size = _size
	mass = 1.5 * size
	$Sprite2D.scale = Vector2.ONE * scale_factor * size
	radius = int($Sprite2D.texture.get_size().x / 2 * $Sprite2D.scale.x)
	var shape = CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape  # 바위 size에 따라 콜리전 크기 계산
	linear_velocity = _velocity
	angular_velocity = randf_range(-PI, PI)  # 시계방향 혹은 반시계방향으로 설정
	$Explosion.scale = Vector2.ONE * 0.75 * size  # 폭발 크기를 바위 크기에 맞춰 조정


func _integrate_forces(physics_state):
	var xform = physics_state.transform
	# 최소최대값 설정 시 radius 를 포함하여 화면에서 완전히 빠져나간 후 반대편에서 나오게 됨
	xform.origin.x = wrapf(xform.origin.x, 0 - radius, screensize.x + radius)
	xform.origin.y = wrapf(xform.origin.y, 0 - radius, screensize.y + radius)
	physics_state.transform = xform

func explode():
	$CollisionShape2D.set_deferred("disabled", true)  # CollisionShape2D 노드의 충돌 감지를 비활성화
	$Sprite2D.hide()
	$Explosion/AnimationPlayer.play("explosion")
	$Explosion.show()  # Explosion 노드를 화면에 표시
	exploded.emit(size, radius, position, linear_velocity)  # exploded라는 시그널을 방출
	# 폭발된 위치에서 멈출 수 있도록 velocity 값 초기화
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	await $Explosion/AnimationPlayer.animation_finished  # 애니메이션 종료까지 기다린 후 다음 실행
	queue_free()  # 노드를 씬에서 제거	
