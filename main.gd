extends Node2D

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene
@onready var camera = $Camera2D


func _on_host_pressed():
	peer.create_server(1027)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	camera.enabled = false
	$CanvasLayer.hide()

func _on_join_pressed():
	peer.create_client("localhost", 1027)
	multiplayer.multiplayer_peer = peer
	camera.enabled = false
	$CanvasLayer.hide()


func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)


func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)
	
	
func del_player(id):
	rpc("_del_player", id)
	
	
@rpc("any_peer", "call_local")
func _del_player(id):
	get_node(str(id)).queue_free()
