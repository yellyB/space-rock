extends RigidBody2D

@export var engine_power = 500
@export var spin_power = 8000

var thrust = Vector2.ZERO
var rotation_dir = 0
var screensize = Vector2.ZERO

enum {INIT, ALIVE, INVULERABLE, DEAD}
var state = INIT

func _ready():
	change_state(ALIVE)
	screensize = get_viewport_rect().size  # 화면 크기
	
func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled", true)
		ALIVE:
			$CollisionShape2D.set_deferred("disabled", false)
		INVULERABLE:
			$CollisionShape2D.set_deferred("disabled", true)
		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)
	state = new_state

func _process(delta):
	get_input()
 
# 키 입력 받아 우주선의 추력 켜거나 끄는 함수
func get_input():
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("thrust"):
		# transform 은 객체의 현재 위치, 회전, 크기 정보 
		thrust = transform.x * engine_power
	
	# -1: 왼쪽 / 1: 오른쪽 / 0: 아무입력 없음	
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	
	
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
