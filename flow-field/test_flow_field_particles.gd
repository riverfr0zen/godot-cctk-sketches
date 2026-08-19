extends Node2D

const FREQ_INC := 0.01

@export var bg_color := Color("#102025")
@export var num_particles := 1000
@export var flow_field_size := Vector2(40, 30)
@export var ff_speed := 2
@export var ff_frequency := 0.05
@export var ff_curl := 1.0
@export var ff_normalize := false
@export var show_particles := true
@export var particle_color := Color.WHITE
@export var particle_size := 4.0
@export var particle_max_velocity := 2.0
var flow_field : FlowField2D
@onready var particle_ps := preload("res://addons/godot_cctk/flow_field/particle.tscn") as PackedScene
@onready var screen_size = get_viewport().get_visible_rect().size


func _ready() -> void:
    RenderingServer.set_default_clear_color(bg_color)

    flow_field = FlowField2D.new(flow_field_size)
    flow_field.set_scale_for_size(screen_size)
    flow_field.speed = ff_speed
    flow_field.frequency = ff_frequency
    flow_field.curl_tightness = ff_curl
    flow_field.normalize = ff_normalize
    $FlowFieldHud.position_center()
    $FlowFieldHud.flow_field = flow_field
    $FlowFieldHud.set_cells_prop("modulate", Color(0, 0, 1, 0.4))
    generate_particles()

func _process(delta: float) -> void:
    flow_field.update(delta)
    $FlowFieldHud.update()
    for p in get_tree().get_nodes_in_group("particles"):
        p.visible = show_particles
        p.modulate = particle_color
        p.follow(flow_field)
        p.update()
        # Prev positions are updated in the visualizer (ParticleTrails) after it's done drawing
        #p.update_previous()
        p.handle_edges(screen_size)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("common.toggle_hud"):
        $FlowFieldHud.visible = !$FlowFieldHud.visible
    if event.is_action_pressed("common.restart"):
        flow_field.reseed()
    if event.is_action_pressed("ui_up"):
        flow_field.frequency += FREQ_INC
        print("frequency: %s" % flow_field.frequency)
    if event.is_action_pressed("ui_down"):
        flow_field.frequency -= FREQ_INC
        print("frequency: %s" % flow_field.frequency)

func generate_particles():
    for i in range(num_particles):
        var pobj = particle_ps.instantiate()
        pobj.scale = Vector2(particle_size, particle_size)
        pobj.global_position = Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))
        pobj.max_velocity = particle_max_velocity
        pobj.visible = show_particles
        pobj.modulate = particle_color
        add_child(pobj)
        pobj.add_to_group("particles")
