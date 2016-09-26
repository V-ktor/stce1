
extends Node

# constants #

const OVERVIEW = 0
const EQUIPMENT = 1
const TRADE = 2
const BAR = 3
const SHIPYARD = 4
const MAP = 5
const CREW = 6

const num_planets = 8
const asteroids_inner_dist_min = 450000
const asteroids_inner_dist_max = 550000
const asteroids_outer_dist_min =  875000
const asteroids_outer_dist_max = 1400000
const dist_pirate_inner = 125000

const republic_police_ships = [
[["srf-m",1],["paa",1],["paa",1],["mis",4],["rgs",1],["egs",1],["egs",1],["aps",1],["scs",1]],
[["srf-m",1],["elb",1],["elb",1],["mis",4],["rgs",1],["egs",1],["egs",1],["ass",1],["scs",1]],
[["srf-m",1],["scg",1],["scg",1],["drt",8],["rgs",1],["egs",1],["egs",1],["bos",1],["scs",1]]
]
const republic_military_ships = [
[["rpf-m",1],["skg",1],["skg",1],["drt",8],["drt",8],["rbm",1],["cld",1],["bas",1],["ebm",1],["ebm",1],["aps",1],["scs",1]],
[["sos-m",1],["paa",1],["paa",1],["drt",8],["rgs",1],["shs",1],["ebm",1],["ass",1]],
[["hwf-m",1],["plc",1],["plc",1],["plg",1],["plg",1],["siw",4],["rbm",1],["shs",1],["fcs",1],["egm",1],["egm",1],["apm",1],["apm",1]],
[["hwf-m",1],["shr",1],["shr",1],["paa",1],["paa",1],["siw",4],["rgm",1],["shs",1],["cld",1],["egm",1],["egm",1],["apm",1],["bom",1]],
[["hwf-m",1],["iog",1],["iog",1],["chg",1],["chg",1],["siw",4],["rgm",1],["shs",1],["bas",1],["egm",1],["egm",1],["asm",1],["stm",1]],
[["b01-m",1],["plc",1],["plc",1],["mtr",8],["mtr",8],["drt",8],["siw",4],["drt",8],["siw",4],["rgm",1],["shs",1],["shs",1],["egm",1],["egm",1],["apm",1],["apm",1]]
]
const civil_trader_ships = [
[["fr1",1],["chg",1],["chg",1],["plt",1],["cgt",1],["plt",1],["mis",4],["rbs",1],["rbs",1],["rbs",1],["shm",1],["cem",1],["cem",1],["ebm",1],["ebm",1],["ebm",1],["apm",1],["apm",1]],
[["fr1",1],["paa",1],["paa",1],["cgt",1],["cgt",1],["mlt",1],["mis",4],["rbs",1],["rbs",1],["rbs",1],["cem",1],["cem",1],["cem",1],["egm",1],["egm",1],["egm",1],["asm",1],["asm",1]],
[["fr1",1],["elb",1],["elb",1],["plt",1],["plt",1],["mlt",1],["drt",4],["rbs",1],["rbs",1],["rbs",1],["bam",1],["cem",1],["cem",1],["ebm",1],["ebm",1],["ebm",1],["stm",1],["asm",1]],
[["fr2",1],["chg",1],["chg",1],["mis",4],["rbs",1],["shs",1],["ebs",1],["ebs",1],["bos",1]],
[["fr2",1],["paa",1],["paa",1],["mis",4],["rbs",1],["ces",1],["egs",1],["egs",1],["ass",1]],
[["tr1",1],["plt",1],["drt",8],["drt",8],["rbs",1],["ces",1],["ebs",1],["ebs",1],["aps",1],["sts",1]],
[["tr1",1],["cgt",1],["mis",4],["mis",4],["rbs",1],["ces",1],["ebs",1],["ebs",1],["ass",1],["bos",1]]
]


# variables #

var last_player_pos = Vector2(0,0)
var sun_scale = 1.0
var num_pirates = 0
var num_republic_police = 0
var num_republic_military = 0
var num_civil_trader = 0
var objects = []
var ships = []
var missiles = []


# system variables #

