extends Node3D

const SPEED := 7.0
const RADIUS := 110.0

var player: CharacterBody3D
var cam: Camera3D
var ui: Control
var cam_yaw := 0.0
var stick_id := -1
var look_id := -1
var stick_origin := Vector2.ZERO
var stick_vec := Vector2.ZERO


func _ready() -> void:
	_build_world()
	_build_player()
	_build_ui()


func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	return m


func _build_world() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.5, 0.7, 0.9)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.6, 0.6, 0.6)
	env.environment = e
	add_child(env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 30, 0)
	add_child(sun)

	var ground := StaticBody3D.new()
	var gm := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(500, 500)
	gm.mesh = pm
	gm.material_override = _mat(Color(0.3, 0.3, 0.32))
	var gc := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(500, 1, 500)
	gc.shape = bs
	gc.position.y = -0.5
	ground.add_child(gm)
	ground.add_child(gc)
	add_child(ground)

	for i in 12:
		var b := StaticBody3D.new()
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		var h := randf_range(6.0, 20.0)
		bm.size = Vector3(8, h, 8)
		mi.mesh = bm
		mi.material_override = _mat(Color(randf(), randf(), randf()).lightened(0.3))
		var cs := CollisionShape3D.new()
		var bx := BoxShape3D.new()
		bx.size = bm.size
		cs.shape = bx
		b.add_child(mi)
		b.add_child(cs)
		b.position = Vector3(randf_range(-60, 60), h / 2.0, randf_range(-60, 60))
		if b.position.length() < 10.0:
			b.position.x += 20.0
		add_child(b)


func _build_player() -> void:
	player = CharacterBody3D.new()
	var body := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = 0.4
	cm.height = 1.8
	body.mesh = cm
	body.position.y = 0.9
	body.material_override = _mat(Color(0.9, 0.3, 0.2))
	var nose := MeshInstance3D.new()
	var nm := BoxMesh.new()
	nm.size = Vector3(0.2, 0.2, 0.4)
	nose.mesh = nm
	nose.position = Vector3(0, 1.4, -0.4)
	nose.material_override = _mat(Color.WHITE)
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.4
	cap.height = 1.8
	col.shape = cap
	col.position.y = 0.9
	player.add_child(body)
	player.add_child(nose)
	player.add_child(col)
	player.position = Vector3(0, 0.1, 0)
	add_child(player)

	cam = Camera3D.new()
	add_child(cam)
	cam.current = true


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	ui = Control.new()
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.draw.connect(_draw_ui)
	layer.add_child(ui)

	var lbl := Label.new()
	lbl.text = "Phase 1 OK"
	lbl.position = Vector2(30, 20)
	lbl.add_theme_font_size_override("font_size", 36)
	layer.add_child(lbl)

	add_child(layer)


func _draw_ui() -> void:
	if stick_id != -1:
		ui.draw_circle(stick_origin, RADIUS, Color(1, 1, 1, 0.15))
		ui.draw_circle(stick_origin + stick_vec * RADIUS, 45.0, Color(1, 1, 1, 0.5))


func _input(event: InputEvent) -> void:
	var half := get_viewport().get_visible_rect().size.x * 0.5
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < half and stick_id == -1:
				stick_id = event.index
				stick_origin = event.position
				stick_vec = Vector2.ZERO
			elif event.position.x >= half and look_id == -1:
				look_id = event.index
		else:
			if event.index == stick_id:
				stick_id = -1
				stick_vec = Vector2.ZERO
			elif event.index == look_id:
				look_id = -1
		ui.queue_redraw()
	elif event is InputEventScreenDrag:
		if event.index == stick_id:
			stick_vec = (event.position - stick_origin).limit_length(RADIUS) / RADIUS
		elif event.index == look_id:
			cam_yaw -= event.relative.x * 0.005
		ui.queue_redraw()


func _physics_process(delta: float) -> void:
	var input := stick_vec
	if input == Vector2.ZERO:
		input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var dir := Vector3(input.x, 0, input.y).rotated(Vector3.UP, cam_yaw)
	player.velocity.x = dir.x * SPEED
	player.velocity.z = dir.z * SPEED
	if not player.is_on_floor():
		player.velocity.y -= 25.0 * delta
	else:
		player.velocity.y = 0.0
	player.move_and_slide()

	if dir.length() > 0.1:
		player.rotation.y = lerp_angle(player.rotation.y, atan2(-dir.x, -dir.z), 12.0 * delta)

	cam.position = player.position + Vector3(0, 5, 8).rotated(Vector3.UP, cam_yaw)
	cam.look_at(player.position + Vector3(0, 1, 0))
