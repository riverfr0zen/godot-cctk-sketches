extends Node2D

const FREQ_INC := 0.01

@export_enum(
    "None", "Defaults", "Bramble", "BattyBowties", "CherryBlossom", "DarkJungle", 
    "ForRumplestiltskin", "GreenChillies", "MouseDroppings", "Stalactititites",
    "RoseMilk", 
) var preset := "None"
@export var bg_color := Color.WHITE
@export var num_particles := 1000
@export var flow_field_size := Vector2(40, 30)
@export var ff_vector_mod := Vector2.ONE
@export var ff_speed := 2
@export var ff_frequency := 0.05
@export var ff_curl := 1.0
@export var ff_normalize := false
@export var show_particles := true
@export var particle_color := Color.WHITE
@export var particle_size := 2.0
@export var particle_max_velocity := 2.0
## Can be used to modify the force applied to the particle. 
## NOTE: particle velocity will never exceed `particle_max_velocity`
@export var particle_force_modifier := Vector2.ONE
var flow_field : FlowField2D
var active_preset := preset
@onready var trails_viz := $VisualizerViewport/ParticleTrails
@onready var particle_ps := preload("res://addons/godot_cctk/flow_field/particle.tscn") as PackedScene
@onready var screen_size = get_viewport().get_visible_rect().size


func _ready() -> void:
    init_sketch_from_settings()

func _process(delta: float) -> void:
    if active_preset != preset:
        update_preset()

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

func init_sketch_from_settings():
    $VisualizerViewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
    RenderingServer.set_default_clear_color(bg_color)
    flow_field = FlowField2D.new(flow_field_size)
    flow_field.set_scale_for_size(screen_size)
    flow_field.speed = ff_speed
    flow_field.frequency = ff_frequency
    flow_field.curl_tightness = ff_curl
    flow_field.vector_modifier = ff_vector_mod
    flow_field.normalize = ff_normalize
    $FlowFieldHud.position_center()
    $FlowFieldHud.flow_field = flow_field
    $FlowFieldHud.set_cells_prop("modulate", Color(0, 0, 1, 0.4))
    clear_particles()
    generate_particles()

func clear_particles():
    for p in get_tree().get_nodes_in_group("particles"):
        remove_child(p)
        p.queue_free()

func generate_particles():
    for i in range(num_particles):
        var pobj = particle_ps.instantiate()
        pobj.scale = Vector2(particle_size, particle_size)
        pobj.global_position = Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))
        pobj.max_velocity = particle_max_velocity
        pobj.force_modifier = particle_force_modifier
        pobj.visible = show_particles
        pobj.modulate = particle_color
        add_child(pobj)
        pobj.add_to_group("particles")
        

