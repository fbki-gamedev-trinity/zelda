extends Node

class_name CombatSystem

@onready var animated_sprite_2d: AnimationController = $"../AnimatedSprite2D"
@onready var right_hand_weapon_sprite: Sprite2D = $RightHandWeaponSprite
@onready var right_hand_collision_shape_2d: CollisionShape2D = $RightHandWeaponSprite/Area2D/CollisionShape2D
@onready var left_hand_weapon_sprite: Sprite2D = $LeftHandWeaponSprite2
@onready var left_hand_collision_shape_2d: CollisionShape2D = $LeftHandWeaponSprite2/Area2D/CollisionShape2D

@export var right_weapon: WeaponItem
@export var left_weapon: WeaponItem

var can_attack = true

func _ready() -> void:
	animated_sprite_2d.attack_animation_finished.connect(on_attack_animation_finished)

func _input(event):
	if Input.is_action_just_pressed("right_hand_action"):
		if !can_attack:
			return
		can_attack = false
		animated_sprite_2d.play_attack_animation()
		var attack_direction = animated_sprite_2d.attack_direction
		if right_weapon == null:
			return
		var attack_data = right_weapon.get_data_for_direction(attack_direction)
		right_hand_weapon_sprite.position = attack_data.get("attachment_position")
		right_hand_weapon_sprite.rotation_degrees = attack_data.get("rotation")
		right_hand_weapon_sprite.z_index = attack_data.get("z_index")
		right_hand_weapon_sprite.show()
		
	if Input.is_action_just_pressed("left_hand_action"):
		animated_sprite_2d.play_attack_animation()
		
func set_active_weapon(weapon: WeaponItem, slot_to_equip: String):
	if slot_to_equip == "Left_Hand":
		if weapon.collision_shape != null:
			left_hand_collision_shape_2d.shape == weapon.collision_shape
		left_hand_weapon_sprite.texture = weapon.in_hand_texture
		left_weapon = weapon
		
	elif slot_to_equip == "Right_Hand":
		if weapon.collision_shape != null:
			right_hand_collision_shape_2d.shape == weapon.collision_shape
		right_hand_weapon_sprite.texture = weapon.in_hand_texture
		right_weapon = weapon

func on_attack_animation_finished():
	can_attack = true
	right_hand_weapon_sprite.hide()
	left_hand_weapon_sprite.hide()
