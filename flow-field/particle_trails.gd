extends Node2D

@export var trail_color_1 := Color(0.5, 0.9, 0.5, 1)
@export var trail_color_2 := Color(0.2, 0.5, 0.2, 1)
@export var trail_min_width := 0.1
@export var trail_max_width := 4.0
@export var trail_shrink_duration := 1.0
@export var trail_bloat_duration := 1.0
var trail_width : float
var trail_color : Color
var tween_size : Tween
var tween_color : Tween

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

    if tween_color:
        tween_color.kill()
    tween_color = create_tween().set_loops()
    tween_color.tween_property(self, "trail_color", trail_color_2, 10.0)
    tween_color.tween_property(self, "trail_color", trail_color_1, 10.0)

    
func _draw() -> void:
    for p in get_tree().get_nodes_in_group("particles"):
        draw_line(to_local(p.previous_global_position), to_local(p.global_position), trail_color, trail_width)
        p.update_previous()