const stations = [
"Planet1/Solar01","Planet1/Solar02","Planet1/Solar03","Planet1/Solar04","Planet1/Farm01","Planet1/Farm02",
"Planet2/Solar01","Planet2/Solar02","Planet2/Farm01","Planet2/Farm02","Planet2/Farm03","Planet2/Farm04",
"Planet3/Shipyard","Planet3/Station01","Planet3/Station02","Planet3/Solar01",
"Planet4/Station01","Planet4/Farm01","Planet4/Solar01","Planet4/Mine01","Planet4/Mine02",
"Planet5/Mine01","Planet5/Refinery01","Planet5/Refinery02",
"Planet6/Station01","Planet6/Refinery01","Planet6/Refinery02","Planet6/Farm01","Planet6/Farm02","Planet6/Solar01",
"Planet7/Refinery01","Planet7/Mine01","Planet7/Solar01","Planet7/Solar02",
"Planet8/Mine01","Planet8/Mine02"
]
var stations_icon = {
"Planet1/Solar01":"res://images/stations/solar02_icon.png",
"Planet1/Solar02":"res://images/stations/solar02_icon.png",
"Planet1/Solar03":"res://images/stations/solar01_icon.png",
"Planet1/Solar04":"res://images/stations/solar02_icon.png",
"Planet1/Farm01":"res://images/stations/farm01_icon.png",
"Planet1/Farm02":"res://images/stations/farm02_icon.png",
"Planet2/Solar01":"res://images/stations/solar02_icon.png",
"Planet2/Solar02":"res://images/stations/solar02_icon.png",
"Planet2/Farm01":"res://images/stations/farm02_icon.png",
"Planet2/Farm02":"res://images/stations/farm02_icon.png",
"Planet2/Farm03":"res://images/stations/farm01_icon.png",
"Planet2/Farm04":"res://images/stations/farm01_icon.png",
"Planet3/Shipyard":"res://images/stations/shipyard_icon.png",
"Planet3/Station01":"res://images/stations/station01_icon.png",
"Planet3/Station02":"res://images/stations/station02_icon.png",
"Planet3/Solar01":"res://images/stations/solar01_icon.png",
"Planet4/Station01":"res://images/stations/station01_icon.png",
"Planet4/Farm01":"res://images/stations/farm02_icon.png",
"Planet4/Solar01":"res://images/stations/solar02_icon.png",
"Planet4/Mine01":"res://images/stations/mine01_icon.png",
"Planet4/Mine02":"res://images/stations/mine01_icon.png",
"Planet5/Mine01":"res://images/stations/mine01_icon.png",
"Planet5/Refinery01":"res://images/stations/station02_icon.png",
"Planet5/Refinery02":"res://images/stations/station02_icon.png",
"Planet6/Station01":"res://images/stations/station01_icon.png",
"Planet6/Refinery01":"res://images/stations/station02_icon.png",
"Planet6/Refinery02":"res://images/stations/station02_icon.png",
"Planet6/Farm01":"res://images/stations/farm01_icon.png",
"Planet6/Farm02":"res://images/stations/farm01_icon.png",
"Planet6/Solar01":"res://images/stations/solar02_icon.png",
"Planet7/Refinery01":"res://images/stations/station02_icon.png",
"Planet7/Mine01":"res://images/stations/mine01_icon.png",
"Planet7/Solar01":"res://images/stations/solar01_icon.png",
"Planet7/Solar02":"res://images/stations/solar02_icon.png",
"Planet8/Mine01":"res://images/stations/mine01_icon.png",
"Planet8/Mine02":"res://images/stations/mine01_icon.png"}
const stations_prod = {
"Planet1/Solar01":{"energy_cells":400},
"Planet1/Solar02":{"energy_cells":400},
"Planet1/Solar03":{"energy_cells":130},
"Planet1/Solar04":{"energy_cells":400},
"Planet1/Farm01":{"food":80,"oxygen":50,"textiles":25},
"Planet1/Farm02":{"food":240,"oxygen":150,"textiels":80},
"Planet2/Solar01":{"energy_cells":400},
"Planet2/Solar02":{"energy_cells":400},
"Planet2/Farm01":{"food":240,"oxygen":150,"textiels":80},
"Planet2/Farm02":{"food":240,"oxygen":150,"textiels":80},
"Planet2/Farm03":{"food":72,"oxygen":60,"textiles":25},
"Planet2/Farm04":{"food":72,"oxygen":60,"textiles":25},
"Planet3/Shipyard":{},
"Planet3/Station01":{"food":500,"metal":350,"energy_cells":500,"electronics":600,"luxury_goods":250,"chemicals":250,"radioactives":200,"oxygen":500,"textiles":400,"medicine":250},
"Planet3/Station02":{"electronics":100,"luxury_goods":100,"medicine":250},
"Planet3/Solar01":{"energy_cells":130},
"Planet4/Station01":{"food":110,"metal":600,"electronics":100,"luxury_goods":60,"chemicals":200,"radioactives":300,"medicine":200},
"Planet4/Farm01":{"food":250,"oxygen":150,"textiels":80},
"Planet4/Solar01":{"energy_cells":400},
"Planet4/Mine01":{"metal":250,"radioactives":30},
"Planet4/Mine02":{"metal":250,"radioactives":30},
"Planet5/Mine01":{"metal":500,"radioactives":75},
"Planet5/Refinery01":{"chemicals":350,"oxygen":150},
"Planet5/Refinery02":{"chemicals":350,"oxygen":150},
"Planet6/Station01":{"food":250,"metal":600,"energy_cells":500,"electronics":400,"luxury_goods":200,"chemicals":200,"radioactives":100,"oxygen":100,"textiles":250,"medicine":400},
"Planet6/Refinery01":{"chemicals":350,"oxygen":150},
"Planet6/Refinery02":{"chemicals":350,"oxygen":150},
"Planet6/Farm01":{"food":80,"oxygen":50,"textiles":25},
"Planet6/Farm02":{"food":80,"oxygen":50,"textiles":25},
"Planet6/Solar01":{"energy_cells":400},
"Planet7/Refinery01":{"chemicals":350,"oxygen":150},
"Planet7/Mine01":{"metal":500,"radioactives":75},
"Planet7/Solar01":{"energy_cells":130},
"Planet7/Solar02":{"energy_cells":400},
"Planet8/Mine01":{"metal":250,"radioactives":30},
"Planet8/Mine02":{"metal":250,"radioactives":30}
}
const stations_cons = {
"Planet1/Solar01":{"food":36,"metal":200,"chemicals":150,"oxygen":24,"textiles":12,"medicine":6},
"Planet1/Solar02":{"food":36,"metal":200,"chemicals":150,"oxygen":24,"textiles":12,"medicine":6},
"Planet1/Solar03":{"food":18,"metal":66,"chemicals":50,"oxygen":12,"textiles":6,"medicine":3},
"Planet1/Solar04":{"food":36,"metal":200,"chemicals":150,"oxygen":24,"textiles":12,"medicine":6},
"Planet1/Farm01":{"food":18,"energy_cells":75,"oxygen":12,"textiles":6,"medicine":3},
"Planet1/Farm02":{"food":36,"energy_cells":225,"oxygen":24,"textiles":12,"medicine":6},
"Planet2/Solar01":{"food":36,"metal":200,"chemicals":150,"oxygen":24,"textiles":12,"medicine":6},
"Planet2/Solar02":{"food":36,"metal":200,"chemicals":150,"oxygen":24,"textiles":12,"medicine":6},
"Planet2/Farm01":{"food":36,"energy_cells":225,"oxygen":24,"textiles":12,"medicine":6},
"Planet2/Farm02":{"food":36,"energy_cells":225,"oxygen":24,"textiles":12,"medicine":6},
"Planet2/Farm03":{"food":18,"energy_cells":75,"oxygen":12,"textiles":6,"medicine":3},
"Planet2/Farm04":{"food":18,"energy_cells":75,"oxygen":12,"textiles":6,"medicine":3},
"Planet3/Shipyard":{"food":144,"metal":400,"energy_cells":300,"electronics":250,"chemicals":150,"radioactives":300,"oxygen":96,"textiles":48,"medicine":24},
"Planet3/Station01":{"food":220,"metal":250,"energy_cells":100,"luxury_goods":400,"radioactives":100,"oxygen":200,"textiles":75,"medicine":100},
"Planet3/Station02":{"food":100,"metal":75,"energy_cells":200,"chemicals":100,"radioactives":25,"oxygen":36,"textiles":18,"medicine":9},
"Planet3/Solar01":{"food":18,"metal":66,"chemicals":50,"oxygen":12,"textiles":6,"medicine":3},
"Planet4/Station01":{"food":300,"metal":400,"energy_cells":200,"luxury_goods":20,"radioactives":175,"oxygen":400,"textiles":100,"medicine":300},
"Planet4/Farm01":{"food":36,"energy_cells":225,"oxygen":24,"textiles":12,"medicine":6},
"Planet4/Solar01":{"food":36,"metal":200,"chemicals":150,"oxygen":24,"textiles":12,"medicine":6},
"Planet4/Mine01":{"food":36,"energy_cells":175,"oxygen":24,"textiles":12,"medicine":6},
"Planet4/Mine02":{"food":36,"energy_cells":175,"oxygen":24,"textiles":12,"medicine":6},
"Planet5/Mine01":{"food":72,"energy_cells":355,"oxygen":48,"textiles":24,"medicine":12},
"Planet5/Refinery01":{"food":54,"energy_cells":200,"oxygen":36,"textiles":18,"medicine":9},
"Planet5/Refinery02":{"food":54,"energy_cells":200,"oxygen":36,"textiles":18,"medicine":9},
"Planet6/Station01":{"food":250,"metal":500,"energy_cells":300,"luxury_goods":400,"radioactives":300,"oxygen":200,"textiles":50,"medicine":100},
"Planet6/Refinery01":{"food":54,"energy_cells":200,"oxygen":36,"textiles":18,"medicine":9},
"Planet6/Refinery02":{"food":54,"energy_cells":200,"oxygen":36,"textiles":18,"medicine":9},
"Planet6/Farm01":{"food":18,"energy_cells":75,"oxygen":12,"textiles":6,"medicine":3},
"Planet6/Farm02":{"food":18,"energy_cells":75,"oxygen":12,"textiles":6,"medicine":3},
"Planet6/Solar01":{"food":36,"metal":200,"chemicals":150,"oxygen":24,"textiles":12,"medicine":6},
"Planet7/Refinery01":{"food":54,"energy_cells":200,"oxygen":36,"textiles":18,"medicine":9},
"Planet7/Mine01":{"food":36,"energy_cells":175,"oxygen":24,"textiles":12,"medicine":6},
"Planet7/Solar01":{"food":18,"metal":66,"chemicals":50,"oxygen":12,"textiles":6,"medicine":3},
"Planet7/Solar02":{"food":36,"metal":200,"chemicals":150,"oxygen":24,"textiles":12,"medicine":6},
"Planet8/Mine01":{"food":36,"energy_cells":175,"oxygen":24,"textiles":12,"medicine":6},
"Planet8/Mine02":{"food":36,"energy_cells":175,"oxygen":24,"textiles":12,"medicine":6},
}
const stations_cargo = {
"Planet1/Solar01":{"food":4000,"metal":4000,"energy_cells":8000,"chemicals":3000,"oxygen":2400,"textiles":2400,"medicine":2400},
"Planet1/Solar02":{"food":4000,"metal":4000,"energy_cells":8000,"chemicals":3000,"oxygen":2400,"textiles":2400,"medicine":2400},
"Planet1/Solar03":{"food":2000,"metal":1500,"energy_cells":4500,"chemicals":1400,"oxygen":1400,"textiles":1400,"medicine":1400},
"Planet1/Solar04":{"food":4000,"metal":4000,"energy_cells":8000,"chemicals":3000,"oxygen":2400,"textiles":2400,"medicine":2400},
"Planet1/Farm01":{"food":4500,"energy_cells":3000,"oxygen":2500,"textiles":2500,"medicine":1300},
"Planet1/Farm02":{"food":8000,"energy_cells":6000,"oxygen":4000,"textiles":4000,"medicine":3000},
"Planet2/Solar01":{"food":4000,"metal":4000,"energy_cells":8000,"chemicals":3000,"oxygen":2400,"textiles":2400,"medicine":2400},
"Planet2/Solar02":{"food":4000,"metal":4000,"energy_cells":8000,"chemicals":3000,"oxygen":2400,"textiles":2400,"medicine":2400},
"Planet2/Farm01":{"food":8000,"energy_cells":6000,"oxygen":4000,"textiles":4000,"medicine":3000},
"Planet2/Farm02":{"food":8000,"energy_cells":6000,"oxygen":4000,"textiles":4000,"medicine":3000},
"Planet2/Farm03":{"food":4500,"energy_cells":3000,"oxygen":2500,"textiles":2500,"medicine":1300},
"Planet2/Farm04":{"food":4500,"energy_cells":3000,"oxygen":2500,"textiles":2500,"medicine":1300},
"Planet3/Shipyard":{"food":10000,"metal":10000,"energy_cells":10000,"electronics":10000,"chemicals":10000,"radioactives":10000,"oxygen":6000,"textiles":5000,"medicine":5000},
"Planet3/Station01":{"food":15000,"metal":15000,"energy_cells":15000,"electronics":15000,"luxury_goods":10000,"chemicals":15000,"radioactives":10000,"oxygen":15000,"textiles":15000,"medicine":15000},
"Planet3/Station02":{"food":2300,"metal":2000,"energy_cells":4000,"electronics":8000,"luxury_goods":2500,"chemicals":4000,"radioactives":2000,"oxygen":2600,"textiles":2600,"medicine":2600},
"Planet3/Solar01":{"food":2000,"metal":1500,"energy_cells":4500,"chemicals":1400,"oxygen":1400,"textiles":1400,"medicine":1400},
"Planet4/Station01":{"food":9000,"metal":15000,"energy_cells":9000,"electronics":15000,"luxury_goods":11000,"chemicals":15000,"radioactives":13000,"chemicals":9000,"oxygen":9000,"textiles":9000,"medicine":10000},
"Planet4/Farm01":{"food":8000,"energy_cells":6000,"oxygen":4000,"textiles":4000,"medicine":3000},
"Planet4/Solar01":{"food":4000,"metal":4000,"energy_cells":8000,"chemicals":3000,"oxygen":2400,"textiles":2400,"medicine":2400},
"Planet4/Mine01":{"food":4000,"metal":8000,"energy_cells":4000,"radioactives":3000,"oxygen":2400,"textiles":2400,"medicine":2400},
"Planet4/Mine02":{"food":4000,"metal":8000,"energy_cells":4000,"radioactives":3000,"oxygen":2400,"textiles":2400,"medicine":2400},
"Planet5/Mine01":{"food":4000,"metal":8000,"energy_cells":4000,"radioactives":3000,"oxygen":2400,"textiles":2400,"medicine":2400},
"Planet5/Refinery01":{"food":3000,"energy_cells":3500,"chemicals":5500,"oxygen":6000,"textiles":2000,"medicine":2000},
"Planet5/Refinery02":{"food":3000,"energy_cells":3500,"chemicals":5500,"oxygen":6000,"textiles":2000,"medicine":2000},
"Planet6/Station01":{"food":10000,"metal":15000,"energy_cells":10000,"electronics":15000,"luxury_goods":10000,"chemicals":15000,"radioactives":10000,"oxygen":10000,"textiles":12000,"medicine":15000},
"Planet6/Refinery01":{"food":3000,"energy_cells":3500,"chemicals":5500,"oxygen":6000,"textiles":2000,"medicine":2000},
"Planet6/Refinery02":{"food":3000,"energy_cells":3500,"chemicals":5500,"oxygen":6000,"textiles":2000,"medicine":2000},
"Planet6/Farm01":{"food":4500,"energy_cells":3000,"oxygen":2500,"textiles":2500,"medicine":1300},
"Planet6/Farm02":{"food":4500,"energy_cells":3000,"oxygen":2500,"textiles":2500,"medicine":1300},
"Planet6/Solar01":{"food":4000,"metal":4000,"energy_cells":8000,"chemicals":3000,"oxygen":2400,"textiles":2400,"medicine":2400},
"Planet7/Refinery01":{"food":3000,"energy_cells":3500,"chemicals":5500,"oxygen":6000,"textiles":2000,"medicine":2000},
"Planet7/Mine01":{"food":4000,"metal":8000,"energy_cells":4000,"radioactives":3000,"oxygen":2400,"textiles":2400,"medicine":2400},
"Planet7/Solar01":{"food":2000,"metal":1500,"energy_cells":4500,"chemicals":1400,"oxygen":1400,"textiles":1400,"medicine":1400},
"Planet7/Solar02":{"food":4000,"metal":4000,"energy_cells":8000,"chemicals":3000,"oxygen":2400,"textiles":2400,"medicine":2400},
"Planet8/Mine01":{"food":4000,"metal":8000,"energy_cells":4000,"radioactives":3000,"oxygen":2400,"textiles":2400,"medicine":2400},
"Planet8/Mine02":{"food":4000,"metal":8000,"energy_cells":4000,"radioactives":3000,"oxygen":2400,"textiles":2400,"medicine":2400},
}
const stations_comm = {
"Planet1/Solar01":{"metal":1484,"energy_cells":7488,"medicine":1661,"food":2465,"chemicals":1552,"textiles":1518,"oxygen":1678},
"Planet1/Solar02":{"metal":1515,"energy_cells":7423,"medicine":1654,"food":2627,"chemicals":1526,"textiles":1433,"oxygen":1616},
"Planet1/Solar03":{"metal":593,"energy_cells":3868,"medicine":910,"food":1622,"chemicals":720,"oxygen":1000,"textiles":871},
"Planet1/Solar04":{"metal":1519,"energy_cells":7780,"medicine":1612,"food":2511,"chemicals":1556,"oxygen":1746,"textiles":1623},
"Planet1/Farm01":{"energy_cells":3000,"medicine":872,"food":2480,"textiles":1204,"oxygen":1567},
"Planet1/Farm02":{"energy_cells":6000,"medicine":1956,"food":4780,"textiles":2392,"oxygen":2441},
"Planet2/Solar01":{"metal":1670,"energy_cells":3604,"medicine":1277,"food":2594,"chemicals":847,"textiles":1344,"oxygen":1570},
"Planet2/Solar02":{"metal":1777,"energy_cells":3723,"medicine":1283,"food":2643,"chemicals":874,"textiles":1072,"oxygen":1587},
"Planet2/Farm01":{"energy_cells":3497,"medicine":1603,"food":4445,"oxygen":2304,"textiles":2357},
"Planet2/Farm02":{"energy_cells":3669,"medicine":1610,"food":5095,"oxygen":2369,"textiles":2356},
"Planet2/Farm03":{"energy_cells":1726,"medicine":783,"food":2924,"oxygen":1495,"textiles":1151},
"Planet2/Farm04":{"energy_cells":1688,"medicine":777,"food":2633,"oxygen":1472,"textiles":1204},
"Planet3/Station01":{"electronics":11663,"metal":5475,"energy_cells":4771,"luxury_goods":4307,"medicine":8876,"radioactives":4364,"food":7411,"chemicals":7155,"oxygen":9744,"textiles":8506},
"Planet3/Station02":{"electronics":6240,"metal":849,"energy_cells":1577,"luxury_goods":1064,"medicine":1249,"radioactives":1013,"food":1357,"chemicals":2442,"oxygen":1813,"textiles":1557},
"Planet3/Shipyard":{"electronics":8347,"metal":4227,"energy_cells":3423,"radioactives":4945,"medicine":3098,"food":5897,"chemicals":4927,"textiles":2792,"oxygen":3826},
"Planet3/Solar01":{"metal":776,"energy_cells":1180,"medicine":957,"food":1317,"chemicals":784,"textiles":877,"oxygen":977},
"Planet4/Station01":{"electronics":10298,"metal":9391,"energy_cells":4522,"luxury_goods":4643,"radioactives":8586,"medicine":3328,"food":4685,"chemicals":6604,"textiles":3922,"oxygen":4777},
"Planet4/Solar01":{"metal":2626,"energy_cells":3046,"medicine":1264,"food":2386,"chemicals":1937,"textiles":1023,"oxygen":1454},
"Planet4/Farm01":{"energy_cells":2545,"medicine":1584,"food":4731,"textiles":2303,"oxygen":1703},
"Planet4/Mine01":{"metal":4870,"energy_cells":1870,"medicine":1259,"radioactives":1963,"food":2332,"oxygen":1465,"textiles":1024},
"Planet4/Mine02":{"metal":4469,"energy_cells":1660,"radioactives":1958,"medicine":1264,"food":2324,"textiles":1020,"oxygen":1452},
"Planet5/Mine01":{"metal":2764,"energy_cells":531,"radioactives":1589,"medicine":1476,"food":2063,"textiles":1142,"oxygen":1714},
"Planet5/Refinery01":{"energy_cells":1075,"medicine":1238,"food":1601,"chemicals":3900,"oxygen":4164,"textiles":958},
"Planet5/Refinery02":{"energy_cells":1085,"medicine":1242,"food":1578,"chemicals":3871,"oxygen":3833,"textiles":950},
"Planet6/Station01":{"metal":6800,"electronics":12402,"luxury_goods":2626,"energy_cells":5088,"radioactives":2988,"medicine":9366,"food":5852,"chemicals":13391,"textiles":7449,"oxygen":6425},
"Planet6/Solar01":{"metal":2028,"energy_cells":3313,"medicine":1674,"food":2519,"chemicals":2905,"oxygen":1558,"textiles":1593},
"Planet6/Farm01":{"energy_cells":1617,"medicine":907,"food":2731,"textiles":1448,"oxygen":1498},
"Planet6/Farm02":{"energy_cells":1641,"medicine":891,"food":2529,"oxygen":1402,"textiles":1596},
"Planet6/Refinery01":{"energy_cells":2004,"medicine":1341,"food":1941,"chemicals":4049,"textiles":1477,"oxygen":4040},
"Planet6/Refinery02":{"energy_cells":2098,"medicine":1341,"food":1667,"chemicals":4055,"oxygen":3488,"textiles":1331},
"Planet7/Solar01":{"metal":1082,"energy_cells":2708,"medicine":523,"food":718,"chemicals":1226,"oxygen":894,"textiles":591},
"Planet7/Solar02":{"metal":2106,"energy_cells":5103,"medicine":866,"food":1191,"chemicals":2568,"textiles":917,"oxygen":1447},
"Planet7/Mine01":{"metal":5000,"energy_cells":3175,"radioactives":2796,"medicine":866,"food":1182,"textiles":917,"oxygen":1447},
"Planet7/Refinery01":{"energy_cells":2899,"medicine":796,"food":1000,"chemicals":4000,"textiles":677,"oxygen":3292},
"Planet8/Mine01":{"metal":6433,"energy_cells":0,"medicine":454,"radioactives":2384,"food":1056,"oxygen":856,"textiles":817},
"Planet8/Mine02":{"metal":6435,"energy_cells":0,"radioactives":2384,"medicine":456,"food":1056,"textiles":916,"oxygen":812}
}
const stations_ballance = {
"Planet1/Solar01":0,
"Planet1/Solar02":0,
"Planet1/Solar03":0,
"Planet1/Solar04":0,
"Planet1/Farm01":0,
"Planet1/Farm02":0,
"Planet2/Solar01":0,
"Planet2/Solar02":0,
"Planet2/Farm01":0,
"Planet2/Farm02":0,
"Planet2/Farm03":0,
"Planet2/Farm04":0,
"Planet3/Shipyard":0,
"Planet3/Station01":500,
"Planet3/Station02":0,
"Planet3/Solar01":0,
"Planet4/Station01":200,
"Planet4/Farm01":0,
"Planet4/Solar01":0,
"Planet4/Mine01":0,
"Planet4/Mine02":0,
"Planet5/Mine01":0,
"Planet5/Refinery01":0,
"Planet5/Refinery02":0,
"Planet6/Station01":350,
"Planet6/Refinery01":0,
"Planet6/Refinery02":0,
"Planet6/Farm01":0,
"Planet6/Farm02":0,
"Planet6/Solar01":0,
"Planet7/Refinery01":0,
"Planet7/Mine01":0,
"Planet7/Solar01":0,
"Planet7/Solar02":0,
"Planet8/Mine01":0,
"Planet8/Mine02":0
}
var stations_outfits = {
"Planet1/Solar01":[],
"Planet1/Solar02":[],
"Planet1/Solar03":[],
"Planet1/Solar04":[],
"Planet1/Farm01":[],
"Planet1/Farm02":[],
"Planet2/Solar01":[],
"Planet2/Solar02":[],
"Planet2/Farm01":[],
"Planet2/Farm02":[],
"Planet2/Farm03":[],
"Planet2/Farm04":[],
"Planet3/Shipyard":[]+Equipment.base_weapons+Equipment.good_weapons+Equipment.base_turrets+Equipment.good_turrets+Equipment.base_missiles+Equipment.good_missiles+Equipment.base_reactors+Equipment.base_engines+Equipment.good_engines+Equipment.base_internal+Equipment.base_external,
"Planet3/Station01":[]+Equipment.base_weapons+Equipment.melee_weapons+Equipment.good_weapons+Equipment.base_turrets+Equipment.good_turrets+Equipment.base_missiles+Equipment.good_missiles+Equipment.base_reactors+Equipment.base_engines+Equipment.good_engines+Equipment.base_internal+Equipment.base_external,
"Planet3/Station02":[],
"Planet3/Solar01":[],
"Planet4/Station01":[]+Equipment.base_weapons+Equipment.base_turrets+Equipment.base_missiles+Equipment.base_reactors+Equipment.base_engines+Equipment.base_internal+Equipment.base_external,
"Planet4/Farm01":[],
"Planet4/Solar01":[],
"Planet4/Mine01":[],
"Planet4/Mine02":[],
"Planet5/Mine01":[],
"Planet5/Refinery01":[],
"Planet5/Refinery02":[],
"Planet6/Station01":[]+Equipment.base_weapons+Equipment.good_weapons+Equipment.base_turrets+Equipment.good_turrets+Equipment.good_missiles+Equipment.base_missiles+Equipment.base_reactors+Equipment.base_engines+Equipment.base_internal+Equipment.base_external,
"Planet6/Refinery01":[],
"Planet6/Refinery02":[],
"Planet6/Farm01":[],
"Planet6/Farm02":[],
"Planet6/Solar01":[],
"Planet7/Refinery01":[],
"Planet7/Mine01":[],
"Planet7/Solar01":[],
"Planet7/Solar02":[],
"Planet8/Mine01":[],
"Planet8/Mine02":[]
}
var stations_ships = {
"Planet1/Solar01":[],
"Planet1/Solar02":[],
"Planet1/Solar03":[],
"Planet1/Solar04":[],
"Planet1/Farm01":[],
"Planet1/Farm02":[],
"Planet2/Solar01":[],
"Planet2/Solar02":[],
"Planet2/Farm01":[],
"Planet2/Farm02":[],
"Planet2/Farm03":[],
"Planet2/Farm04":[],
"Planet3/Shipyard":[]+Equipment.republic_ships1,
"Planet3/Station01":[]+Equipment.republic_ships1+Equipment.civil_ships1,
"Planet3/Station02":[],
"Planet3/Solar01":[],
"Planet4/Station01":[],
"Planet4/Farm01":[],
"Planet4/Solar01":[],
"Planet4/Mine01":[],
"Planet4/Mine02":[],
"Planet5/Mine01":[],
"Planet5/Refinery01":[],
"Planet5/Refinery02":[],
"Planet6/Station01":[],
"Planet6/Refinery01":[],
"Planet6/Refinery02":[],
"Planet6/Farm01":[],
"Planet6/Farm02":[],
"Planet6/Solar01":[],
"Planet7/Refinery01":[],
"Planet7/Mine01":[],
"Planet7/Solar01":[],
"Planet7/Solar02":[],
"Planet8/Mine01":[],
"Planet8/Mine02":[]
}
const stations_services = {
"Planet1/Solar01":["bar","trader","crew"],
"Planet1/Solar02":["bar","trader","crew"],
"Planet1/Solar03":["trader"],
"Planet1/Solar04":["bar","trader","crew"],
"Planet1/Farm01":["trader"],
"Planet1/Farm02":["bar","trader","crew"],
"Planet2/Solar01":["bar","trader","crew"],
"Planet2/Solar02":["bar","trader","crew"],
"Planet2/Farm01":["bar","trader","crew"],
"Planet2/Farm02":["bar","trader","crew"],
"Planet2/Farm03":["trader"],
"Planet2/Farm04":["trader"],
"Planet3/Shipyard":["trader","outfitter","shipyard","crew"],
"Planet3/Station01":["bar","trader","outfitter","shipyard","crew"],
"Planet3/Station02":["bar","trader","outfitter","crew"],
"Planet3/Solar01":["trader"],
"Planet4/Station01":["var","trader","outfitter","shipyard","crew"],
"Planet4/Farm01":["bar","trader","crew"],
"Planet4/Solar01":["bar","trader","crew"],
"Planet4/Mine01":["bar","trader"],
"Planet4/Mine02":["bar","trader"],
"Planet5/Mine01":["bar","trader"],
"Planet5/Refinery01":["bar","trader","crew"],
"Planet5/Refinery02":["bar","trader","crew"],
"Planet6/Station01":["bar","trader","outfitter","shipyard","crew"],
"Planet6/Refinery01":["bar","trader"],
"Planet6/Refinery02":["bar","trader"],
"Planet6/Farm01":["trader"],
"Planet6/Farm02":["trader"],
"Planet6/Solar01":["bar","trader","crew"],
"Planet7/Refinery01":["bar","trader","outfitter","crew"],
"Planet7/Mine01":["bar","trader"],
"Planet7/Solar01":["trader"],
"Planet7/Solar02":["bar","trader"],
"Planet8/Mine01":["bar","trader","crew"],
"Planet8/Mine02":["bar","trader","crew"]
}
const stations_name = {
"Planet1/Solar01":"",
"Planet1/Solar02":"",
"Planet1/Solar03":"",
"Planet1/Solar04":"",
"Planet1/Farm01":"",
"Planet1/Farm02":"",
"Planet2/Solar01":"",
"Planet2/Solar02":"",
"Planet2/Farm01":"",
"Planet2/Farm02":"",
"Planet2/Farm03":"",
"Planet2/Farm04":"",
"Planet3/Shipyard":"SHIPYARD",
"Planet3/Station01":"STATION01",
"Planet3/Station02":"",
"Planet3/Solar01":"",
"Planet4/Station01":"",
"Planet4/Farm01":"",
"Planet4/Solar01":"",
"Planet4/Mine01":"",
"Planet4/Mine02":"",
"Planet5/Mine01":"",
"Planet5/Refinery01":"",
"Planet5/Refinery02":"",
"Planet6/Station01":"",
"Planet6/Refinery01":"",
"Planet6/Refinery02":"",
"Planet6/Farm01":"",
"Planet6/Farm02":"",
"Planet6/Solar01":"",
"Planet7/Refinery01":"",
"Planet7/Mine01":"",
"Planet7/Solar01":"",
"Planet7/Solar02":"",
"Planet8/Mine01":"",
"Planet8/Mine02":""
}
const stations_desc = {
"Planet1/Solar01":"",
"Planet1/Solar02":"",
"Planet1/Solar03":"",
"Planet1/Solar04":"",
"Planet1/Farm01":"",
"Planet1/Farm02":"",
"Planet2/Solar01":"",
"Planet2/Solar02":"",
"Planet2/Farm01":"",
"Planet2/Farm02":"",
"Planet2/Farm03":"",
"Planet2/Farm04":"",
"Planet3/Shipyard":"SHIPYARD_DESC",
"Planet3/Station01":"STATION01_DESC",
"Planet3/Station02":"",
"Planet3/Solar01":"",
"Planet4/Station01":"",
"Planet4/Farm01":"",
"Planet4/Solar01":"",
"Planet4/Mine01":"",
"Planet4/Mine02":"",
"Planet5/Mine01":"",
"Planet5/Refinery01":"",
"Planet5/Refinery02":"",
"Planet6/Station01":"",
"Planet6/Refinery01":"",
"Planet6/Refinery02":"",
"Planet6/Farm01":"",
"Planet6/Farm02":"",
"Planet6/Solar01":"",
"Planet7/Refinery01":"",
"Planet7/Mine01":"",
"Planet7/Solar01":"",
"Planet7/Solar02":"",
"Planet8/Mine01":"",
"Planet8/Mine02":""
}
const stations_bar = {
"Planet1/Solar01":"",
"Planet1/Solar02":"",
"Planet1/Solar03":"",
"Planet1/Solar04":"",
"Planet1/Farm01":"",
"Planet1/Farm02":"",
"Planet2/Solar01":"",
"Planet2/Solar02":"",
"Planet2/Farm01":"",
"Planet2/Farm02":"",
"Planet2/Farm03":"",
"Planet2/Farm04":"",
"Planet3/Shipyard":"",
"Planet3/Station01":"STATION01_BAR",
"Planet3/Station02":"",
"Planet3/Solar01":"",
"Planet4/Station01":"",
"Planet4/Farm01":"",
"Planet4/Solar01":"",
"Planet4/Mine01":"",
"Planet4/Mine02":"",
"Planet5/Mine01":"",
"Planet5/Refinery01":"",
"Planet5/Refinery02":"",
"Planet6/Station01":"",
"Planet6/Refinery01":"",
"Planet6/Refinery02":"",
"Planet6/Farm01":"",
"Planet6/Farm02":"",
"Planet6/Solar01":"",
"Planet7/Refinery01":"",
"Planet7/Mine01":"",
"Planet7/Solar01":"",
"Planet7/Solar02":"",
"Planet8/Mine01":"",
"Planet8/Mine02":""
}
var stations_image = {
"Planet1/Solar01":"",
"Planet1/Solar02":"",
"Planet1/Solar03":"",
"Planet1/Solar04":"",
"Planet1/Farm01":"",
"Planet1/Farm02":"",
"Planet2/Solar01":"",
"Planet2/Solar02":"",
"Planet2/Farm01":"",
"Planet2/Farm02":"",
"Planet2/Farm03":"",
"Planet2/Farm04":"",
"Planet3/Shipyard":"",
"Planet3/Station01":"",
"Planet3/Station02":"",
"Planet3/Solar01":"",
"Planet4/Station01":"",
"Planet4/Farm01":"",
"Planet4/Solar01":"",
"Planet4/Mine01":"",
"Planet4/Mine02":"",
"Planet5/Mine01":"",
"Planet5/Refinery01":"",
"Planet5/Refinery02":"",
"Planet6/Station01":"",
"Planet6/Refinery01":"",
"Planet6/Refinery02":"",
"Planet6/Farm01":"",
"Planet6/Farm02":"",
"Planet6/Solar01":"",
"Planet7/Refinery01":"",
"Planet7/Mine01":"",
"Planet7/Solar01":"",
"Planet7/Solar02":"",
"Planet8/Mine01":"",
"Planet8/Mine02":""
}


