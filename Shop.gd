extends Control

var coins = 0
var coins_goal = 20

@onready var coin_anim = $CoinSprite

func _ready():
	coin_anim.play("Spin")

func update_coins(score: int, coins_label):
	if score >= coins_goal:
		coins += 1
		coins_goal += 20
		coins_label.text = "Coins: %d" % coins
