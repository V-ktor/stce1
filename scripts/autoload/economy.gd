
extends Node
# Commodities and economy

const commodities = ["food","metal","energy_cells","electronics","luxury_goods",
"chemicals","radioactives","oxygen","textiles","medicine","industrial"]
const prices = {"food":40,"metal":60,"energy_cells":40,"electronics":110,
"luxury_goods":200,"chemicals":110,"radioactives":160,"oxygen":50,"textiles":50,
"medicine":150,"industrial":100}
const price_range = {"food":30,"metal":45,"energy_cells":30,"electronics":90,
"luxury_goods":150,"chemicals":85,"radioactives":120,"oxygen":35,"textiles":35,
"medicine":120,"industrial":75}

var commodity_icon = {
"food":preload("res://images/outfits/unknown.png"),
"metal":preload("res://images/outfits/unknown.png"),
"energy_cells":preload("res://images/outfits/unknown.png"),
"electronics":preload("res://images/outfits/unknown.png"),
"luxury_goods":preload("res://images/outfits/unknown.png"),
"chemicals":preload("res://images/outfits/unknown.png"),
"radioactives":preload("res://images/outfits/unknown.png"),
"oxygen":preload("res://images/outfits/unknown.png"),
"textiles":preload("res://images/outfits/unknown.png"),
"medicine":preload("res://images/outfits/unknown.png"),
"industrial":preload("res://images/outfits/unknown.png")}

var update_cycles = 0


func update():
	# calculate positions of planets and stations
	print("economy update")
	Stations.update_station_positions()
	
	# trade
	for s in Stations.stations:
		# calculate export
		var trade = {}
		for k in commodities:
			trade[k] = {}
		for to in Stations.stations:
			if (s!=to):
				var dist = Stations.stations_current_pos[s].distance_squared_to(Stations.stations_current_pos[to])/50000000.0
				for k in commodities:
					if (Stations.stations_cargo[s].has(k) && Stations.stations_cargo[to].has(k)):
						trade[k][to] = 1.0*max(Stations.stations_price[to][k]-Stations.stations_price[s][k],0)/price_range[k]*Stations.stations_cargo[to][k]*1000.0/dist/dist
					else:
						trade[k][to] = 0
			else:
				for k in commodities:
					trade[k][to] = 0
		
		for k in commodities:
			if (Stations.stations_cargo[s].has(k)):
				# normalize export weight array
				var N = 0
				for j in Stations.stations:
					N += trade[k][j]
				if (N>0):
					N = min(0.1*Stations.stations_cargo[s][k],Stations.stations_comm[s][k])/max(N,1.0)		# don't sell more than there is available or more than 10%
					for j in Stations.stations:
						trade[k][j] = ceil(trade[k][j]*N)
						if (trade[k][j]!=0):
							trade[k][j] = min(trade[k][j],floor(0.05*Stations.stations_cargo[j][k]))
#							print(str(s)+" -> "+str(j)+": "+str(trade[k][j])+"t of "+k+", profit: "+str(Stations.stations_price[j][k]-Stations.stations_price[s][k]))
							Stations.stations_comm[s][k] -= trade[k][j]
							Stations.stations_comm[j][k] += trade[k][j]
	
	for s in Stations.stations:
		for c in commodities:
			# consumption
			if (Stations.stations_cons[s].has(c)):
				Stations.stations_comm[s][c] -= Stations.stations_cons[s][c]
				if (Stations.stations_comm[s][c]<0):
					Stations.stations_comm[s][c] = 0
			
			# production
			if (Stations.stations_prod[s].has(c)):
				Stations.stations_comm[s][c] += Stations.stations_prod[s][c]
				if (Stations.stations_comm[s][c]>Stations.stations_cargo[s][c]):
					Stations.stations_comm[s][c] = Stations.stations_cargo[s][c]
			
			# 
			if (Stations.stations_cargo[s].has(c)):
				var filled = Stations.stations_comm[s][c]/Stations.stations_cargo[s][c]
				if (Stations.stations_ballance[s]>0):
					if (filled<0.2):
						Stations.stations_comm[s][c] += Stations.stations_ballance[s]
						print("added "+str(Stations.stations_ballance[s])+"t of "+c+" at "+s)
					elif (filled>0.8):
						Stations.stations_comm[s][c] -= Stations.stations_ballance[s]
						print("removed "+str(Stations.stations_ballance[s])+"t of "+c+" at "+s)
				
				if (Stations.stations_comm[s][c]<0):
					Stations.stations_comm[s][c] = 0
				elif (Stations.stations_comm[s][c]>Stations.stations_cargo[s][c]):
					Stations.stations_comm[s][c] = Stations.stations_cargo[s][c]
		
		for c in commodities:
			# recalculate prices
			if (Stations.stations_cargo[s].has(c)):
				var d = 0
				if (Stations.stations_prod[s].has(c)):
					d += Stations.stations_prod[s][c]
				if (Stations.stations_cons[s].has(c)):
					d -= Stations.stations_cons[s][c]
				var p = (Stations.stations_comm[s][c]+2.0*d)/Stations.stations_cargo[s][c]-0.5
				Stations.stations_price[s][c] = round(prices[c]+price_range[c]*clamp(0.5-2*p*p*sign(p),0.0,1.0))
			else:
				Stations.stations_price[s][c] = 0
	
	update_cycles += 1
	if (update_cycles>=24):
		Stations.reset_outfits()
		update_cycles = 0
	
#	get_node("TimerEconomyUpdate").set_wait_time(60.0*0.025)

func update_station_prices():
	for s in Stations.stations:
		for c in commodities:
			# recalculate prices
			if (Stations.stations_cargo[s].has(c)):
				var d = 0
				if (Stations.stations_prod[s].has(c)):
					d += Stations.stations_prod[s][c]
				if (Stations.stations_cons[s].has(c)):
					d -= Stations.stations_cons[s][c]
				var p = (Stations.stations_comm[s][c]+2.0*d)/Stations.stations_cargo[s][c]-0.5
				Stations.stations_price[s][c] = round(prices[c]+price_range[c]*clamp(0.5-2*p*p*sign(p),0.0,1.0))
			else:
				Stations.stations_price[s][c] = 0

func _ready():
	var ti = Timer.new()
	ti.set_name("TimerEconomyUpdate")
	ti.connect("timeout",self,"update")
	ti.set_wait_time(60.0)
	add_child(ti)
	ti.start()
	ti.set_active(false)
	
	for c in commodities:
		Equipment.outfits[c] = {"type":"commodity","icon":commodity_icon[c],"mass":1.0,"name":c}
