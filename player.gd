extends RigidBody2D

@export var engine_power = 500
@export var spin_power = 8000
@export var bullet_scene : PackedScene
@export var fire_rate = 0.25

signal lives_changed
signal dead

var thrust = Vector2.ZERO
var rotation_dir = 0
var screensize = Vector2.ZERO
var can_shoot = true

enum {INIT, ALIVE, INVULNERABLE, DEAD}
var state = INIT

var reset_pos = false
var lives = 0: set = set_lives

	
func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled", true)
			$Sprite2D.modulate.a = 0.5
		ALIVE:
			$CollisionShape2D.set_deferred("disabled", false)
			$Sprite2D.modulate.a = 1.0
		INVULNERABLE:
			$CollisionShape2D.set_deferred("disabled", true)
			$Sprite2D.modulate.a = 0.5
			$InvulnerabilityTimer.start()
		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)
			$Sprite2D.hide()
			linear_velocity = Vector2.ZERO
			dead.emit()
	state = new_state
 
# 키 입력 받아 우주선의 추력 켜거나 끄는 함수
func get_input():
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("thrust"):
		# transform 은 객체의 현재 위치, 회전, 크기 정보 
		thrust = transform.x * engine_power
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
	# -1: 왼쪽 / 1: 오른쪽 / 0: 아무입력 없음	
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")


func shoot():
	if state == INVULNERABLE: return
	
	can_shoot = false
	$GunCooldown.start()
	
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.start($Muzzle.global_transform)  # 전역 좌표 부여.

func set_lives(value):
	lives = value
	lives_changed.emit(lives)
	if lives <= 0:
		change_state(DEAD)
	else:
		change_state(INVULNERABLE)

func reset():
	reset_pos = true
	$Sprite2D.show()
	lives = 3
	change_state(ALIVE)

func explode():
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	await $Explosion/AnimationPlayer.animation_finished
	$Explosion.hide()

func _ready():
	change_state(ALIVE)
	screensize = get_viewport_rect().size  # 화면 크기
	$GunCooldown.wait_time = fire_rate
	
func _process(delta):
	get_input()

func _physics_process(delta):
	constant_force = thrust
	constant_torque = rotation_dir * spin_power
	
	## Area2D 였다면 아래 코드로 screen wrap을 사용할 수 있지만, 물리엔진은 불가능
	#if position.x > screensize.x:
		#position.x = 0
	#if position.x < 0:
		#position.x = screensize.x
	#if position.y > screensize.y:
		#position.y = 0
	#if position.y < 0:
		#position.y = screensize.y

func _integrate_forces(physics_state):
	var xform = physics_state.transform
	# wrapf(value, min, max)
	xform.origin.x = wrapf(xform.origin.x, 0, screensize.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screensize.y)
	physics_state.transform = xform
	if reset_pos:
		physics_state.transform.origin = screensize / 2
		reset_pos = false
	

func _on_gun_colldown_timeout():
	can_shoot = true


func _on_invulnerability_timer_timeout():
	change_state(ALIVE)


func _on_body_entered(body):
	if body.is_in_group("rocks"):
		body.explode()
		lives -= 1
		explode()
