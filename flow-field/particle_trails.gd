extends Node2D

@export var trail_color := Color("872f4233")
@export var trail_min_width := 0.1
@export var trail_max_width := 4.0
@export var trail_shrink_duration := 0.5
@export var trail_bloat_duration := 0.5
var trail_width := trail_min_width

func _ready() -> void:
    var tween = create_tween().set_loops()
    tween.tween_property(self, "trail_width", 1.0, trail_bloat_duration)
    tween.tween_property(self, "trail_width", 0.1, trail_shrink_duration)


func _process(_delta: float) -> void:
    queue_redraw()
    
func _draw() -> void:
    for p in get_tree().get_nodes_in_group("particles"):
        draw_line(to_local(p.previous_global_position), to_local(p.global_position), trail_color, trail_width)
        p.update_previous()
