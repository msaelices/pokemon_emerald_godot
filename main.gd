extends Node2D


@onready var rooms: Node2D = $rooms
@onready var player: player
@onready var anim_player: AnimationPlayer = $animation_player
@onready var music_player: AudioStreamPlayer = $music_player

const battle_scn: PackedScene = preload("res://battle/battle.tscn")

signal transition_finished


const rooms_arr: Array = [preload("res://rooms/room_00.tscn"), preload("res://rooms/room_01.tscn"), preload("res://rooms/room_02.tscn"), 
preload("res://rooms/room_03.scn"), preload("res://rooms/room_04.tscn"), preload("res://rooms/room_05.tscn"), 
preload("res://rooms/room_06.tscn"), preload("res://rooms/room_07.tscn"), preload("res://rooms/room_08.tscn"),
preload("res://rooms/room_09.tscn"), preload("res://rooms/room_10.tscn")]



func _ready() -> void:
	
	start()
	
	global.connect("transition", Callable(self, "transition"))
	global.connect("start_battle", Callable(self, "start_battle"))
	global.connect("end_battle", Callable(self, "end_battle"))
	global.connect("start_dialogue", Callable(self, "start_dialogue"))
	global.connect("end_dialogue", Callable(self, "end_dialogue"))
	global.connect("start_game", Callable(self, "start_game"))
	global.connect("save_game", Callable(self, "save_game"))
	global.connect("enter_new_area", Callable(self, "enter_new_area"))


const save_path: String = "user://savefile.save"
var data: Array 


func start() -> void:
	
	anim_player.play("fade_out")
	
	data = FileAccess.open(save_path, FileAccess.READ).get_var().duplicate()
	
	global.current_room = data[0][0]
	
	rooms.add_child(rooms_arr[global.current_room].instantiate())
	
	var player_inst: CharacterBody2D = player_scn.instantiate()
	rooms.get_child(0).get_node("tilemap").add_child(player_inst)
	player_inst.position = data[0][1]
	player = $rooms.get_child(0).get_node("tilemap").get_node("player")
	
	global.player_pokemon.clear()
	global.player_pokemon.append_array(data[1])
	global.player_moveset.append_array(data[2])
	global.player_inventory.append_array(data[3])
	
	play_music()


@onready var sfx_player: AudioStreamPlayer = $sfx_player

const player_scn: PackedScene = preload("res://player/player.tscn")

var new_room_int: int = 0
var new_player_position: Vector2
var player_trans_inst
var transition_type: int
var room_inst: Node2D


func transition(new_room: int, next_position: Vector2, trans_type: int) -> void:
	
	if new_room < 0:
		
		play_cutscene(new_room)
		
	else:
		player_trans_inst = player_scn.instantiate()
		player_trans_inst.position = next_position
		new_room_int = new_room
		global.current_room = new_room
		anim_player.play("fade_in")
		room_inst = rooms_arr[new_room].instantiate()
		transition_type = trans_type
		
		sfx_player.play()
		await sfx_player.finished


func end_transtition() -> void:
	
	if transition_type == 0:
		player.queue_free()
	
	rooms.get_child(0).queue_free()
	rooms.add_child(room_inst)
	
	await get_tree().create_timer(1).timeout
	
	rooms.get_child(0).get_node("tilemap").add_child(player_trans_inst)
	player = $rooms.get_child(0).get_node("tilemap").get_node("player")
	
	play_music()
	anim_player.play("fade_out")
	enter_new_area(global.current_area)
	transition_finished.emit()


func start_battle(enemy_pokemon: Array, enemy_moveset: Array, battle_type: int) -> void:
	
	stop_music()
	player = get_node("rooms").get_child(0).get_node("tilemap").get_child(0)
	player.process_mode = Node.PROCESS_MODE_DISABLED
	
	var battle_instance = battle_scn.instantiate()
	add_child(battle_instance)
	
	battle_instance.set_battle(enemy_pokemon, enemy_moveset, battle_type)


func end_battle() -> void:
	
	player.process_mode = Node.PROCESS_MODE_INHERIT
	get_node("battle").queue_free()
	play_music()


const dialogue_scn: PackedScene = preload("res://dialogue/dialogue_scn.tscn")

var dialogue_inst: CanvasLayer


func start_dialogue(text: Array) -> void:
	
	dialogue_inst = dialogue_scn.instantiate()
	dialogue_inst.set_text(text)
	add_child(dialogue_inst)


func end_dialogue() -> void:
	
	player.process_mode = Node.PROCESS_MODE_INHERIT
	dialogue_inst.queue_free()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	
	if anim_name == "fade_in":
		end_transtition()


func save_game() -> void:
	
	data.clear()
	print(data)
	data.append_array([[global.current_room, player.position], global.player_pokemon, global.player_moveset, global.player_inventory])
	print(data)
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(data)
	file.close()


func stop_music() -> void:
	
	music_player.stop()
	music_player.set_stream(null)


func play_music() -> void:
	
	match global.current_room:
		
		0:
			if !music_player.stream == load("res://sounds/1-05 Littleroot Town.mp3"):
				music_player.stream = load("res://sounds/1-05 Littleroot Town.mp3")
			else: return
		1:
			if !music_player.stream == load("res://sounds/1-05 Littleroot Town.mp3"):
				music_player.stream = load("res://sounds/1-05 Littleroot Town.mp3")
			else: return
		2:
			if !music_player.stream == load("res://sounds/1-05 Littleroot Town.mp3"):
				music_player.stream = load("res://sounds/1-05 Littleroot Town.mp3")
			else: return
		3:
			if !music_player.stream == load("res://sounds/1-05 Littleroot Town.mp3"):
				music_player.stream = load("res://sounds/1-05 Littleroot Town.mp3")
			else:
				return
	
	music_player.play()


func enter_new_area(new_area: int) -> void:
	
	var displayed_areas: Array = []
	var current_area: int = new_area
	
	match new_area:
		
		0:
			displayed_areas = [0, 1]
		1:
			displayed_areas = [0, 1, 2]
		2:
			displayed_areas = [1, 2, 3, 4]
		3:
			displayed_areas = [2, 3] # weird water connection
		4:
			displayed_areas = [2, 4, 5]
		5:
			displayed_areas = [4, 5, 6]
		6:
			displayed_areas = [6, 7, 9]
		7:
			displayed_areas = []
	
	global.current_area = current_area
	
	global.enter_new_room.emit(displayed_areas, current_area)

@onready var cutscene_player: AnimationPlayer = $cutscene_player
@onready var cutscene_01: Node2D = $cutscenes/cutscene_01


func play_cutscene(cutscene: int) -> void:
	
	if cutscene == -1:
		cutscene_one()


func cutscene_one() -> void:
	
	transition(3, Vector2(8, 56), 0)
	await transition_finished
	player.process_mode = Node.PROCESS_MODE_DISABLED
	player.sprite.frame = 4
	cutscene_01.visible = true
	global.start_dialogue.emit([["MOM We're here finally fuck"]])
	await global.end_dialogue
	cutscene_player.play("cutscene_000")
	await cutscene_player.animation_finished
	cutscene_01.queue_free()
	
	transition(2, Vector2(40, 88), 0)


func _on_cut_scene_player_animation_finished(anim_name: StringName) -> void:
	pass # Replace with function body.
