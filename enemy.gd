extends Area2D

@export var bullet_scene : PackedScene
@export var speed = 150
@export var rotation_speed = 120
@export var health = 3
@export var bullet_spread = 0.2

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
	if follow.progress_ratio >= 1:  # progress_ratio가 1이면 경로의 끝에 도달한 것. (0~1)
		queue_free()

func _on_gun_cooldown_timeout():
	shoot_pulse(3, 0.15)
	
func shoot_pulse(n, delay):
	for i in n:
		shoot()
		await get_tree().create_timer(delay).timeout

func shoot():
	$ShootSound.play()
	var dir = global_position.direction_to(target.global_position)
	dir = dir.rotated(randf_range(-bullet_spread, bullet_spread))
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.start(global_position, dir)
	
func take_damage(amount):
	health -= amount
	$AnimationPlayer.play("flash")
	if health <= 0:
		explode()
		
func explode():
	speed = 0
	$Explosion.show()
	$GunCooldown.stop()
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.hide()
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	await $Explosion/AnimationPlayer.animation_finished
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("rocks"):
		return
	explode()
	body.shield -= 50
