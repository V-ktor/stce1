
extends Control

# constans #

const INVENTORY = 0
const EQUIPMENT = 1
const STORE = 2
const SHIP = 3
const HANGAR = 4

# variables #

var icon = ""
var type
var ID
var pressed = false

onready var Menu = HUD.get_node("Station")


func get_drag_data(pos):
	if (icon==""):
		return -1
	
	var ii = TextureFrame.new()
	ii.set_expand(true)
	ii.set_texture(Equipment.outfits[icon]["icon"])
	ii.set_size(Vector2(64,64))
	set_drag_preview(ii)
	return [type,ID]

func can_drop_data(pos,data):
	if (typeof(data)!=TYPE_ARRAY):
		return false
	if (data[0]==type):
		return false
	if (type==EQUIPMENT):
		if (Equipment.outfits[Player.equipment[Player.ship_selected][0][Equipment.TYPE]]["slots"][ID-1].split("_")[0]==Equipment.outfits[Player.inventory[data[1]][Equipment.TYPE]]["type"]):
			return true
	elif (type==INVENTORY):
		if (data[0]==STORE):
			return true
	elif (type==STORE):
		if (data[0]==INVENTORY):
			return true
	elif (type==SHIP):
		if (data[0]==INVENTORY):
			return true
	return false

func drop_data(pos,data):
	if (type==EQUIPMENT && data[0]==INVENTORY):
		Equipment.equip(ID,data[1])
	elif (type==INVENTORY  && data[0]==STORE):
		Equipment.buy(data[1])
	elif (type==STORE  && data[0]==INVENTORY):
		Equipment.sell(data[1])
	elif (type==HANGAR && data[0]==SHIP):
		Equipment.buy_ship(data[1])
	elif (type==SHIP && data[0]==HANGAR):
		Equipment.sell_ship(data[1])

func _input_event(ev):
	if (ev.is_action_pressed("RMB")):
		if (pressed):
			pressed = false
			return
		pressed = true
		if (type==INVENTORY):
			if (Menu.menu==1):
				Equipment.equip_i(ID)
			elif (Menu.menu==2):
				Equipment.sell(ID)
		elif (type==EQUIPMENT):
			if (Menu.menu==1):
				Equipment.unequip(ID)
		elif (type==STORE):
			if (Menu.menu==2):
				Equipment.buy(ID)
		elif (type==SHIP):
			if (Menu.menu==4):
				Equipment.buy_ship(ID)
		elif (type==HANGAR):
			if (Menu.menu==4):
				Equipment.sell_ship(ID)
		hide_tooltip()
	elif (ev.is_action_pressed("LMB") && type==HANGAR):
		Equipment.swap_ship(ID)

func show_tooltip():
	if (is_visible()):
		Equipment.show_tooltip(type,ID)

func hide_tooltip():
	Equipment.hide_tooltip()
