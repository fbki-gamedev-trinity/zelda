extends Node

class_name SpellSystem

var spell_configs: Array[SpellConfig] = [
	preload("res://resources/fire_spell_config.tres"),
	preload("res://resources/water_spell_config.tres"),
	preload("res://resources/rocks_spell_config.tres")
]

var arrow_configs: Array[SpellConfig] = [
	preload("res://resources/fire_arrow_config.tres"),
	preload("res://resources/water_arrow_config.tres"),
	preload("res://resources/air_arrow_config.tres")
]


const SPELL_SCENE = preload("res://scenes/spell.tscn")
const ARROW_SCENE = preload("res://scenes/arrow.tscn")


var configs = {
	"ranged": arrow_configs,
	"magic": spell_configs
}

var scenes = {
	"ranged": ARROW_SCENE,
	"magic": SPELL_SCENE
}

@onready var animated_sprite_2d: AnimationController = %AnimatedSprite2D
@onready var inventory: Inventory = $"../inventory"
@onready var on_screen_ui: OnScreenUI = $"../onScreenUI"
@onready var combat_system: CombatSystem = $"../CombatSystem"

var current_spell_cooldown = -1
var cooldown_timer = 1000
var active_spell_index = -1

func _ready() -> void:
	inventory.spell_activated.connect(on_spell_activated)
	combat_system.cast_active_spell.connect(on_cast_active_spell)
	
func _process(delta: float) -> void:
	if current_spell_cooldown != -1 && cooldown_timer < current_spell_cooldown:
		cooldown_timer += delta
		
func on_cast_active_spell():
	var spell_direction = animated_sprite_2d.attack_vector
	var spell_config = configs[combat_system.left_weapon.attack_type.to_lower()][active_spell_index]
	
	if cooldown_timer != 0 and cooldown_timer < current_spell_cooldown:
		return
	else: 
		cooldown_timer = 0
		
	on_screen_ui.spell_cooldown_activated(current_spell_cooldown)
	var spell_rotation = get_spell_rotation(spell_direction, spell_config.initial_rotation)
	var spell: Spell = scenes[combat_system.left_weapon.attack_type.to_lower()].instantiate()
	get_tree().root.add_child(spell)
	spell.rotation_degrees = spell_rotation
	spell.direction = spell_direction
	spell.init(spell_config)
	spell.position = get_parent().global_position

func get_spell_rotation(spell_direction: Vector2, initial_rotation: int):
	match spell_direction:
		Vector2.LEFT:
			return -180 + initial_rotation
		Vector2.RIGHT:
			return 0 + initial_rotation
		Vector2.UP:
			return -90 + initial_rotation
		Vector2.DOWN:
			return 90 + initial_rotation
	
		
func on_spell_activated(idx: int):
	active_spell_index = idx
	var spell_config = configs[combat_system.left_weapon.attack_type.to_lower()][idx]
	on_screen_ui.toggle_spell_slot(true, spell_config.ui_texture)
	print(spell_config.initial_cooldown)
	current_spell_cooldown = spell_config.initial_cooldown #вот тут ломается