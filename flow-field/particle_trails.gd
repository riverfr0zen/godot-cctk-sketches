extends Node2D

const TWEEN_SHRINK_IDX = 1
const TWEEN_INTERVAL_IDX = 2

@export var trail_color_1 := Color("801180")
@export var trail_color_2 := Color("e9ca34ff")
@export var trail_clr_1_duration := 10.0
@export var trail_clr_2_duration := 10.0
@export var trail_min_width := 0.1
@export var trail_max_width := 4.0
@export var trail_shrink_duration := 1.0
@export var trail_bloat_duration := 1.0
## If set, causes a delay in the trail size tween loop. During the delay, the
## trail is not drawn.
@export var trail_delay := 0
var trail_width : float
var trail_color : Color
var tween_size : Tween
var tween_color : Tween
var pause_trail := false


func _ready() -> void:
    init_from_settings()


func _process(_delta: float) -> void:
    queue_redraw()

func init_from_settings():
    trail_width = trail_min_width
    trail_color = trail_color_1
    if tween_size:
        tween_size.kill()
    tween_size = create_tween().set_loops()
    tween_size.tween_property(self, "trail_width", trail_max_width, trail_bloat_duration)
    tween_size.tween_property(self, "trail_width", trail_min_width, trail_shrink_duration)
    if trail_delay > 0:
        tween_size.tween_interval(trail_delay)
    tween_size.step_finished.connect(_on_tween_size_step_finished)

    if tween_color:
        tween_color.kill()
    tween_color = create_tween().set_loops()
    tween_color.tween_property(self, "trail_color", trail_color_2, trail_clr_2_duration)
    tween_color.tween_property(self, "trail_color", trail_color_1, trail_clr_1_duration)

    
func _draw() -> void:
    for p in get_tree().get_nodes_in_group("particles"):
        if !pause_trail:
            draw_line(to_local(p.previous_global_position), to_local(p.global_position), trail_color, trail_width)
        p.update_previous()

func _on_tween_size_step_finished(idx: int):
    if trail_delay > 0:
        if idx == TWEEN_SHRINK_IDX:
            pause_trail = true
            #print("paused")
        if idx == TWEEN_INTERVAL_IDX:
            pause_trail = false
            #print("resumed")
    #print("finished step %s" % idx)
