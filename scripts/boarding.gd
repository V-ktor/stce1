
extends Panel

const defense_bonus = 1.25

var text_log
var active = false
var player
var enemy
var player_crew = 1
var enemy_crew = 1
var last_player_crew = 1
var last_enemy_crew = 1
var player_attacking = false
var enemy_attacking = false
var player_inc_steal = 0
var enemy_inc_steal = 0
var player_defeated = false
var enemy_defeated = false
var num_enemy_loot = 0
var num_player_loot = 0
var enemy_switch_attack_limit = 0.0


func _start(attacking):
	Player.time_speedup = false
	player = get_node("/root/Main/Player")
	
	text_log.clear()
	text_log.push_color(Color(1.0,1.0,1.0))
	text_log.add_text(tr("THE_AIRLOCK_BLASTS_OPEN")+" ")
	if (attacking):
		text_log.add_text(tr("YOU_ARE_READY_TO_ATTACK")+"\n")
	else:
		text_log.push_color(Color(1.0,0.8,0.7))
		text_log.add_text(tr("YOU_ARE_ATTACKED_BY")+" "+enemy.name+"!\n")
	update_loot()
	
	get_node("LabelVS").set_text(player.name+" VS "+enemy.name)
	
	active = true
	player_crew = player.crew
	enemy_crew = enemy.crew
	last_player_crew = player_crew
	last_enemy_crew = enemy_crew
	player_attacking = attacking
	enemy_attacking = !attacking
	player_defeated = false
	enemy_defeated = false
	player_inc_steal = 1.0*player_crew/num_player_loot
	enemy_inc_steal = 1.0*enemy_crew/num_enemy_loot
	enemy_switch_attack_limit = 1.0
	set_process(true)
	show()

func update_loot():
	var text = get_node("Outfits")
	text.clear()
	text.add_text(tr("LOOTABLE_OUTFITS")+":\n")
	num_enemy_loot = 0
	num_player_loot = 0
	for o in enemy.inventory+enemy.equipment:
		if (o[Equipment.TYPE]!=""):
			var ammount = o[Equipment.AMMOUNT]
			var name = Equipment.outfits[o[Equipment.TYPE]]["name"]
			var mass = Equipment.outfits[o[Equipment.TYPE]]["mass"]
			if (ammount>1):
				text.add_text(str(ammount)+"x ")
			text.add_text(tr(name)+" ("+str(mass)+Equipment.units["mass"]+")\n")
			num_enemy_loot += 1
	for o in player.inventory+player.equipment:
		if (o[Equipment.TYPE]!=""):
			num_player_loot += 1

func undock():
	active = false
	set_process(false)
	player.crew = round(player_crew)
	Player.ship_crew[Player.ship_selected] = player.crew
	enemy.crew = round(enemy_crew)
	player.disable_grappling_hook()
	enemy.disable_grappling_hook()
	player.boarding = false
	enemy.boarding = false
	enemy.credits = 0
	enemy.recalc()
	player.recalc()
	hide()

func _player_attack():
	if (player_defeated || enemy_defeated):
		player_attacking = false
	else:
		player_attacking = true

func _player_defend():
	player_attacking = false

func _player_undock():
	if (!active):
		return
	
	_player_defend()
	if (!player_attacking && !enemy_attacking):
		undock()
	else:
		text_log.push_color(Color(1.0,0.6,0.4))
		text_log.add_text(tr("ENEMY_PREVENTS_YOU_FROM_DETACHING_DOCKING_CLAMPS")+"\n")

func enemy_attack():
	if (!enemy_attacking):
		text_log.push_color(Color(1.0,0.8,0.6))
		text_log.add_text(tr("ENEMY_STARTS_ATTACKING")+"\n")
	enemy_attacking = true

func enemy_defend():
	if (enemy_attacking):
		text_log.push_color(Color(0.6,1.0,0.8))
		text_log.add_text(tr("ENEMY_STOPS_ATTACK")+"\n")
	enemy_attacking = false

func enemy_undock():
	enemy_defend()
	if (!player_attacking && !enemy_attacking):
		undock()

func steal_enemy_cash():
	var ammount = floor(enemy.credits*rand_range(0.05,0.15))
	
	Player.credits += ammount
	player.credits = Player.credits
	enemy.credits -= ammount
	
	text_log.push_color(Color(0.7,1.0,0.8))
	text_log.add_text(tr("GAINED")+" "+str(ammount)+tr(Equipment.units["price"])+".\n")

