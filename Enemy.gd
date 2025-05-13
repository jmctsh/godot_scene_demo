extends CharacterBody2D

@export var speed = 200.0
@export var jump_velocity = -400.0
@export var gravity = 980.0
@export var detection_radius = 300.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var player = get_tree().get_first_node_in_group("player")

var is_attacking = false
var is_hurt = false
var is_dead = false
var target_position = null

func _physics_process(delta):
	if is_dead:
		return
		
	# 添加重力
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# AI行为
	if player and not is_attacking and not is_hurt:
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player < detection_radius:
			# 追踪玩家
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * speed
			
			# 如果足够近就攻击
			if distance_to_player < 50.0:
				attack()
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	# 更新动画
	update_animation()
	
	# 移动角色
	move_and_slide()

func update_animation():
	if is_dead:
		animated_sprite.play("death")
		return
	
	if is_hurt:
		animated_sprite.play("hurt")
		return
	
	if is_attacking:
		animated_sprite.play("attack")
		return
	
	if not is_on_floor():
		animated_sprite.play("jump")
	elif velocity.x != 0:
		animated_sprite.play("run")
		animated_sprite.flip_h = velocity.x < 0
	else:
		animated_sprite.play("idle")

func attack():
	is_attacking = true
	# 在这里添加攻击判定逻辑
	await get_tree().create_timer(0.5).timeout
	is_attacking = false

func take_damage():
	if not is_hurt and not is_dead:
		is_hurt = true
		# 在这里添加受伤逻辑
		await get_tree().create_timer(0.5).timeout
		is_hurt = false

func die():
	is_dead = true
	# 在这里添加死亡逻辑 
