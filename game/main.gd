extends Node3D

const GLB_PATH := "res://game/character.glb"
const GLB_YAW := PI
const MAX_SPEED := 8.5
const JUMP_V := 9.0
const GRAVITY := 25.0
const RADIUS := 110.0
const BLOCK := 54.0

var player: CharacterBody3D
var model: Node3D
var cam: Camera3D
var ui: Control
var cam_yaw := 0.0
var cam_pitch := 0.85
var stick_id := -1
var look_id := -1
var jump_id := -1
var stick_origin := Vector2.ZERO
var stick_vec := Vector2.ZERO
var want_jump := false
var speed := 0.0
var anim_t := 0.0
var time := 0.0

var hips: Node3D
var torso: Node3D
var arm_l: Node3D
var arm_r: Node3D
var leg_l: Node3D
var leg_r: Node3D

var anim_player: AnimationPlayer
var a_idle := ""
var a_walk := ""
var a_run := ""
var a_jump := ""
var a_cur := ""


func _ready() -> void:
	_build_world()
	_build_city()
	_build_player()
	_build_ui()


func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	return m


func _box(pos: Vector3, size: Vector3, mat: Material, solid: bool) -> void:
	var bm := BoxMesh.new()
	bm.size = size
	var mi := MeshInstance3D.new()
	mi.mesh = bm
	mi.material_override = mat
	if solid:
		var sb := StaticBody3D.new()
		var cs := CollisionShape3D.new()
		var bx := BoxShape3D.new()
		bx.size = size
		cs.shape = bx
		sb.position = pos
		sb.add_child(mi)
		sb.add_child(cs)
		add_child(sb)
	else:
		mi.position = pos
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(mi)


func _build_world() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	sky.sky_material = ProceduralSkyMaterial.new()
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.ambient_light_energy = 0.6
	e.fog_enabled = true
	e.fog_light_color = Color(0.7, 0.8, 0.9)
	e.fog_density = 0.004
	env.environment = e
	add_child(env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 30, 0)
	sun.shadow_enabled = true
	sun.light_energy = 0.75
	sun.directional_shadow_max_distance = 120.0
	add_child(sun)

	var ground := StaticBody3D.new()
	var gm := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(600, 600)
	gm.mesh = pm
	gm.material_override = _mat(Color(0.16, 0.16, 0.18))
	var gc := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(600, 1, 600)
	gc.shape = bs
	gc.position.y = -0.5
	ground.add_child(gm)
	ground.add_child(gc)
	add_child(ground)


func _build_city() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7

	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1))
	for x in range(9, 23):
		for y in range(7, 21):
			img.set_pixel(x, y, Color(0.35, 0.45, 0.6))
	var tex := ImageTexture.create_from_image(img)

	var tints := [
		Color(0.55, 0.5, 0.45), Color(0.4, 0.45, 0.5), Color(0.55, 0.38, 0.35),
		Color(0.38, 0.48, 0.42), Color(0.45, 0.45, 0.48), Color(0.6, 0.55, 0.35)
	]
	var mats: Array[StandardMaterial3D] = []
	for t in tints:
		var m := _mat(t)
		m.albedo_texture = tex
		m.uv1_triplanar = true
		m.uv1_scale = Vector3(0.25, 0.25, 0.25)
		mats.append(m)

	var walk_mat := _mat(Color(0.5, 0.5, 0.52))
	for i in range(-3, 3):
		for j in range(-3, 3):
			var c := Vector3(i * BLOCK + BLOCK / 2.0, 0, j * BLOCK + BLOCK / 2.0)
			_box(c + Vector3(0, 0.03, 0), Vector3(40, 0.06, 40), walk_mat, false)
			for sx in [-10.0, 10.0]:
				for sz in [-10.0, 10.0]:
					if rng.randf() < 0.12:
						continue
					var h := rng.randf_range(10.0, 45.0)
					if rng.randf() < 0.25:
						h = rng.randf_range(5.0, 10.0)
					var bm: StandardMaterial3D = mats[rng.randi() % mats.size()]
					_box(c + Vector3(sx, h / 2.0, sz), Vector3(17, h, 17), bm, true)

	var line_mat := _mat(Color(0.95, 0.8, 0.2))
	for k in range(-3, 4):
		_box(Vector3(k * BLOCK, 0.02, 0), Vector3(0.3, 0.02, 340), line_mat, false)
		_box(Vector3(0, 0.02, k * BLOCK), Vector3(340, 0.02, 0.3), line_mat, false)


