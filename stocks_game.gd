extends Node2D

const TYPING_SPEED = 2
const COUNTING_SPEED = 0.01

@onready var EightBallTracker = $StocksArea/StockBg1/StockTracker1
@onready var EightBallInstanceHolder = $StocksArea/StockBg1/StockTracker1/ChildHolder
@onready var EightBallPriceLabel = $"StocksArea/StockBg1/8BallPriceLabel"
@onready var EightBallSharesLabel = $"StocksArea/StockBg1/8BallSharesLabel"
@onready var HexaDeckTracker = $StocksArea/StockBg2/StockTracker2
@onready var HexaDeckInstanceHolder = $StocksArea/StockBg2/StockTracker2/ChildHolder
@onready var HexaDeckPriceLabel = $StocksArea/"StockBg2/HexaDeckPriceLabel"
@onready var HexaDeckSharesLabel = $"StocksArea/StockBg2/HexaDeckSharesLabel"
@onready var BoneApetitTracker = $StocksArea/StockBg3/StockTracker3
@onready var BoneApetitInstanceHolder = $StocksArea/StockBg3/StockTracker3/ChildHolder
@onready var BoneApetitPriceLabel = $StocksArea/"StockBg3/BoneApetitPriceLabel"
@onready var BoneApetitSharesLabel = $"StocksArea/StockBg3/BoneApetitSharesLabel"
@onready var NewsHeadlineLabel = $NewsArea/Panel2/Headline
@onready var BalanceLabel = $BalanceArea/BalanceLabel
@onready var LiquidAssetsLabel = $BalanceArea/LiquidAssetsLabel
@onready var TimeLabel = $TimeLabel
@onready var Spotlight = $Spotlight
@onready var TempTracker = preload("res://temporary_tracker.tscn")
@onready var clipboardEasing = preload("res://clipboard_easing.tres")


var EightBallShares := 0
var HexaDeckShares := 0
var BoneApetitShares := 0
var time := 0.0
var current_char := 0
var done_typing := false
var dippedBelow := false
var balanceCounting := 0.0 #unused for now, will make animation for counting balance up
var introStep := 0
var rng := RandomNumberGenerator.new()
var balance := 200.0
var liquid_balance := 0.0
var isTicking := false
var introPlaying := true
var outroPlaying := false
var newsEffect := 0.5
var gameFinished := false
var texts := ["Welcome to the miniature stock market! Here, you can be a stock broker for a day.",
"The market's going a bit crazy right now, because of the earthquake. Prices can change in a flash!",
"Here, you can see your balance, or how much money you have. Below it is the amount of money you would have if you sold all your stocks immediately.",
"To make money, BUY stocks when their prices are low and SELL them when they are high.",
"Looking at the charts for each stock can help. When a stock goes up, it usually keeps going for at least a little while and vice versa.",
"Buying stocks can be a shot in the dark, so you can check important news here and buy or sell based on that.",
"You'll get 2 minutes to try to make your client as much money as possible. Good luck!",
" "
]
var stories := ["This just in: gamers are getting tired of being exploited, sales of games priced above $40 plummets.", 
"Experts say rise in inactivity among children could increase chance to buy games. Recent bad weather across most of the Midwest motivates children to stay inside and gets them playing games.", 
"Many HexaDeck customers outraged to misleading terms regarding premiums.", 
"HexaDeck stock predicted to rise after introducing new pricing. Although short-term revenue may decrease marginally, customer satisfaction and shares will likely rise", 
"Bone Apetit treat bag found with LIVE RAT inside, customers furious.", 
"Trend of 'modern' haircuts for poodles increases interest in pets.",
"Newly introduced tariffs will increase market volatility, experts say.",
"Popular bank announces interest rate cuts, making borrowing cheaper and boosting investor confidence.",
"Economists warn the economy may be entering a recession as consumer spending slows."
]
var currentStory : int

func _ready() -> void:
	$BlackFade/AnimationPlayer.play("fade_from_black")
	playIntroStep()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click") and !isTicking and done_typing:
		introStep += 1
		playIntroStep()
	if !dippedBelow:
		if balance + liquid_balance < 50.0:
			dippedBelow = true
	if Input.is_action_just_pressed("click") and gameFinished:
		get_tree().change_scene_to_file("res://menu_screen.tscn")
	BalanceLabel.text = "$" + str(snapped(balance, 0.01))
	LiquidAssetsLabel.text = "($" + str(snapped(balance + liquid_balance, 0.01)) + ")"
	if isTicking:
		time += delta
		TimeLabel.text = str(snapped(120.0 - time, 1))
		if time >= 120.0:
			playEnding()
		liquid_balance = (EightBallShares * EightBallTracker.price) + (HexaDeckShares * HexaDeckTracker.price) + (BoneApetitShares * BoneApetitTracker.price)
	if introPlaying:
		if $IntroTextBox/Label.text == texts[introStep]:
			done_typing = true
		else:
			done_typing = false
		if !done_typing:
			$IntroTextBox/AnimationPlayer.stop()
			for i in range(TYPING_SPEED):
				if done_typing:
					return
				if texts[introStep].length() > current_char:
					$IntroTextBox/Label.text += texts[introStep][current_char]
				current_char += 1
		else:
			$IntroTextBox/AnimationPlayer.play("next_bounce")