# data #

var asteroids = [
load("res://scenes/asteroids/asteroid01.tscn"),load("res://scenes/asteroids/asteroid02.tscn"),
load("res://scenes/asteroids/asteroid03.tscn"),load("res://scenes/asteroids/asteroid04.tscn"),
load("res://scenes/asteroids/asteroid05.tscn"),load("res://scenes/asteroids/asteroid06.tscn"),
load("res://scenes/asteroids/asteroid07.tscn"),load("res://scenes/asteroids/asteroid08.tscn"),
load("res://scenes/asteroids/asteroid09.tscn"),load("res://scenes/asteroids/asteroid10.tscn")]


func delete_objects():
	for i in range(objects.size()-1,-1,-1):
		if (objects[i].has_method("destroyed")):
			objects[i].destroyed()
		objects[i].queue_free()
		objects.remove(i)
	for i in range(ships.size()-1,-1,-1):
		if (ships[i].has_method("destroyed")):
			ships[i].destroyed()
		ships[i].queue_free()
		ships.remove(i)
	for i in range(missiles.size()-1,-1,-1):
		if (missiles[i].has_method("destroyed")):
			missiles[i].destroyed()
		missiles[i].queue_free()
		missiles.remove(i)

func update_objects():
	remove_asteroids()
	remove_ships()
	
	yield(get_tree(),"idle_frame")
	
	add_asteroids()
	yield(get_tree(),"idle_frame")
	add_pirates()
	yield(get_tree(),"idle_frame")
	add_republic_ships()
	yield(get_tree(),"idle_frame")
	add_civil_ships()

