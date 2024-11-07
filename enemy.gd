extends Area2D

@export var bullet_scene : PackedScene
@export var speed = 150
@export var rotation_speed = 120
@export var health = 3

var follow = PathFollow2D.new()  # PathFollow2D는 부모 Path2D를 따라 자동으로 이동함
var target = null

func _ready():
	$Sprite2D.frame = randi() % 3  # 적의 spriteSheet 개수가 3이라 0,1,2중 랜덤 값
	# $EnemyPaths 의 자식 노드들 중 하나 무작위로 선택하기
	var path = $EnemyPaths.get_children()[randi() % $EnemyPaths.get_child_count()]
	path.add_child(follow)  # 위의 path에 자식으로 추가
	follow.loop = false  # 경로 끝에 도달하면 stop

func _physics_process(delta):
	rotation += deg_to_rad(rotation_speed) * delta
	follow.progress += speed * delta  # progress는 경로에서 현재 위치. 경로 따라 이동시키기
	position = follow.global_position
	if follow.progress_ratio >= 1:  # progress_ratio가 1이면 경로의 끝에 도달한 것.
		queue_free()

func _on_gun_cooldown_timeout():
	pass # Replace with function body.
