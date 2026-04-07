class_name Stock extends ColorRect

@onready var TempTracker = preload("res://temporary_tracker.tscn")

@export var slope : float = 0.5
@export var price : float = 20.0
@export var instability := 3
@export var velocity : float = 0
@export var acceleration : float = 0
@export var jerk : float = 0
@export var fair_value : float = 50.0
@export var memoryLength : int = 15


const GRAPH_SCALE := 2.2
const MAX_PRICE := 99.00
const MIN_PRICE := 5.00

var averageTick : float = 0
var pendingEvents := []
var lastTicks := []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	for i in range(memoryLength):
		lastTicks.append(0.0)
	for i in range(100):
		pendingEvents.append(0.0)

func scheduleEvent(time : int, strength : float) -> void:
	pendingEvents[time] += strength

func stockTick():
	match Globals.market:
		Globals.MarketTypes.BULLISH:
			slope = 1
		Globals.MarketTypes.BEARISH:
			slope = -1
		Globals.MarketTypes.SIDEWAYS:
			slope = 0.0
	set_position(Vector2(90.0, 47.0 - (price / GRAPH_SCALE)))
	get_children()[0].add_child(TempTracker.instantiate())
	var noise := rng.randf_range(-instability - Globals.volatility, instability + Globals.volatility)
	acceleration += noise * 0.05
	var old_price = price
	averageTick = 0
	for i in lastTicks:
		averageTick += i
	averageTick /= lastTicks.size()
	var strength = clamp(averageTick * 2.0, -1.0, 1.0)
	var neutral = Color(0.6,0.6,0.6)
	if strength > 0:
		color = neutral.lerp(Color.GREEN, strength)
	else:
		color = neutral.lerp(Color.RED, -strength)
	acceleration += pendingEvents[0]
	pendingEvents.pop_at(0)
	pendingEvents.append(0.0)
	price += averageTick / 2
	acceleration += jerk
	velocity += acceleration
	acceleration /= 1.05
	jerk /= 1.3
	price += velocity
	price += slope
	price += (fair_value - price) * 0.1
	var price_delta = price - old_price
	lastTicks.append(price_delta)
	lastTicks.pop_at(0)
	if price >= 90:
		velocity -= 1
	elif price <= 10:
		velocity += 5
	if price < MIN_PRICE:
		price = MIN_PRICE
	if price > MAX_PRICE:
		price = MAX_PRICE
	velocity /= 1.2
	if velocity < -5:
		velocity /= 2
	if velocity > 5:
		velocity /= 2
