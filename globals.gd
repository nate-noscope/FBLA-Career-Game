extends Node

signal line_changed(dialogue_line)
enum MarketTypes {BULLISH, BEARISH, SIDEWAYS}
var market := MarketTypes.BULLISH
var volatility := 1.0
var current_line
