extends Node

signal run_started
signal match_recorded(time: float)
signal run_finished(total_time: float)

const SAVE_PATH := "user://timesplits.cfg"

enum RunState { IDLE, RUNNING, MATCH_LIT, FINISHED }
var state := RunState.IDLE

var start_time := 0.0

# Current run
var match_split := -1.0
var total_time := -1.0

# Personal best
var pb_total := -1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_pb()
	start_run()
	
func now() -> float:
	return Time.get_ticks_usec() / 1000000.0
	
func start_run() -> void:
	match_split = -1.0
	total_time = -1.0
	
	start_time = now()
	state = RunState.RUNNING
	
	run_started.emit()

func reset_run() -> void:
	start_run()

func get_elapsed_time() -> float:
	match state:
		RunState.RUNNING, RunState.MATCH_LIT:
			return now() - start_time
		RunState.FINISHED:
			return total_time
		_:
			return 0.0

func match_lit() -> void:
	if state != RunState.RUNNING:
		return
		
	match_split = now() - start_time
	state = RunState.MATCH_LIT
	
	print("Match split: ", format_time(match_split))
	match_recorded.emit(match_split)

func cigarette_lit() -> void:
	if state != RunState.MATCH_LIT:
		return
		
	total_time = now() - start_time
	state = RunState.FINISHED
	
	# pb not initialized or better time seen
	if pb_total < 0.0 or total_time < pb_total:
		pb_total = total_time
		save_pb()
		
	print("Total time: ", format_time(total_time))
	print("Personal best: ", format_time(pb_total))
	run_finished.emit(total_time)
	
func save_pb() -> void:
	var config := ConfigFile.new()
	config.set_value("records", "total", pb_total)
	
	var error := config.save(SAVE_PATH)
	if error != OK:
		push_error("Failed to save PB: " + str(error))
		
func load_pb() -> void:
	var config := ConfigFile.new()
	
	if config.load(SAVE_PATH) != OK:
		return
		
	pb_total = float(config.get_value("records", "total", -1.0))
	
func reset_pb() -> void:
	pb_total = -1.0
	save_pb()
	
static func format_time(seconds: float) -> String:
	if seconds < 0.0:
		return "--:--.---"
		
	var milliseconds := int(round(seconds * 1000.0))
	var minutes := milliseconds / 60000
	var remaining_seconds := (milliseconds / 1000) % 60
	var remaining_ms := milliseconds % 1000
	
	return "%02d:%02d.%03d" % [minutes, remaining_seconds, remaining_ms]
	