func remove_asteroids():
	if (!has_node("Player")):
		return
	
	var pos = get_node("Player").get_global_pos()
	for a in get_node("Asteroids").get_children():
		if (pos.distance_squared_to(a.get_global_pos())>5000000000000):
			a.destroyed()
			objects.erase(a)
			a.queue_free()

func add_asteroids():
	if (!has_node("Player")):
		return
	
	var num_asteroids = randi()%40+80-get_node("Asteroids").get_child_count()
	if (num_asteroids<=0):
		return
	
	var pos = get_node("Player").get_global_pos()
	var dist = pos.length()
	if (pos.distance_squared_to(last_player_pos)>1000000 && ((dist>asteroids_inner_dist_min-25000 && dist<asteroids_inner_dist_max+25000) || (dist>asteroids_outer_dist_min-25000 && dist<asteroids_outer_dist_max+25000))):
		var dir = pos/dist
		var max_ang = 0
		if (dist<(asteroids_inner_dist_max-asteroids_outer_dist_min)/2.0):
			max_ang = asin(clamp((dist-asteroids_inner_dist_min)/20000,0,1))+PI/2.0
		else:
			max_ang = asin(clamp((asteroids_inner_dist_max-dist)/20000,0,1))+PI/2.0
			dir *= -1
		for i in range(num_asteroids):
			var d = rand_range(10000,25000)
			var p = pos+d*dir.rotated(max_ang*rand_range(-1.0,1.0))
			
			var scale = rand_range(1.0,2.0)*rand_range(0.5,1.5)*Vector2(rand_range(0.8,1.2),rand_range(0.8,1.2))
			var ai = asteroids[randi()%(asteroids.size())].instance()
			ai.set_rot(2*PI*randf())
			ai.set_angular_velocity(rand_range(-0.25,0.25))
			ai.set_linear_velocity(Vector2(128.0*randf(),0).rotated(2*PI*randf()))
			ai.set_name("Asteroid"+str(randi()))
			ai.set_pos(p)
			ai.get_node("Sprite").set_scale(0.5*scale)
			ai.set_mass(250*(scale.x+scale.y))
			get_node("Asteroids").add_child(ai)
			for i in range(ai.get_shape_count()):
				ai.set_shape_transform(i,Matrix32(0.0,Vector2(0,0)).scaled(scale))
		
		last_player_pos = pos

