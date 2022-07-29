extends Node2D

const SCALE = 0.01 #五维最高100
const WIDTH = 1.5
const POSITION = Vector2(132.5,111.8)
const COLOR = Color(1,1,1,1)
const POINTS = PoolVector2Array([Vector2(80,19.2), Vector2(185,19.2),
	  Vector2(240,111.8), Vector2(185,205.5), Vector2(80,205.5), Vector2(25,111.8)])
var current_points = PoolVector2Array([Vector2(80,19.2), Vector2(185,19.2),
	  Vector2(240,111.8), Vector2(185,205.5), Vector2(80,205.5), Vector2(25,111.8)])

func _process(_delta):
	update()

func _draw():
	draw_colored_polygon(POINTS,Color.gray)
	draw_line(POSITION, Vector2(80,19.2), Color.darkgray, WIDTH)
	draw_line(POSITION, Vector2(185,19.2), Color.darkgray, WIDTH)
	draw_line(POSITION, Vector2(240,111.8), Color.darkgray, WIDTH)
	draw_line(POSITION, Vector2(185,205.5), Color.darkgray, WIDTH)
	draw_line(POSITION, Vector2(80,205.5), Color.darkgray, WIDTH)
	draw_line(POSITION, Vector2(25,111.8), Color.darkgray, WIDTH)
	
	if get_node("../..").current_person != null:
		draw_date()
		draw_colored_polygon(current_points,Color.teal)

func draw_date():
	var command: Vector2 = Util.line_scale(get_node("../..").current_person.get_command()*0.01,POSITION,Vector2(80,19.2))
	var intelligence: Vector2 = Util.line_scale(get_node("../..").current_person.get_intelligence()*0.01,POSITION,Vector2(185,19.2))
	var politics: Vector2 = Util.line_scale(get_node("../..").current_person.get_politics()*0.01,POSITION,Vector2(240,111.8))
	var glamour: Vector2 = Util.line_scale(get_node("../..").current_person.get_glamour()*0.01,POSITION,Vector2(185,205.5))
	var commands: Vector2 = Util.line_scale(get_node("../..").current_person.get_command()*0.01,POSITION,Vector2(80,205.5))
	var strength: Vector2 = Util.line_scale(get_node("../..").current_person.get_strength()*0.01,POSITION,Vector2(25,111.8))
	
	
	current_points = PoolVector2Array([command,intelligence,politics,glamour,commands,strength])
