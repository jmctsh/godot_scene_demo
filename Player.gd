extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -400.0
@export var gravity = 980.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var camera = $Camera2D

var is_attacking = false
var is_hurt = false
var is_dead = false
var is_jumping = false

func _ready():
	animated_sprite.play("idle")

func _physics_process(delta):
	# 获取输入
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# 设置水平速度
	if direction:
		velocity.x = direction * speed
		# 根据移动方向翻转精灵
		animated_sprite.flip_h = direction < 0
		# 播放行走动画
		if animated_sprite.animation != "walk" and not is_attacking and is_on_floor():
			animated_sprite.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		# 如果没有移动，播放待机动画
		if animated_sprite.animation != "idle" and not is_attacking and is_on_floor():
			animated_sprite.play("idle")
	
	# 处理跳跃
	if (Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("jump")) and is_on_floor():
		velocity.y = jump_velocity
		is_jumping = true
		animated_sprite.play("jump_start")
	
	# 处理跳跃动画状态
	if not is_on_floor():
		if is_jumping and animated_sprite.animation == "jump_start" and animated_sprite.frame >= animated_sprite.sprite_frames.get_frame_count("jump_start") - 1:
			animated_sprite.play("jump_keep")
	else:
		is_jumping = false
	
	# 处理攻击
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
	
	# 应用重力
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 移动角色
	move_and_slide()
	
	# 如果在地面上且没有移动，确保播放待机动画
	if is_on_floor() and velocity.x == 0 and animated_sprite.animation != "idle" and not is_attacking:
		animated_sprite.play("idle")

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
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")

func attack():
	is_attacking = true
	animated_sprite.play("attack")
	# 在这里添加攻击判定逻辑
	await get_tree().create_timer(0.5).timeout
	is_attacking = false
	# 根据当前状态恢复适当的动画
	if not is_on_floor():
		animated_sprite.play("jump_keep")
	elif velocity.x != 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")

func take_damage():
	if not is_hurt and not is_dead:
		is_hurt = true
		# 在这里添加受伤逻辑
		await get_tree().create_timer(0.5).timeout
		is_hurt = false

func die():
	is_dead = true
	# 在这里添加死亡逻辑 