func remove_ships():
	if (!has_node("Player")):
		return
	
	var pos = get_node("Player").get_global_pos()
	for s in ships:
		if (pos.distance_to(s.get_global_pos())>100000):
			if (s.faction==Factions.PIRATES):
				num_pirates -= 1
			elif (s.faction==Factions.REPUBLIC):
				if (s.type=="police"):
					num_republic_police -= 1
				elif (s.type=="military"):
					num_republic_military -= 1
			elif (s.faction==Factions.CIVIL):
				num_civil_trader -= 1
			s.destroyed()
			ships.erase(s)
			s.queue_free()

func add_pirates():
	if (!has_node("Player")):
		return
	
	var pos = get_node("Player").get_global_pos()
	var dist = pos.length()
	if (dist<dist_pirate_inner || (dist>asteroids_inner_dist_min-10000 && dist<asteroids_inner_dist_max+10000) || (dist>asteroids_outer_dist_min-10000 && dist<asteroids_outer_dist_max+10000)):
		var num = min(round(rand_range(-6.0,4.5*(1+Player.difficulty))-num_pirates),2)
		if (num<=0):
			return
		
		num_pirates += num
		for i in range(num):
			var pos = get_node("Player").get_global_pos()+Vector2(rand_range(25000,40000),0).rotated(2*PI*randf())
			var p = Ships.create_rnd_pirate(pos,get_node("Player").get_lv()+(get_node("Player").get_global_pos()-pos).normalized()*rand_range(500,3000))
			p.target = get_node("Player")
			p.connect("destroyed",self,"pirate_destroyed")