func update_preset():
    if preset != "None":
        Utils.reset_defaults(self, ["preset", "show_particles"])
        Utils.reset_defaults(trails_viz)

    if preset == "Defaults":
        init_sketch_from_settings()
        trails_viz.init_from_settings()
    if preset == "Bramble":
        num_particles = 500
        bg_color = Color("80c563ff")
        ff_frequency = 0.2
        ff_curl = 0.5
        ff_normalize = true
        init_sketch_from_settings()
        trails_viz.trail_color_1 = Color("f5d7c3")
        trails_viz.trail_color_2 = Color("583300")
        trails_viz.trail_min_width = 2.0
        trails_viz.trail_max_width = 10.0
        trails_viz.trail_shrink_duration = 2.0
        trails_viz.trail_bloat_duration = 5.0
        trails_viz.init_from_settings()
    if preset == "BattyBowties":
        num_particles = 40
        bg_color = Color("1254ff")
        ff_frequency = 0.03
        ff_curl = 0.6
        ff_vector_mod = Vector2(1.0, 0.5)
        particle_max_velocity = 1.0
        init_sketch_from_settings()
        trails_viz.trail_color_1 = Color("221b12")
        trails_viz.trail_color_2 = Color("be97fe")
        trails_viz.trail_clr_2_duration = 1.0
        trails_viz.trail_clr_2_duration = 1.0
        trails_viz.trail_min_width = 30.0
        trails_viz.trail_max_width = 5.0
        trails_viz.trail_shrink_duration = 0.2
        trails_viz.trail_bloat_duration = 0.2
        trails_viz.trail_delay = 3.0
        trails_viz.init_from_settings()
    if preset == "CherryBlossom":
        bg_color = Color("ffffff")
        ff_curl = 2.5
        particle_max_velocity = 0.2
        init_sketch_from_settings()
        trails_viz.trail_color_1 = Color("e3d2de")
        trails_viz.trail_color_2 = Color("af4451")
        trails_viz.trail_max_width = 30.0
        trails_viz.trail_shrink_duration = 1.0
        trails_viz.trail_bloat_duration = 5.0
        trails_viz.init_from_settings()
    if preset == "DarkJungle":
        bg_color = Color("808865")
        ff_vector_mod = Vector2(0.1, 2.0)
        ff_frequency = 0.08
        init_sketch_from_settings()
        trails_viz.trail_color_1 = Color("86b259")
        trails_viz.trail_color_2 = Color("190f03")
        trails_viz.trail_max_width = 20.0
        trails_viz.trail_bloat_duration = 5.0
        trails_viz.trail_delay = 0.4
        trails_viz.init_from_settings()
    if preset == "ForRumplestiltskin":
        bg_color = Color("c6ccbe")
        ff_frequency = 0.1
        ff_curl = 0.3
        ff_normalize = true
        particle_max_velocity = 5.0
        init_sketch_from_settings()
        trails_viz.trail_color_1 = Color("edd9a0")
        trails_viz.trail_color_2 = Color("836a0f")
        trails_viz.trail_min_width = 0.5
        trails_viz.trail_max_width = 1.0
        trails_viz.trail_shrink_duration = 1.0
        trails_viz.trail_bloat_duration = 5.0
        trails_viz.init_from_settings()
    if preset == "GreenChillies":
        bg_color = Color("ae7f2f")
        flow_field_size = Vector2(16, 8)
        ff_frequency = 0.03
        ff_curl = 0.6
        particle_max_velocity = 0.15
        init_sketch_from_settings()
        trails_viz.trail_color_1 = Color("96ee40")
        trails_viz.trail_color_2 = Color("1a491a")
        trails_viz.trail_clr_1_duration = 15.0
        trails_viz.trail_clr_2_duration = 9.0
        trails_viz.trail_min_width = 0.5
        trails_viz.trail_max_width = 20.0
        trails_viz.trail_shrink_duration = 10.0
        trails_viz.trail_delay = 2.0
        trails_viz.init_from_settings()
    if preset == "MouseDroppings":
        bg_color = Color("f7dae1")
        num_particles = 500
        flow_field_size = Vector2(80, 60)
        ff_curl = 2.5
        ff_normalize = true
        particle_max_velocity = 0.5
        init_sketch_from_settings()
        #trails_viz.trail_color_1 = Color("d2edff")
        #trails_viz.trail_color_2 = Color("6f6cec")
        trails_viz.trail_min_width = 1.0
        trails_viz.trail_max_width = 2.0
        trails_viz.trail_shrink_duration = 0.1
        trails_viz.trail_bloat_duration = 0.1
        trails_viz.trail_delay = 2.0
        trails_viz.init_from_settings()
    if preset == "Stalactititites":
        bg_color = Color("0e1717")
        flow_field_size = Vector2(80, 60)
        ff_speed = 1
        ff_curl = 0.4
        particle_max_velocity = 0.2
        init_sketch_from_settings()
        trails_viz.trail_color_1 = Color("d2edff")
        trails_viz.trail_color_2 = Color("6f6cec")
        trails_viz.trail_min_width = 1.0
        trails_viz.trail_max_width = 20.0
        trails_viz.trail_shrink_duration = 1.0
        trails_viz.trail_bloat_duration = 5.0
        trails_viz.init_from_settings()
    if preset == "RoseMilk":
        bg_color = Color("ffffff")
        ff_speed = 10
        ff_frequency = 0.01
        ff_curl = 0.4
        particle_max_velocity = 5
        init_sketch_from_settings()
        trails_viz.trail_color_1 = Color("e3d2de")
        trails_viz.trail_color_2 = Color("bb363eff")
        trails_viz.trail_clr_1_duration = 2.0
        trails_viz.trail_max_width = 20.0
        trails_viz.trail_shrink_duration = 3.0
        trails_viz.trail_bloat_duration = 5.0
        trails_viz.init_from_settings()


    active_preset = preset