func playIntroStep():
	$IntroTextBox/Label.text = ""
	current_char = 0
	match introStep:
		0:
			Spotlight.show()
			Spotlight.position = Vector2(2, -81)
			Spotlight.scale = Vector2(2, 1)
		1:
			pass
		2:
			Spotlight.position = Vector2(-77, -20)
		3:
			Spotlight.scale = Vector2(1, 1)
			Spotlight.position = Vector2(-27, 0)
		4:
			Spotlight.scale = Vector2(2, 1)
			Spotlight.position = Vector2(101, 53)
		5:
			Spotlight.position = Vector2(-100, 92)
		7:
			isTicking = true
			introPlaying = false
			$Spotlight.hide()
			$IntroTextBox.hide()
			$StocksArea/Timer.start()
			$NewsArea/NewsTimer.start()
			$StocksArea/StockBg1/EightBallBuy.disabled = false
			$StocksArea/StockBg1/EightBallSell.disabled = false
			$StocksArea/StockBg2/HexaDeckBuy.disabled = false
			$StocksArea/StockBg2/HexaDeckSell.disabled = false
			$StocksArea/StockBg3/BoneApetitBuy.disabled = false
			$StocksArea/StockBg3/BoneApetitSell.disabled = false

func playEnding():
	$Clipboard/AnimationPlayer.play("end_review")
	isTicking = false
	outroPlaying = true
	await get_tree().create_timer(2.0).timeout
	if balance > 200.0:
		$Clipboard/Checkbox.play("check")
	else:
		$Clipboard/Checkbox.play("cross")
	await get_tree().create_timer(2.0).timeout
	if !dippedBelow:
		$Clipboard/Checkbox2.play("check")
	else:
		$Clipboard/Checkbox2.play("cross")
	await get_tree().create_timer(2.0).timeout
	$Clipboard/Label2.text = "Final balance + stocks: $" + str(snapped(balance, 0.01))
	await get_tree().create_timer(2.0).timeout
	$Clipboard/ScoreLabel.text = "Your score: " + str(calculateScore())
	gameFinished = true

func calculateScore():
	var score := 0.0
	score += balance
	if balance > 200.0:
		score += 25
	if dippedBelow:
		score -= 75
	return snapped(score, 1)

func _on_timer_timeout() -> void:
	EightBallTracker.stockTick()
	HexaDeckTracker.stockTick()
	BoneApetitTracker.stockTick()
	EightBallPriceLabel.text = "$" + str(snapped(EightBallTracker.price, 0.01))
	HexaDeckPriceLabel.text = "$" + str(snapped(HexaDeckTracker.price, 0.01))
	BoneApetitPriceLabel.text = "$" + str(snapped(BoneApetitTracker.price, 0.01))

func _on_news_timer_timeout() -> void:
	currentStory = rng.randi_range(0, stories.size() - 1)
	NewsHeadlineLabel.text = stories[currentStory]
	match currentStory:
		0:
			EightBallTracker.scheduleEvent(rng.randi_range(10,40), rng.randf_range(-1, -3))
			EightBallTracker.fair_value -= 5
		1:
			EightBallTracker.scheduleEvent(rng.randi_range(10,40), rng.randf_range(1, 3))
		2:
			HexaDeckTracker.scheduleEvent(rng.randi_range(10,40), rng.randf_range(-1, -3))
			HexaDeckTracker.fair_value -= 10
		3:
			HexaDeckTracker.scheduleEvent(rng.randi_range(30,60), rng.randf_range(1.5, 2.5))
			HexaDeckTracker.fair_value += 15
		4:
			BoneApetitTracker.scheduleEvent(rng.randi_range(5,20), rng.randf_range(-1, -3))
		5:
			BoneApetitTracker.scheduleEvent(rng.randi_range(10,40), rng.randf_range(0, 1))
		6:
			Globals.volatility = 3
		7:
			Globals.market = Globals.MarketTypes.BULLISH
			Globals.volatility = 2
		8:
			Globals.market = Globals.MarketTypes.BEARISH
			Globals.volatility = 0.5

func _on_eight_ball_buy_pressed() -> void:
	if balance >= EightBallTracker.price:
		balance -= EightBallTracker.price
		EightBallShares += 1
		EightBallSharesLabel.text = str(EightBallShares)

func _on_eight_ball_sell_pressed() -> void:
	if EightBallShares > 0:
		balance += EightBallTracker.price
		EightBallShares -= 1
		EightBallSharesLabel.text = str(EightBallShares)


func _on_hexa_deck_buy_pressed() -> void:
	if balance >= HexaDeckTracker.price:
		balance -= HexaDeckTracker.price
		HexaDeckShares += 1
		HexaDeckSharesLabel.text = str(HexaDeckShares)


func _on_hexa_deck_sell_pressed() -> void:
	if HexaDeckShares > 0:
		balance += HexaDeckTracker.price
		HexaDeckShares -= 1
		HexaDeckSharesLabel.text = str(HexaDeckShares)


func _on_bone_apetit_buy_pressed() -> void:
	if balance >= BoneApetitTracker.price:
		balance -= BoneApetitTracker.price
		BoneApetitShares += 1
		BoneApetitSharesLabel.text = str(BoneApetitShares)


func _on_bone_apetit_sell_pressed() -> void:
	if BoneApetitShares > 0:
		balance += BoneApetitTracker.price
		BoneApetitShares -= 1
		BoneApetitSharesLabel.text = str(BoneApetitShares)
