
extends Node

# constants

const UNATACKABLE = 0
const NEUTRAL = 1
const PLAYER = 2
const PIRATES = 3
const REPUBLIC = 4
const ENEMY = 5
const CIVIL = 6


# variables

var is_enemy = [
[false,false,false,false,false,false,false],
[false,false,false,false,false,false,false],
[false, true,false, true,false, true,false],
[false, true, true,false, true, true, true],
[false, true,false, true,false, true,false],
[false, true, true, true, true,false,false],
[false, true,false, true,false,false,false],
]


# functions

func is_enemy(f1,f2):
	return is_enemy[f1][f2]
