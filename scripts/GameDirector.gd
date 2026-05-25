class_name GameDirector extends Node

var gameManagerScene = preload("res://scenes/GameManager.tscn")
var mainMenuScene = preload("res://scenes/MainMenu.tscn")

func _ready():
	_load_at_start()

func _load_at_start():
	add_scene(gameManagerScene)
	add_scene(mainMenuScene)

func add_scene(path):
	var newScene = path.instantiate()
	add_child(newScene)
	return newScene

func remove_scene(scene):
	remove_child(scene)
