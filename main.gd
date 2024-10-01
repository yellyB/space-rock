extends Node

@export var rock_scene : PackedScene

var screensize = Vector2.ZERO

func spawn_rock(size, pos=null, vel=null):  # 깨진 바위는 pos, vel 값을 전달한다
	if pos == null:
		$RockPath/RockSpawn.progress = randi()
		pos = $RockPath/RockSpawn.position
	if vel == null:
		vel = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)
	var rock = rock_scene.instantiate()
	rock.screensize = screensize
	rock.start(pos, vel, size)
	call_deferred("add_child", rock)
	
	# 바위 파편
	rock.exploded.connect(self._on_rock_exploded)
	
func _on_rock_exploded(size, radius, pos, vel):
	if size <= 1:
		return
	for offset in [-1, 1]:  # 2개 바위 생성하고, 서로 반대 방향 향할수 있도록 하기 위함
		var dir = $Player.position.direction_to(pos).orthogonal() * offset
		# ㄴ direction_to: 플레이어와 pos 간의 벡터를 구함. 
		# ㄴ orthogonal: 벡터의 수직 벡터를 반환
		var newPos = pos + dir * radius
		var newVel = dir * vel.length() * 1.1
		spawn_rock(size - 1, newPos, newVel)
	
	
func _ready():
	screensize = get_viewport().get_visible_rect().size
	for i in 3:
		spawn_rock(3)