func steal_enemy_cargo():
	var player_cargo = player.cargo-Equipment.get_cargo_mass(player.inventory)
	if (player_cargo<=0):
		return
	if (enemy.inventory.size()<1):
		steal_enemy_equipment()
		return
	
	var ID = randi()%(enemy.inventory.size())
	var ammount = min(player_cargo/Equipment.outfits[enemy.inventory[ID][Equipment.TYPE]]["mass"],enemy.inventory[ID][Equipment.AMMOUNT])
	if (ammount<1):
		return
	Equipment.add_item([enemy.inventory[ID][Equipment.TYPE],ammount])
	player.inventory = Player.inventory
	text_log.push_color(Color(0.7,1.0,0.8))
	text_log.add_text(tr(Equipment.outfits[enemy.inventory[ID][Equipment.TYPE]]["name"])+" "+tr("ACQUIRED")+" ("+str(player_cargo-Equipment.outfits[enemy.inventory[ID][Equipment.TYPE]]["mass"]*ammount)+Equipment.units["cargo_space"]+" "+tr("FREE")+")"+".\n")
	enemy.inventory[ID][Equipment.AMMOUNT] -= ammount
	if (enemy.inventory[ID][Equipment.AMMOUNT]<1):
		enemy.inventory.remove(ID)
	
	update_loot()

func steal_enemy_equipment():
	var player_cargo = player.cargo-Equipment.get_cargo_mass(player.inventory)
	var loot = []
	for i in range(enemy.equipment.size()):
		var type = enemy.equipment[i][Equipment.TYPE]
		if (type!="" && Equipment.outfits[type]["mass"]<=player_cargo && Equipment.outfits[type]["type"]!="ship"):
			loot.push_back(i)
	
	if (loot.size()<1):
		return
	
	var ID = loot[randi()%(loot.size())]
	var ammount = min(enemy.equipment[ID][Equipment.AMMOUNT],floor(player_cargo/Equipment.outfits[enemy.equipment[ID][Equipment.TYPE]]["mass"]))
	Equipment.add_item([enemy.equipment[ID][Equipment.TYPE],ammount])
	player.inventory = Player.inventory
	text_log.push_color(Color(0.7,1.0,0.8))
	if (enemy.equipment[ID][Equipment.AMMOUNT]>1):
		text_log.add_text(str(ammount)+"x ")
	text_log.add_text(tr(Equipment.outfits[enemy.equipment[ID][Equipment.TYPE]]["name"])+" "+tr("ACQUIRED")+" ("+str(player_cargo-Equipment.outfits[enemy.equipment[ID][Equipment.TYPE]]["mass"]*ammount)+Equipment.units["cargo_space"]+" "+tr("FREE")+")"+".\n")
	enemy.equipment[ID][Equipment.AMMOUNT] -= ammount
	if (enemy.equipment[ID][Equipment.AMMOUNT]<1):
		enemy.equipment[ID] = ["",0]
	
	update_loot()

func steal_player_cash():
	var ammount = floor(Player.credits*rand_range(0.05,0.15))
	
	Player.credits -= ammount
	player.credits = Player.credits
	enemy.credits += ammount
	
	text_log.push_color(Color(1.0,0.8,0.7))
	text_log.add_text(tr("LOST")+" "+str(ammount)+tr(Equipment.units["price"])+".\n")

func steal_player_cargo():
	var enemy_cargo = enemy.cargo-Equipment.get_cargo_mass(enemy.inventory)
	if (enemy_cargo<=0):
		return
	if (player.inventory.size()<1):
		steal_player_equipment()
		return
	
	var ID = randi()%(player.inventory.size())
	var ammount = min(enemy_cargo/Equipment.outfits[player.inventory[ID][Equipment.TYPE]]["mass"],player.inventory[ID][Equipment.AMMOUNT])
	if (ammount<1):
		return
	enemy.inventory.push_back([player.inventory[ID][Equipment.TYPE],ammount])
	text_log.push_color(Color(1.0,0.8,0.7))
	text_log.add_text(tr(Equipment.outfits[player.inventory[ID][Equipment.TYPE]]["name"])+" "+tr("HAS_BEEN_STOLEN")+".\n")
	player.inventory[ID][Equipment.AMMOUNT] -= ammount
	if (player.inventory[ID][Equipment.AMMOUNT]<1):
		player.inventory.remove(ID)
	
	num_player_loot -= 1