func _part(parent: Node3D, mesh: Mesh, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat
	parent.add_child(mi)
	return mi


func _boxm(size: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = size
	return b


func _spherem(r: float) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	return s


func _limb(parent: Node3D, pivot_pos: Vector3, r: float, h: float, mat: Material) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = pivot_pos
	parent.add_child(pivot)
	var cm := CapsuleMesh.new()
	cm.radius = r
	cm.height = h
	_part(pivot, cm, Vector3(0, -h / 2.0, 0), mat)
	return pivot


func _build_player() -> void:
	player = CharacterBody3D.new()
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 1.8
	col.shape = cap
	col.position.y = 0.9
	player.add_child(col)
	model = Node3D.new()
	player.add_child(model)
	player.position = Vector3(0, 0.1, 0)
	add_child(player)

	if ResourceLoader.exists(GLB_PATH):
		_build_glb()
	else:
		_build_rig()

	cam = Camera3D.new()
	cam.far = 600.0
	cam.position = Vector3(0, 6, 9)
	add_child(cam)
	cam.current = true


func _build_rig() -> void:
	var skin := _mat(Color(0.87, 0.67, 0.52))
	var shirt := _mat(Color(0.15, 0.35, 0.7))
	var pants := _mat(Color(0.18, 0.18, 0.22))
	var shoe := _mat(Color(0.95, 0.95, 0.95))
	var dark := _mat(Color(0.05, 0.05, 0.05))

	hips = Node3D.new()
	hips.position.y = 0.95
	model.add_child(hips)
	torso = Node3D.new()
	hips.add_child(torso)

	_part(torso, _boxm(Vector3(0.5, 0.6, 0.28)), Vector3(0, 0.3, 0), shirt)
	_part(torso, _spherem(0.14), Vector3(0, 0.78, 0), skin)
	_part(torso, _boxm(Vector3(0.22, 0.05, 0.05)), Vector3(0, 0.8, -0.12), dark)

	arm_l = _limb(torso, Vector3(-0.33, 0.52, 0), 0.07, 0.55, shirt)
	arm_r = _limb(torso, Vector3(0.33, 0.52, 0), 0.07, 0.55, shirt)
	_part(arm_l, _spherem(0.07), Vector3(0, -0.56, 0), skin)
	_part(arm_r, _spherem(0.07), Vector3(0, -0.56, 0), skin)

	leg_l = _limb(hips, Vector3(-0.13, 0, 0), 0.09, 0.9, pants)
	leg_r = _limb(hips, Vector3(0.13, 0, 0), 0.09, 0.9, pants)
	_part(leg_l, _boxm(Vector3(0.16, 0.1, 0.3)), Vector3(0, -0.9, -0.05), shoe)
	_part(leg_r, _boxm(Vector3(0.16, 0.1, 0.3)), Vector3(0, -0.9, -0.05), shoe)


func _build_glb() -> void:
	var scn: PackedScene = load(GLB_PATH)
	var inst := scn.instantiate() as Node3D
	inst.rotation.y = GLB_YAW
	model.add_child(inst)
	anim_player = inst.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if anim_player == null:
		return
	a_idle = _find_anim(["idle"])
	a_walk = _find_anim(["walk"])
	a_run = _find_anim(["run", "sprint", "jog"])
	a_jump = _find_anim(["jump", "fall"])
	if a_run == "":
		a_run = a_walk
	for n in [a_idle, a_walk, a_run]:
		if n != "":
			anim_player.get_animation(n).loop_mode = Animation.LOOP_LINEAR


func _find_anim(keys: Array) -> String:
	for n in anim_player.get_animation_list():
		var l := String(n).to_lower()
		for k in keys:
			if l.contains(k):
				return String(n)
	return ""


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	ui = Control.new()
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.draw.connect(_draw_ui)
	layer.add_child(ui)

	var lbl := Label.new()
	lbl.text = "Phase 2"
	lbl.position = Vector2(30, 20)
	lbl.add_theme_font_size_override("font_size", 36)
	layer.add_child(lbl)
	add_child(layer)


func _jump_center() -> Vector2:
	return get_viewport().get_visible_rect().size - Vector2(170, 170)


func _draw_ui() -> void:
	if stick_id != -1:
		ui.draw_circle(stick_origin, RADIUS, Color(1, 1, 1, 0.15))
		ui.draw_circle(stick_origin + stick_vec * RADIUS, 45.0, Color(1, 1, 1, 0.5))
	var jc := _jump_center()
	var a := 0.4 if jump_id != -1 else 0.18
	ui.draw_circle(jc, 70.0, Color(1, 1, 1, a))
	ui.draw_string(ThemeDB.fallback_font, jc + Vector2(-60, 10), "JUMP", HORIZONTAL_ALIGNMENT_CENTER, 120, 30)


func _input(event: InputEvent) -> void:
	var half := get_viewport().get_visible_rect().size.x * 0.5
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.distance_to(_jump_center()) < 100.0:
				jump_id = event.index
				want_jump = true
			elif event.position.x < half and stick_id == -1:
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
			elif event.index == jump_id:
				jump_id = -1
		ui.queue_redraw()
	elif event is InputEventScreenDrag:
		if event.index == stick_id:
			stick_vec = (event.position - stick_origin).limit_length(RADIUS) / RADIUS
		elif event.index == look_id:
			cam_yaw -= event.relative.x * 0.005
			cam_pitch = clampf(cam_pitch + event.relative.y * 0.004, 0.25, 1.35)
		ui.queue_redraw()


func _physics_process(delta: float) -> void:
	time += delta
	var input := stick_vec
	if input == Vector2.ZERO:
		input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var mag := minf(input.length(), 1.0)
	var dir := Vector3(input.x, 0, input.y).rotated(Vector3.UP, cam_yaw)

	var target := Vector3.ZERO
	if mag > 0.05:
		target = dir.normalized() * (MAX_SPEED * mag * mag)

	var hv := Vector3(player.velocity.x, 0, player.velocity.z)
	hv = hv.move_toward(target, 45.0 * delta)
	player.velocity.x = hv.x
	player.velocity.z = hv.z

	if player.is_on_floor():
		player.velocity.y = -1.0
		if want_jump or Input.is_action_just_pressed("ui_accept"):
			player.velocity.y = JUMP_V
	else:
		player.velocity.y -= GRAVITY * delta
	want_jump = false
	player.move_and_slide()

	speed = hv.length()
	if target.length() > 0.1:
		var want_yaw := atan2(-target.x, -target.z)
		model.rotation.y = lerp_angle(model.rotation.y, want_yaw, 1.0 - exp(-14.0 * delta))

	_animate(delta, player.is_on_floor())

	var tgt := player.position + Vector3(0, 1.8, 0)
	var off := Vector3(0, 0, 10).rotated(Vector3.RIGHT, -cam_pitch).rotated(Vector3.UP, cam_yaw)
	cam.position = cam.position.lerp(tgt + off, 1.0 - exp(-14.0 * delta))
	cam.look_at(tgt)


func _animate(delta: float, on_floor: bool) -> void:
	if anim_player != null:
		_animate_glb(on_floor)
		return
	if hips == null:
		return

	var k := 1.0 - exp(-18.0 * delta)

	if not on_floor:
		leg_l.rotation.x = lerpf(leg_l.rotation.x, 0.9, k)
		leg_r.rotation.x = lerpf(leg_r.rotation.x, -0.4, k)
		arm_l.rotation.x = lerpf(arm_l.rotation.x, 2.3, k)
		arm_r.rotation.x = lerpf(arm_r.rotation.x, 2.3, k)
		torso.rotation.x = lerpf(torso.rotation.x, -0.1, k)
		hips.position.y = lerpf(hips.position.y, 0.95, k)
		return

	var ratio := clampf(speed / MAX_SPEED, 0.0, 1.0)
	var swing := 0.0
	var lean := 0.0
	var twist := 0.0
	var sway := sin(time * 1.8) * 0.04
	if speed > 0.4:
		anim_t += delta * (5.0 + speed * 1.3)
		var amp := 0.35 + ratio * 0.7
		swing = sin(anim_t) * amp
		lean = ratio * 0.3
		twist = sin(anim_t) * 0.12 * ratio
		sway = 0.0

	leg_l.rotation.x = lerpf(leg_l.rotation.x, swing, k)
	leg_r.rotation.x = lerpf(leg_r.rotation.x, -swing, k)
	arm_l.rotation.x = lerpf(arm_l.rotation.x, -swing * 1.1 + sway, k)
	arm_r.rotation.x = lerpf(arm_r.rotation.x, swing * 1.1 - sway, k)
	torso.rotation.x = lerpf(torso.rotation.x, -lean, k)
	torso.rotation.y = lerpf(torso.rotation.y, twist, k)
	hips.position.y = 0.95 * cos(leg_l.rotation.x)


func _animate_glb(on_floor: bool) -> void:
	var want := a_idle
	if not on_floor and a_jump != "":
		want = a_jump
	elif speed > 5.5 and a_run != "":
		want = a_run
	elif speed > 0.5 and a_walk != "":
		want = a_walk
	if want != "" and want != a_cur:
		a_cur = want
		anim_player.play(want, 0.2)
	if a_cur != "" and a_cur == a_walk:
		anim_player.speed_scale = clampf(speed / 2.5, 0.6, 1.6)
	elif a_cur != "" and a_cur == a_run:
		anim_player.speed_scale = clampf(speed / 7.0, 0.8, 1.4)
	else:
		anim_player.speed_scale = 1.0