func add_republic_ships():
	if (!has_node("Player")):
		return
	
	var pos = get_node("Player").get_global_pos()
	if (num_republic_police<15):
		var dist = min(get_node("Planet3/Planet").get_global_pos().distance_squared_to(pos),get_node("Planet2/Planet").get_global_pos().distance_squared_to(pos))
		if (dist<500000000):
			var num = min(15-num_republic_police,6)
			num_republic_police += num
			for i in range(num):
				var eq = republic_police_ships[randi()%(republic_police_ships.size())]
				var inventory = []
				var crew = Equipment.outfits[eq[0][Equipment.TYPE]]["bunks"]
				var pos = get_node("Player").get_global_pos()+Vector2(rand_range(25000,40000),0).rotated(2*PI*randf())
				var name = "Police Ship "+str(randi()%1000)
				var si = Ships.create_ship(eq[0][Equipment.TYPE],eq,inventory,Ships.script_republic_police,Factions.REPUBLIC,pos,2*PI*randf(),get_node("Planet3").get_lv(),name,crew)
				si.connect("destroyed",self,"republic_police_destroyed")
			
			var dist = 500000000
			var station = ""
			for s in Stations.stations:
				var dist2 = pos.distance_squared_to(get_node(s).get_global_pos())*rand_range(0.5,2.0)
				if (dist2<dist):
					station = s
					dist = dist2
			if (station!=""):
				var dock = get_node(station).request_landing_position()
				if (dock>=0):
					var eq = republic_police_ships[randi()%(republic_police_ships.size())]
					var inventory = []
					var crew = Equipment.outfits[eq[0][Equipment.TYPE]]["bunks"]
					var name = "Police Ship "+str(randi()%1000)
					var si = Stations.take_off(station,dock,eq[0][Equipment.TYPE],eq,inventory,Ships.script_republic_police,Factions.REPUBLIC,name,crew)
					si.connect("destroyed",self,"republic_police_destroyed")
					num_republic_police += 1
	
	if (num_republic_military>=10):
		return
	
	var dist = pos.length()
	if (dist<350000):
		var num = min(10-num_republic_military,8)
		if (num>0):
			var dir = pos/dist
			var max_ang = 0
			if (dist<200000):
				max_ang = asin(clamp((dist-100000)/30000,0,1))+PI/2.0
			else:
				max_ang = asin(clamp((350000-dist)/30000,0,1))+PI/2.0
				dir *= -1
			num_republic_military += num
			for i in range(num):
				var eq = republic_military_ships[randi()%(republic_military_ships.size())]
				var inventory = []
				var crew = Equipment.outfits[eq[0][Equipment.TYPE]]["bunks"]
				var p = pos+rand_range(25000,40000)*dir.rotated(max_ang*rand_range(-1.0,1.0))
