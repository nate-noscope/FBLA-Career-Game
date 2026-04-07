extends Node

signal line_changed(dialogue_line)
enum MarketTypes {BULLISH, BEARISH, SIDEWAYS}
var market := MarketTypes.BULLISH
var volatility := 1.0
var current_line
var evidence1 := -1
var evidence2 := -1
var evidence_score := 0.0
var court_score := 0.0
