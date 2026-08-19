extends Node2D

@export var trail_color_1 := Color(1.0, 0.9, 0.9, 1)
@export var trail_color_2 := Color(0.5, 0.1, 0.1, 1)
@export var trail_min_width := 0.1
@export var trail_max_width := 4.0
@export var trail_shrink_duration := 0.5
@export var trail_bloat_duration := 0.5
var trail_width := trail_min_width
var trail_color := trail_color_1

func _ready() -> void:
    var tween = create_tween().set_loops()
    tween.tween_property(self, "trail_width", trail_max_width, trail_bloat_duration)
    tween.tween_property(self, "trail_width", trail_min_width, trail_shrink_duration)

    var color_tween = create_tween().set_loops()
    color_tween.tween_property(self, "trail_color", trail_color_2, 10.0)
    color_tween.tween_property(self, "trail_color", trail_color_1, 10.0)


func _process(_delta: float) -> void:
    queue_redraw()
    
func _draw() -> void:
    for p in get_tree().get_nodes_in_group("particles"):
        draw_line(to_local(p.previous_global_position), to_local(p.global_position), trail_color, trail_width)
        p.update_previous()