#				var pos = get_node("Player").get_global_pos()+Vector2(rand_range(25000,40000),0).rotated(2*PI*randf())
				var name = "Military Ship "+str(randi()%1000)
				var p = Ships.create_ship(eq[0][Equipment.TYPE],eq,inventory,Ships.script_republic_military,Factions.REPUBLIC,p,2*PI*randf(),get_node("Planet3").get_lv(),name,crew)
				p.connect("destroyed",self,"republic_military_destroyed")

func add_civil_ships():
	if (!has_node("Player") || num_civil_trader>9):
		return
	
	var pos = get_node("Player").get_global_pos()
	var dist = 1000000000
	var target = ""
	# find a random station
	for s in Stations.stations:
		var dist2 = pos-get_node(s).get_global_pos()
		dist2 = abs(dist2.x)+abs(dist2.y)
		if (dist2<dist && randf()<0.25):
			target = s
			dist = dist2
	if (target==""):
		return
	
	var eq = civil_trader_ships[randi()%(civil_trader_ships.size())]
	var inventory = [[Economy.commodities[randi()%(Economy.commodities.size())],Equipment.outfits[eq[0][Equipment.TYPE]]["cargo_space"]]]
	var crew = Equipment.outfits[eq[0][Equipment.TYPE]]["bunks"]
	var pos = get_node("Player").get_global_pos()+Vector2(rand_range(25000,40000),0).rotated(2*PI*randf())
	var name = "Civil Trade Ship "+str(randi()%1000)
	var dir = (get_node(target).get_global_pos()-pos).normalized()
	var si = Ships.create_ship(eq[0][Equipment.TYPE],eq,inventory,Ships.script_civil_trader,Factions.CIVIL,pos,dir.angle(),dir*rand_range(500,1000),name,crew)
	si.connect("destroyed",self,"civil_trader_destroyed")
	si.station = target
	num_civil_trader += 1
	
	var dist = 5000000
	var station = ""
	for s in Stations.stations:
		var dist2 = pos.distance_squared_to(get_node(s).get_global_pos())*rand_range(0.005,0.02)
		if (dist2<dist):
			station = s
			dist = dist2
	if (station==""):
		return
	
	var dist = 1000000000
	var target = ""
	for s in Stations.stations:
		if (s!=station):
			var dist2 = pos-get_node(s).get_global_pos()
			dist2 = abs(dist2.x)+abs(dist2.y)
			if (dist2<dist || randf()<0.1):
				target = s
				dist = dist2
	if (target==""):
		return
	
	var dock = get_node(station).request_landing_position()
	if (dock<0):
		return
	
	var eq = civil_trader_ships[randi()%(civil_trader_ships.size())]
	var inventory = [[Economy.commodities[randi()%(Economy.commodities.size())],Equipment.outfits[eq[0][Equipment.TYPE]]["cargo_space"]]]
	var crew = Equipment.outfits[eq[0][Equipment.TYPE]]["bunks"]
	var name = "Civil Trade Ship "+str(randi()%1000)
	var si = Stations.take_off(station,dock,eq[0][Equipment.TYPE],eq,inventory,Ships.script_civil_trader,Factions.CIVIL,name,crew)
	si.connect("destroyed",self,"civil_trader_destroyed")
	si.station = target
	num_civil_trader += 1

