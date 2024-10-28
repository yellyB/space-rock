extends Node

@export var rock_scene : PackedScene

var screensize = Vector2.ZERO
var level = 0
var score = 0
var playing = false

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
	
func new_game():
	get_tree().call_group("rocks", "queue_free")  # 이전 게임의 바위가 남아있을 수 있어 제거
	level = 0
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("Get Ready!")
	$Player.reset()
	await $HUD/Timer.timeout
	playing = true
	
func new_level():
	level += 1
	$HUD.show_message("Wave %s" % level)
	for i in level:
		spawn_rock(3)
	
func game_over():
	playing = false
	$HUD.game_over()
	
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
	score += 10 * size
	$HUD.update_score(score)
	
func _ready():
	screensize = get_viewport().get_visible_rect().size
		
func _process(delta):
	if not playing: return
	if get_tree().get_nodes_in_group("rocks").size() == 0:
		new_level()