func steal_player_equipment():
	var enemy_cargo = enemy.cargo-Equipment.get_cargo_mass(enemy.inventory)
	var loot = []
	for i in range(player.equipment.size()):
		var type = player.equipment[i][Equipment.TYPE]
		if (type!="" && Equipment.outfits[type]["mass"]<=enemy_cargo && Equipment.outfits[type]["type"]!="ship"):
			loot.push_back(i)
	
	if (loot.size()<1):
		return
	
	var ID = loot[randi()%(loot.size())]
	var ammount = min(player.equipment[ID][Equipment.AMMOUNT],floor(enemy_cargo/Equipment.outfits[player.equipment[ID][Equipment.TYPE]]["mass"]))
	text_log.push_color(Color(1.0,0.8,0.7))
	if (player.equipment[ID][Equipment.AMMOUNT]>1):
		text_log.add_text(str(ammount)+"x ")
	text_log.add_text(tr(Equipment.outfits[player.equipment[ID][Equipment.TYPE]]["name"])+" "+tr("HAS_BEEN_STOLEN")+"!\n")
	player.equipment[ID][Equipment.AMMOUNT] -= ammount
	if (player.equipment[ID][Equipment.AMMOUNT]<1):
		player.equipment[ID] = ["",0]
	
	num_player_loot -= 1

func _process(delta):
	if (!(player in get_node("/root/Main").ships) || !(enemy in get_node("/root/Main").ships)):
		undock()
	
	var player_attack = round(player_crew)
	var enemy_attack = round(enemy_crew)
	var sum = player_crew+enemy_crew
	if (!player_attacking):
		player_attack *= defense_bonus*player.defense_bonus
	else:
		player_attack *= player.attack_bonus
	if (!enemy_attacking):
		enemy_attack *= defense_bonus*enemy.defense_bonus
	else:
		enemy_attack *= enemy.attack_bonus
	
	get_node("Bar").set_max(sum-2)
	get_node("Bar").set_value(player_crew-1)
	get_node("NumberLeft").set_text(tr("CREW")+": "+str(last_player_crew)+" ("+str(tr("ATTACK_STRENGTH"))+" "+str(round(100*player_attack)/100.0)+")")
	get_node("NumberRight").set_text("("+str(tr("ATTACK_STRENGTH"))+" "+str(round(100*enemy_attack)/100.0)+") "+tr("CREW")+": "+str(last_enemy_crew))
	
	if (player_attacking || enemy_attacking):
		player_crew -= delta*enemy_attack*0.5/sum*rand_range(0.8,1.2)
		enemy_crew -= delta*player_attack*0.5/sum*rand_range(0.8,1.2)
		
		if (player_crew<1):
			player_crew = 1
			player_defeated = true
			text_log.push_color(Color(1.0,0.4,0.4))
			text_log.add_text(tr("YOU_ARE_DEFEATED")+"\n")
			steal_player_equipment()
			steal_player_cargo()
			steal_player_cash()
			_player_defend()
			enemy_defend()
			set_process(false)
		if (enemy_crew<1):
			enemy_crew = 1
			enemy_defeated = true
			text_log.push_color(Color(0.4,1.0,0.4))
			text_log.add_text(tr("ENEMY_HAS_BEEN_DEFEATED")+"\n")
			steal_enemy_equipment()
			steal_enemy_cargo()
			steal_enemy_cash()
			_player_defend()
			enemy_defend()
			set_process(false)
		
		if (round(player_crew)!=last_player_crew):
			text_log.push_color(Color(1.0,0.5,0.5))
			text_log.add_text(tr("LOST_CREW")+"\n")
			last_player_crew = round(player_crew)
		if (round(enemy_crew)!=last_enemy_crew):
			text_log.push_color(Color(0.5,1.0,0.5))
			text_log.add_text(tr("DEFEATED_ENEMY_CREW")+"\n")
			last_enemy_crew = round(enemy_crew)
		
		if (!player_attacking && enemy_attacking && player_crew<player_inc_steal*num_player_loot):
			steal_player_cargo()
		if (!enemy_attacking && player_attacking && enemy_crew<enemy_inc_steal*num_enemy_loot):
			steal_enemy_cargo()
	
	enemy_switch_attack_limit -= delta
	if (enemy_switch_attack_limit<0.0):
		enemy_switch_attack_limit = 1.0
		if (enemy_crew>player_crew && enemy_attack>player_attack):
			enemy_attack()
			enemy_switch_attack_limit += 1.0
		else:
			if (enemy_attack<2*player_attack && 1.5*enemy_crew<player_crew):
				enemy_undock()
			else:
				enemy_defend()
				enemy_switch_attack_limit += 1.0

func _ready():
	text_log = get_node("Log")
	text_log.set_scroll_follow(true)