func landed():
	num_pirates = 0
	num_republic_police = 0
	num_republic_military = 0

func pirate_destroyed():
	num_pirates -= 1

func republic_police_destroyed():
	num_republic_police -= 1

func republic_military_destroyed():
	num_republic_military -= 1

func civil_trader_destroyed():
	num_civil_trader -= 1


func _process(delta):
	var camera = get_node("Camera")
	
	HUD.get_node("Text2").set_text(str(OS.get_frames_per_second()))
#	HUD.get_node("Text3").clear()
#	if (has_node("Player")):
#		var player = get_node("Player")
#		HUD.get_node("Text3").add_text("equipment: "+str(player.ship_type)+", "+str(player.reactors+player.engines+player.internal+player.external+player.weapons+player.turrets+player.missiles)+"\ninventory: "+str(player.inventory)+"\nmass: "+str(player.mass)+"\nmax hp: "+str(player.hp_max)+"\nhr: "+str(player.hr)+"\nmax sp: "+str(player.sp_max)+"\nsr: "+str(player.sr)+"\nep max: "+str(player.ep_max)+"\ner: "+str(player.er)+"\nmax temp: "+str(player.temp_max)+"\nheat: "+str(player.heat)+"\nheat dissipation: "+str(player.heat_dissipation)+"\nradar range: "+str(player.radar)+"\nstealth: "+str(player.stealth)+"\nacceleration: "+str(player.la)+"\nthrust power: "+str(player.thrust_power)+"\nthrust heat: "+str(player.thrust_heat)+"\nrotation speed: "+str(player.ts)+"\nsteering power: "+str(player.steering_power)+"\nsteering heat: "+str(player.steering_heat)+"\ndamping: "+str(player.damping)+"\nimpact resistance: "+str(player.resist_impact)+"\nplasma resistance: "+str(player.resist_plasma)+"\nexplosive resistance: "+str(player.resist_explosive)+"\ncargo space: "+str(player.cargo)+"\nmin crew: "+str(player.crew_min))
#		HUD.get_node("Text3").newline()
#		HUD.get_node("Text3").newline()
#	for o in ships+objects+missiles:
#		HUD.get_node("Text3").add_text(o.get_name()+"\n")
	
	if (Player.docked):
		camera.set_pos(get_node(Player.parent).get_global_pos())
	
	get_node("Stars").set_region_rect(Rect2(0.015*camera.get_camera_pos()-OS.get_video_mode_size()*camera.get_zoom(),2*OS.get_video_mode_size()*camera.get_zoom()))
	get_node("Stars").set_pos(camera.get_camera_pos())
	get_node("Stars").set_scale(Vector2(0.6,0.6)*camera.get_zoom()+Vector2(0.2,0.2))
	get_node("BG").set_scale(Vector2(0.6,0.6)*camera.get_zoom()+Vector2(0.2,0.2))
	get_node("BG").set_pos(camera.get_camera_screen_center())
	get_node("BG/Nebula").set_pos(-0.015*camera.get_camera_screen_center())

func _ready():
	randomize()
	set_process(true)
	
	for s in stations:
		if !(s in Stations.stations):
			Stations.stations.push_back(s)
			Stations.stations_icon[s] = stations_icon[s]
			Stations.stations_prod[s] = stations_prod[s]
			Stations.stations_cons[s] = stations_cons[s]
			Stations.stations_cargo[s] = stations_cargo[s]
			Stations.stations_comm[s] = stations_comm[s]
			Stations.stations_ballance[s] = stations_ballance[s]
			Stations.stations_outfits[s] = []+stations_outfits[s]
			Stations.stations_produced_outfits[s] = stations_outfits[s]
			Stations.stations_ships[s] = []+stations_ships[s]
			Stations.stations_produced_ships[s] = stations_ships[s]
			Stations.stations_services[s] = stations_services[s]
			Stations.stations_name[s] = stations_name[s]
			Stations.stations_desc[s] = stations_desc[s]
			Stations.stations_bar[s] = stations_bar[s]
			Stations.stations_image[s] = stations_image[s]
			Stations.stations_pos[s] = get_node(s).get_global_pos()
			Stations.stations_fr[s] = 0.0
			Stations.stations_visible[s] = false
			var station_planet = s.split("/")[0]
			if (has_node(station_planet) && get_node(station_planet).has_meta("fr")):
				Stations.stations_fr[s] = get_node(station_planet).fr
		
		Stations.stations_price[s] = {}
		for c in Economy.commodities:
			Stations.stations_price[s][c] = Economy.prices[c]
	
	for s in Stations.stations:
		var icon = HUD.get_node("Map/Map/Station0").duplicate()
		icon.set_texture(load(Stations.stations_icon[s]))
		icon.set_name(s)
		HUD.get_node("Map/Map").add_child(icon)
		icon.show()
		Stations.stations_icons[s] = icon
	
	Economy.update_station_prices()
	HUD._resize()
	
	for c in Economy.commodities:
		var prod = 0
		var cons = 0
		for s in stations:
			if (stations_prod[s].has(c)):
				prod += stations_prod[s][c]
			if (stations_cons[s].has(c)):
				cons += stations_cons[s][c]
		print("total "+c+" produktion: "+str(prod))
		print("total "+c+" consumption: "+str(cons))
	HUD.get_node("Text3").hide()
