extends Control

@onready var timer_label: Label = $PanelContainer/VBoxContainer/TimerLabel
@onready var match_label: Label = $PanelContainer/VBoxContainer/LightMatchLabel
@onready var total_label: Label = $PanelContainer/VBoxContainer/TotalLabel
@onready var pb_label: Label = $PanelContainer/VBoxContainer/PBLabel

func _process(_delta: float) -> void:
	timer_label.text = RunTimer.format_time(RunTimer.get_elapsed_time())
	
	match_label.text = "Match: " + RunTimer.format_time(RunTimer.match_split)
	
	total_label.text = "Total: " + RunTimer.format_time(RunTimer.total_time)
	
	pb_label.text = "PB: " + RunTimer.format_time(RunTimer.pb_total)
	
