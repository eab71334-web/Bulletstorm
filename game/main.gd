extends Node3D

const GLB_PATH := "res://game/character.glb"
const GLB_YAW := PI
const CAR_GLB_PATH := "res://game/car.glb"
const CAR_GLB_YAW := 0.0
const POLICE_GLB_PATH := "res://game/police.glb"
const POLICE_GLB_YAW := 0.0
const CAR_LENGTH := 5.4
const POLICE_LENGTH := 5.2
const CAR_SCALE := 1.25
const WHEEL_R := 0.475

const MAX_SPEED := 8.5
const JUMP_V := 9.0
const GRAVITY := 25.0
const RADIUS := 110.0
const BLOCK := 54.0

const CAR_MAX := 45.0
const CAR_ACCEL := 16.0
const CAR_BRAKE := 32.0
const WHEELBASE := 4.2
const GAUGE_MAX := 220.0
const MAP_HALF := 180.0

const PED_COUNT := 24
const MAX_STARS := 5
const COP_MAX := 31.0

const WEAPONS := [
	{"name": "FISTS", "dmg": 15.0, "rate": 0.45, "auto": false, "pellets": 1, "spread": 0.0, "range": 2.3, "len": 0.0},
	{"name": "PISTOL", "dmg": 26.0, "rate": 0.28, "auto": false, "pellets": 1, "spread": 0.012, "range": 80.0, "len": 0.3},
	{"name": "SMG", "dmg": 11.0, "rate": 0.075, "auto": true, "pellets": 1, "spread": 0.045, "range": 70.0, "len": 0.5},
	{"name": "SHOTGUN", "dmg": 13.0, "rate": 0.85, "auto": false, "pellets": 8, "spread": 0.09, "range": 35.0, "len": 0.8},
	{"name": "RIFLE", "dmg": 20.0, "rate": 0.11, "auto": true, "pellets": 1, "spread": 0.02, "range": 110.0, "len": 0.9},
]
const MAG_SIZE := [0, 12, 30, 6, 30]
const DEFAULT_RES := [0, 60, 180, 24, 120]


class Ped extends CharacterBody3D:
	var hp := 40.0
	var dead := false
	var dead_t := 0.0
	var a_ix := 0
	var a_iz := 0
	var b_ix := 0
	var b_iz := 0
	var t := 0.0
	var lane := 5.5
	var panic := 0.0
	var walk_t := 0.0
	var leg_l: Node3D
	var leg_r: Node3D
	var arm_l: Node3D
	var arm_r: Node3D


class Cop extends CharacterBody3D:
	var hp := 160.0
	var dead := false
	var speed := 0.0
	var path := PackedVector2Array()
	var path_i := 0
	var repath := 0.0
	var shoot_cd := 1.0
	var stuck_t := 0.0
	var reverse_t := 0.0
	var leave_t := 0.0
	var mat_a: StandardMaterial3D
	var mat_b: StandardMaterial3D


var player: CharacterBody3D
var player_col: CollisionShape3D
var model: Node3D
var gun_node: Node3D
var gun_mesh: MeshInstance3D
var cam: Camera3D
var ui: Control
var mini: Control
var big: Control
var wheel: Control

var cam_yaw := 0.0
var cam_pitch := 0.85
var stick_id := -1
var look_id := -1
var jump_id := -1
var fire_id := -1
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

var car: CharacterBody3D
var car_visual: Node3D
var car_wheels: Array[Node3D] = []
var car_speed := 0.0
var car_steer := 0.0
var car_accel_s := 0.0
var in_car := false
var near_car := false

var map_open := false
var wheel_open := false
var bld_rects: Array[Rect2] = []
var block_rects: Array[Rect2] = []
var dest_set := false
var dest := Vector2.ZERO
var route: Array[Vector2] = []
var route_timer := 0.0
var astar := AStar2D.new()
var dest_marker: MeshInstance3D
var arrived_t := 0.0

var hp := 100.0
var dead := false
var wasted_t := 0.0
var hurt_flash := 0.0

var cur_weapon := 1
var ammo_mag: Array[int] = [0, 12, 30, 6, 30]
var ammo_res: Array[int] = [0, 60, 180, 24, 120]
var fire_cd := 0.0
var fire_queued := false
var reloading := false
var reload_t := 0.0
var aim_t := 0.0
var punch_t := 0.0
var lock_node: Node3D

var peds: Array[Ped] = []
var cops: Array[Cop] = []
var stars := 0
var wanted_cool := 0.0
var evade_t := 0.0
var spawn_t := 0.0
var ped_spawn_t := 0.0

var fx: Array[Dictionary] = []
var tr_mat_p: StandardMaterial3D
var tr_mat_c: StandardMaterial3D

var ped_torso_mesh: BoxMesh
var ped_head_mesh: SphereMesh
var ped_leg_mesh: BoxMesh
var ped_arm_mesh: BoxMesh
var shirt_mats: Array[StandardMaterial3D] = []
var skin_mats: Array[StandardMaterial3D] = []
var pant_mat: StandardMaterial3D


func _ready() -> void:
	randomize()
	_init_assets()
	_build_world()
	_build_city()
	_build_player()
	_build_car()
	_build_ui()
	_build_marker()
	_set_weapon(1)
	for i in PED_COUNT:
		_spawn_ped()


# ---------------------------------------------------------------- helpers

func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	return m


func _unshaded(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = c
	return m


func _vp() -> Vector2:
	return get_viewport().get_visible_rect().size


func _jump_center() -> Vector2:
	return _vp() - Vector2(170, 170)


func _act_center() -> Vector2:
	return _vp() - Vector2(350, 130)


func _fire_center() -> Vector2:
	return _vp() - Vector2(170, 390)


func _wpn_center() -> Vector2:
	return _vp() - Vector2(370, 310)


func _mini_rect() -> Rect2:
	var s := _vp()
	return Rect2(s.x - 310.0, 24.0, 280.0, 280.0)


func _big_rect() -> Rect2:
	var s := _vp()
	var d := s.y - 48.0
	return Rect2((s.x - d) / 2.0, 24.0, d, d)


func _close_rect() -> Rect2:
	return Rect2(_vp().x - 280.0, 30.0, 240.0, 90.0)


func _clear_rect() -> Rect2:
	return Rect2(_vp().x - 280.0, 140.0, 240.0, 90.0)


func _wheel_pos(i: int) -> Vector2:
	var a := -PI * 0.5 + TAU * float(i) / float(WEAPONS.size())
	return _vp() * 0.5 + Vector2(cos(a), sin(a)) * 250.0


func _txt(c: Control, t: String, p: Vector2, size: int, col: Color = Color.WHITE) -> void:
	c.draw_string(ThemeDB.fallback_font, p + Vector2(-150.0, size * 0.35), t, HORIZONTAL_ALIGNMENT_CENTER, 300, size, col)


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


func _pivot_mesh(parent: Node3D, pos: Vector3, mesh: Mesh, off_y: float, mat: Material) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = pos
	parent.add_child(pivot)
	_part(pivot, mesh, Vector3(0, -off_y, 0), mat)
	return pivot


func _nid(ix: int, iz: int) -> int:
	return (ix + 3) * 7 + (iz + 3)


func _node_for(p: Vector2) -> int:
	return _nid(clampi(roundi(p.x / BLOCK), -3, 3), clampi(roundi(p.y / BLOCK), -3, 3))


func _neighbors(ix: int, iz: int) -> Array[Vector2i]:
	var r: Array[Vector2i] = []
	if ix > -3:
		r.append(Vector2i(ix - 1, iz))
	if ix < 2 + 1:
		r.append(Vector2i(ix + 1, iz))
	if iz > -3:
		r.append(Vector2i(ix, iz - 1))
	if iz < 2 + 1:
		r.append(Vector2i(ix, iz + 1))
	return r


func _init_assets() -> void:
	tr_mat_p = _unshaded(Color(1.0, 0.9, 0.4))
	tr_mat_c = _unshaded(Color(1.0, 0.4, 0.2))
	ped_torso_mesh = _boxm(Vector3(0.42, 0.6, 0.24))
	ped_head_mesh = _spherem(0.13)
	ped_leg_mesh = _boxm(Vector3(0.16, 0.85, 0.18))
	ped_arm_mesh = _boxm(Vector3(0.11, 0.55, 0.13))
	var shirts := [
		Color(0.8, 0.2, 0.2), Color(0.2, 0.5, 0.8), Color(0.9, 0.8, 0.2), Color(0.3, 0.7, 0.4),
		Color(0.7, 0.4, 0.8), Color(0.9, 0.5, 0.2), Color(0.85, 0.85, 0.85), Color(0.2, 0.2, 0.25)
	]
	for c in shirts:
		shirt_mats.append(_mat(c))
	for c in [Color(0.87, 0.67, 0.52), Color(0.65, 0.45, 0.32), Color(0.45, 0.3, 0.22)]:
		skin_mats.append(_mat(c))
	pant_mat = _mat(Color(0.15, 0.17, 0.25))


# ---------------------------------------------------------------- world

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
	sun.directional_shadow_max_distance = 140.0
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
			block_rects.append(Rect2(c.x - 20.0, c.z - 20.0, 40.0, 40.0))
			for sx in [-10.0, 10.0]:
				for sz in [-10.0, 10.0]:
					if rng.randf() < 0.12:
						continue
					var h := rng.randf_range(10.0, 45.0)
					if rng.randf() < 0.25:
						h = rng.randf_range(5.0, 10.0)
					var bm: StandardMaterial3D = mats[rng.randi() % mats.size()]
					_box(c + Vector3(sx, h / 2.0, sz), Vector3(17, h, 17), bm, true)
					bld_rects.append(Rect2(c.x + sx - 8.5, c.z + sz - 8.5, 17.0, 17.0))

	var line_mat := _mat(Color(0.95, 0.8, 0.2))
	for k in range(-3, 4):
		_box(Vector3(k * BLOCK, 0.02, 0), Vector3(0.3, 0.02, 340), line_mat, false)
		_box(Vector3(0, 0.02, k * BLOCK), Vector3(340, 0.02, 0.3), line_mat, false)

	for ix in range(-3, 4):
		for iz in range(-3, 4):
			astar.add_point(_nid(ix, iz), Vector2(ix * BLOCK, iz * BLOCK))
	for ix in range(-3, 4):
		for iz in range(-3, 4):
			if ix < 3:
				astar.connect_points(_nid(ix, iz), _nid(ix + 1, iz))
			if iz < 3:
				astar.connect_points(_nid(ix, iz), _nid(ix, iz + 1))


func _build_marker() -> void:
	dest_marker = MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 1.2
	cm.bottom_radius = 1.2
	cm.height = 120.0
	dest_marker.mesh = cm
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(1.0, 0.6, 0.1, 0.35)
	dest_marker.material_override = m
	dest_marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	dest_marker.visible = false
	add_child(dest_marker)


# ---------------------------------------------------------------- player

func _build_player() -> void:
	player = CharacterBody3D.new()
	player_col = CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 1.8
	player_col.shape = cap
	player_col.position.y = 0.9
	player.add_child(player_col)
	model = Node3D.new()
	player.add_child(model)
	player.position = Vector3(0, 0.1, 0)
	add_child(player)

	if ResourceLoader.exists(GLB_PATH):
		_build_glb()
	else:
		_build_rig()

	gun_node = Node3D.new()
	gun_node.position = Vector3(0.32, 1.2, -0.2)
	model.add_child(gun_node)
	gun_mesh = MeshInstance3D.new()
	gun_mesh.mesh = _boxm(Vector3(0.09, 0.14, 0.4))
	gun_mesh.material_override = _mat(Color(0.12, 0.12, 0.14))
	gun_node.add_child(gun_mesh)

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


# ---------------------------------------------------------------- vehicles

func _collect_aabb(n: Node, xf: Transform3D, acc: Array) -> void:
	var t := xf
	if n is Node3D:
		t = xf * (n as Node3D).transform
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		if mi.mesh != null:
			var a: AABB = t * mi.mesh.get_aabb()
			if acc.is_empty():
				acc.append(a)
			else:
				acc[0] = (acc[0] as AABB).merge(a)
	for c in n.get_children():
		_collect_aabb(c, t, acc)


func _make_glb_vehicle(path: String, yaw: float, length: float) -> Node3D:
	if not ResourceLoader.exists(path):
		return null
	var scn := load(path) as PackedScene
	if scn == null:
		return null
	var inst := scn.instantiate() as Node3D
	if inst == null:
		return null
	var acc: Array = []
	_collect_aabb(inst, Transform3D.IDENTITY, acc)
	var holder := Node3D.new()
	holder.add_child(inst)
	if acc.is_empty():
		return holder
	var bb: AABB = acc[0]
	var base_yaw := 0.0
	var len := bb.size.z
	if bb.size.x > bb.size.z:
		base_yaw = PI * 0.5
		len = bb.size.x
	var s := length / maxf(len, 0.001)
	inst.position = Vector3(
		-(bb.position.x + bb.size.x * 0.5),
		-bb.position.y,
		-(bb.position.z + bb.size.z * 0.5)
	)
	holder.scale = Vector3.ONE * s
	holder.rotation.y = base_yaw + yaw
	return holder


func _build_car_procedural(vis: Node3D, paint_col: Color, police: bool, wheels_out: Array[Node3D]) -> Array:
	vis.scale = Vector3.ONE * CAR_SCALE
	var paint := _mat(paint_col)
	paint.metallic = 0.6
	paint.roughness = 0.35
	var glass := _mat(Color(0.08, 0.1, 0.14))
	glass.metallic = 0.8
	glass.roughness = 0.1
	var dark := _mat(Color(0.05, 0.05, 0.05))
	var hl := _mat(Color(1, 1, 0.85))
	hl.emission_enabled = true
	hl.emission = Color(1, 0.95, 0.7)
	hl.emission_energy_multiplier = 2.0
	var tl := _mat(Color(1, 0.1, 0.1))
	tl.emission_enabled = true
	tl.emission = Color(1, 0.05, 0.05)
	tl.emission_energy_multiplier = 1.5

	_part(vis, _boxm(Vector3(1.9, 0.55, 4.3)), Vector3(0, 0.62, 0), paint)
	_part(vis, _boxm(Vector3(1.65, 0.5, 2.1)), Vector3(0, 1.14, 0.35), glass)
	_part(vis, _boxm(Vector3(1.7, 0.06, 1.9)), Vector3(0, 1.42, 0.35), paint)
	_part(vis, _boxm(Vector3(1.95, 0.2, 0.2)), Vector3(0, 0.4, -2.15), dark)
	_part(vis, _boxm(Vector3(1.95, 0.2, 0.2)), Vector3(0, 0.4, 2.15), dark)
	for sx in [-0.65, 0.65]:
		_part(vis, _boxm(Vector3(0.4, 0.15, 0.08)), Vector3(sx, 0.72, -2.16), hl)
		_part(vis, _boxm(Vector3(0.4, 0.15, 0.08)), Vector3(sx, 0.72, 2.16), tl)

	var res: Array = []
	if police:
		_part(vis, _boxm(Vector3(1.92, 0.22, 2.4)), Vector3(0, 0.58, 0.2), dark)
		var ma := _mat(Color(1, 0.1, 0.1))
		ma.emission_enabled = true
		ma.emission = Color(1, 0.1, 0.1)
		ma.emission_energy_multiplier = 4.0
		var mb := _mat(Color(0.1, 0.2, 1))
		mb.emission_enabled = true
		mb.emission = Color(0.1, 0.25, 1)
		mb.emission_energy_multiplier = 0.2
		_part(vis, _boxm(Vector3(0.7, 0.14, 0.3)), Vector3(-0.38, 1.52, 0.35), ma)
		_part(vis, _boxm(Vector3(0.7, 0.14, 0.3)), Vector3(0.38, 1.52, 0.35), mb)
		res.append(ma)
		res.append(mb)

	var wpos := [
		Vector3(-1.0, 0.38, -1.35), Vector3(1.0, 0.38, -1.35),
		Vector3(-1.0, 0.38, 1.35), Vector3(1.0, 0.38, 1.35)
	]
	for wp in wpos:
		var pivot := Node3D.new()
		pivot.position = wp
		vis.add_child(pivot)
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.38
		cyl.bottom_radius = 0.38
		cyl.height = 0.3
		var mi := MeshInstance3D.new()
		mi.mesh = cyl
		mi.material_override = dark
		mi.rotation_degrees = Vector3(0, 0, 90)
		pivot.add_child(mi)
		wheels_out.append(pivot)
	return res


func _build_car() -> void:
	car = CharacterBody3D.new()
	var col := CollisionShape3D.new()
	var bx := BoxShape3D.new()
	bx.size = Vector3(2.4, 1.6, CAR_LENGTH - 0.4)
	col.shape = bx
	col.position.y = 0.9
	car.add_child(col)
	car_visual = Node3D.new()
	car.add_child(car_visual)

	var holder := _make_glb_vehicle(CAR_GLB_PATH, CAR_GLB_YAW, CAR_LENGTH)
	if holder != null:
		car_visual.add_child(holder)
	else:
		_build_car_procedural(car_visual, Color(0.8, 0.08, 0.08), false, car_wheels)

	car.position = Vector3(5, 0.1, -9)
	add_child(car)


func _make_cop() -> Cop:
	var c := Cop.new()
	var col := CollisionShape3D.new()
	var bx := BoxShape3D.new()
	bx.size = Vector3(2.3, 1.5, POLICE_LENGTH - 0.5)
	col.shape = bx
	col.position.y = 0.85
	c.add_child(col)
	var vis := Node3D.new()
	c.add_child(vis)
	var holder := _make_glb_vehicle(POLICE_GLB_PATH, POLICE_GLB_YAW, POLICE_LENGTH)
	if holder != null:
		vis.add_child(holder)
	else:
		var tmp: Array[Node3D] = []
		var lights := _build_car_procedural(vis, Color(0.92, 0.92, 0.95), true, tmp)
		if lights.size() >= 2:
			c.mat_a = lights[0]
			c.mat_b = lights[1]
	return c


# ---------------------------------------------------------------- peds

func _make_ped() -> Ped:
	var p := Ped.new()
	p.collision_layer = 2
	p.collision_mask = 0
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 1.8
	col.shape = cap
	col.position.y = 0.9
	p.add_child(col)
	var shirt: StandardMaterial3D = shirt_mats[randi() % shirt_mats.size()]
	var skin: StandardMaterial3D = skin_mats[randi() % skin_mats.size()]
	_part(p, ped_torso_mesh, Vector3(0, 1.15, 0), shirt)
	_part(p, ped_head_mesh, Vector3(0, 1.62, 0), skin)
	p.leg_l = _pivot_mesh(p, Vector3(-0.1, 0.85, 0), ped_leg_mesh, 0.425, pant_mat)
	p.leg_r = _pivot_mesh(p, Vector3(0.1, 0.85, 0), ped_leg_mesh, 0.425, pant_mat)
	p.arm_l = _pivot_mesh(p, Vector3(-0.28, 1.4, 0), ped_arm_mesh, 0.275, shirt)
	p.arm_r = _pivot_mesh(p, Vector3(0.28, 1.4, 0), ped_arm_mesh, 0.275, shirt)
	return p


func _spawn_ped() -> void:
	var p := _make_ped()
	var ix := randi_range(-3, 3)
	var iz := randi_range(-3, 3)
	var nbs := _neighbors(ix, iz)
	var pick: Vector2i = nbs[randi() % nbs.size()]
	p.a_ix = ix
	p.a_iz = iz
	p.b_ix = pick.x
	p.b_iz = pick.y
	p.t = randf()
	p.lane = 5.5 if randf() < 0.5 else -5.5
	add_child(p)
	peds.append(p)
	_place_ped(p)


func _place_ped(p: Ped) -> void:
	var a := Vector2(p.a_ix * BLOCK, p.a_iz * BLOCK)
	var b := Vector2(p.b_ix * BLOCK, p.b_iz * BLOCK)
	var dir := (b - a).normalized()
	var perp := Vector2(-dir.y, dir.x) * p.lane
	var pos := a.lerp(b, p.t) + perp
	p.position = Vector3(pos.x, 0.1, pos.y)
	p.rotation.y = atan2(-dir.x, -dir.y)


func _update_peds(delta: float) -> void:
	for i in range(peds.size() - 1, -1, -1):
		var p := peds[i]
		if p.dead:
			p.dead_t += delta
			p.rotation.x = lerpf(p.rotation.x, -PI * 0.5, 1.0 - exp(-8.0 * delta))
			if p.dead_t > 8.0:
				p.queue_free()
				peds.remove_at(i)
			continue
		var spd := 5.8 if p.panic > 0.0 else 1.7
		p.panic = maxf(p.panic - delta, 0.0)
		p.t += spd * delta / BLOCK
		while p.t >= 1.0:
			p.t -= 1.0
			var nbs := _neighbors(p.b_ix, p.b_iz)
			var opts: Array[Vector2i] = []
			for n in nbs:
				if not (n.x == p.a_ix and n.y == p.a_iz):
					opts.append(n)
			if opts.is_empty():
				opts = nbs
			var pick: Vector2i = opts[randi() % opts.size()]
			p.a_ix = p.b_ix
			p.a_iz = p.b_iz
			p.b_ix = pick.x
			p.b_iz = pick.y
		_place_ped(p)
		p.walk_t += delta * spd * 2.2
		var sw := sin(p.walk_t) * (0.5 if spd < 3.0 else 0.9)
		p.leg_l.rotation.x = sw
		p.leg_r.rotation.x = -sw
		p.arm_l.rotation.x = -sw * 0.8
		p.arm_r.rotation.x = sw * 0.8
	ped_spawn_t -= delta
	if ped_spawn_t <= 0.0 and peds.size() < PED_COUNT:
		ped_spawn_t = 1.5
		_spawn_ped()


func _alarm(pos: Vector3, radius: float) -> void:
	for p in peds:
		if not p.dead and p.position.distance_to(pos) < radius:
			p.panic = maxf(p.panic, 6.0)


func _damage_ped(p: Ped, dmg: float) -> void:
	if p.dead:
		return
	p.hp -= dmg
	p.panic = 8.0
	if p.hp <= 0.0:
		_kill_ped(p)


func _kill_ped(p: Ped) -> void:
	if p.dead:
		return
	p.dead = true
	p.dead_t = 0.0
	p.collision_layer = 0
	_alarm(p.position, 30.0)
	_add_wanted(1)


# ---------------------------------------------------------------- wanted / police

func _add_wanted(n: int) -> void:
	evade_t = 0.0
	if stars == 0:
		stars = 1
		wanted_cool = 4.0
		spawn_t = 0.5
	elif wanted_cool <= 0.0:
		stars = mini(MAX_STARS, stars + n)
		wanted_cool = 4.0


func _spawn_cop() -> void:
	var p3 := car.position if in_car else player.position
	var pp := Vector2(p3.x, p3.z)
	var pos := Vector2.ZERO
	var found := false
	for tries in 14:
		var ix := randi_range(-3, 3)
		var iz := randi_range(-3, 3)
		pos = Vector2(ix * BLOCK, iz * BLOCK)
		if pos.distance_to(pp) > 95.0:
			found = true
			break
	if not found:
		return
	var c := _make_cop()
	c.position = Vector3(pos.x + 3.5, 0.1, pos.y)
	c.rotation.y = atan2(-(pp.x - pos.x), -(pp.y - pos.y))
	add_child(c)
	cops.append(c)


func _damage_cop(c: Cop, dmg: float) -> void:
	if c.dead:
		return
	c.hp -= dmg
	if c.hp <= 0.0:
		c.dead = true
		_spark(c.position + Vector3(0, 1.0, 0), Color(1, 0.55, 0.1), 1.0, 0.5, 7.0)
		_add_wanted(2)
		c.queue_free()
		cops.erase(c)


func _update_cops(delta: float) -> void:
	for i in range(cops.size() - 1, -1, -1):
		var c := cops[i]
		_update_cop(c, delta)
		if stars == 0 and c.leave_t > 6.0:
			c.queue_free()
			cops.remove_at(i)


func _update_cop(c: Cop, delta: float) -> void:
	var tgt3 := car.position if in_car else player.position
	var tp := Vector2(tgt3.x, tgt3.z)
	var cp := Vector2(c.position.x, c.position.z)
	var d := cp.distance_to(tp)
	var chasing := stars > 0 and not dead

	if c.mat_a != null and c.mat_b != null:
		var on := int(time * 6.0) % 2 == 0
		c.mat_a.emission_energy_multiplier = 4.0 if on else 0.2
		c.mat_b.emission_energy_multiplier = 0.2 if on else 4.0

	var target_speed := 0.0
	if chasing:
		var aim := tp
		if d >= 45.0:
			c.repath -= delta
			if c.repath <= 0.0:
				c.repath = 1.0
				c.path = astar.get_point_path(_node_for(cp), _node_for(tp))
				c.path_i = 0
			while c.path_i < c.path.size() and cp.distance_to(c.path[c.path_i]) < 10.0:
				c.path_i += 1
			if c.path_i < c.path.size():
				aim = c.path[c.path_i]
		var vec := aim - cp
		var desired := atan2(-vec.x, -vec.y)
		var diff := wrapf(desired - c.rotation.y, -PI, PI)
		if c.reverse_t > 0.0:
			c.reverse_t -= delta
			target_speed = -9.0
			c.rotation.y -= clampf(diff, -1.0, 1.0) * 1.5 * delta
		else:
			c.rotation.y += clampf(diff, -2.6 * delta, 2.6 * delta)
			target_speed = COP_MAX
			if absf(diff) > 0.8:
				target_speed = 12.0
			if d < 8.0:
				target_speed = 4.0
	else:
		c.leave_t += delta

	c.speed = move_toward(c.speed, target_speed, 16.0 * delta)
	var f := -c.global_transform.basis.z
	c.velocity.x = f.x * c.speed
	c.velocity.z = f.z * c.speed
	if c.is_on_floor():
		c.velocity.y = -1.0
	else:
		c.velocity.y -= GRAVITY * delta
	c.move_and_slide()
	var actual := c.velocity.dot(f)

	if chasing and c.reverse_t <= 0.0 and target_speed > 8.0 and absf(actual) < 2.5:
		c.stuck_t += delta
		if c.stuck_t > 1.2:
			c.reverse_t = 1.0
			c.stuck_t = 0.0
	else:
		c.stuck_t = 0.0
	c.speed = actual

	if chasing:
		c.shoot_cd -= delta
		if d < 30.0 and c.shoot_cd <= 0.0:
			c.shoot_cd = randf_range(0.5, 0.9)
			_cop_shoot(c, tgt3)
		if d < 3.4 and absf(c.speed) > 5.0:
			_hurt_player(30.0 * delta)


func _cop_shoot(c: Cop, tgt3: Vector3) -> void:
	var from := c.position + Vector3(0, 1.2, 0)
	var to := tgt3 + Vector3(0, 1.0, 0)
	var q := PhysicsRayQueryParameters3D.create(from, to + (to - from).normalized() * 1.0, 1)
	q.exclude = [c.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty():
		return
	var col = hit["collider"]
	if col == player or col == car:
		_tracer(from, hit["position"], false)
		if randf() < 0.65:
			_hurt_player(randf_range(4.0, 8.0))


func _update_wanted(delta: float) -> void:
	wanted_cool = maxf(wanted_cool - delta, 0.0)
	if stars <= 0:
		evade_t = 0.0
		return
	spawn_t -= delta
	if cops.size() < stars and spawn_t <= 0.0:
		_spawn_cop()
		spawn_t = 2.5
	var p3 := car.position if in_car else player.position
	var pp := Vector2(p3.x, p3.z)
	var near := false
	for c in cops:
		if Vector2(c.position.x, c.position.z).distance_to(pp) < 60.0:
			near = true
	if near:
		evade_t = 0.0
	else:
		evade_t += delta
		if evade_t > 18.0:
			stars = maxi(stars - 1, 0)
			evade_t = 0.0
			for c in cops:
				c.leave_t = 0.0


# ---------------------------------------------------------------- health

func _hurt_player(amount: float) -> void:
	if dead:
		return
	hp -= amount
	hurt_flash = 0.3
	if hp <= 0.0:
		hp = 0.0
		dead = true
		wasted_t = 3.0
		stick_id = -1
		stick_vec = Vector2.ZERO
		look_id = -1
		jump_id = -1
		fire_id = -1


func _respawn() -> void:
	dead = false
	hp = 100.0
	stars = 0
	evade_t = 0.0
	for c in cops:
		c.queue_free()
	cops.clear()
	if in_car:
		in_car = false
		player.visible = true
		player_col.set_deferred("disabled", false)
	player.position = Vector3(0, 0.1, 0)
	player.velocity = Vector3.ZERO
	cam_pitch = 0.85
	for i in ammo_res.size():
		ammo_res[i] = maxi(ammo_res[i], DEFAULT_RES[i])
	_set_weapon(cur_weapon)


# ---------------------------------------------------------------- weapons

func _set_weapon(i: int) -> void:
	cur_weapon = i
	reloading = false
	reload_t = 0.0
	fire_cd = 0.2
	var w: Dictionary = WEAPONS[i]
	var l := float(w["len"])
	if i == 0:
		gun_node.visible = false
	else:
		gun_node.visible = not in_car
		(gun_mesh.mesh as BoxMesh).size = Vector3(0.09, 0.14, l)
		gun_mesh.position = Vector3(0, 0, -l * 0.5)


func _find_target(origin: Vector3, yaw: float, maxd: float, cone: float) -> Node3D:
	var fwd := Vector3(-sin(yaw), 0, -cos(yaw))
	var best: Node3D = null
	var best_s := 1e9
	for p in peds:
		if p.dead:
			continue
		var s := _target_score(p, origin, fwd, maxd, cone)
		if s < best_s:
			best_s = s
			best = p
	for c in cops:
		var s2 := _target_score(c, origin, fwd, maxd, cone)
		if s2 < best_s:
			best_s = s2
			best = c
	return best


func _target_score(n: Node3D, origin: Vector3, fwd: Vector3, maxd: float, cone: float) -> float:
	var to := n.position + Vector3(0, 1.1, 0) - origin
	var flat := Vector3(to.x, 0, to.z)
	var d := flat.length()
	if d > maxd or d < 0.3:
		return 1e9
	var ang := fwd.angle_to(flat / d)
	if ang > cone:
		return 1e9
	return ang * 40.0 + d


func _try_fire(delta: float) -> void:
	fire_cd -= delta
	if reloading:
		reload_t -= delta
		if reload_t <= 0.0:
			reloading = false
			var need := int(MAG_SIZE[cur_weapon]) - ammo_mag[cur_weapon]
			var n := mini(need, ammo_res[cur_weapon])
			ammo_mag[cur_weapon] += n
			ammo_res[cur_weapon] -= n
	if in_car or dead or map_open or wheel_open:
		fire_queued = false
		return

	var w: Dictionary = WEAPONS[cur_weapon]
	var go := false
	if fire_cd <= 0.0 and not reloading:
		if bool(w["auto"]) and fire_id != -1:
			go = true
		elif fire_queued:
			go = true
	fire_queued = false
	if not go:
		return

	if cur_weapon > 0 and ammo_mag[cur_weapon] <= 0:
		if ammo_res[cur_weapon] > 0:
			reloading = true
			reload_t = 1.3
		fire_cd = 0.3
		return

	fire_cd = float(w["rate"])
	var origin := player.position + Vector3(0, 1.35, 0)
	var tgt := _find_target(origin, cam_yaw, float(w["range"]), 0.9)
	var dir := Vector3(-sin(cam_yaw), 0, -cos(cam_yaw))
	if tgt != null:
		dir = (tgt.position + Vector3(0, 1.1, 0) - origin).normalized()
	model.rotation.y = atan2(-dir.x, -dir.z)
	aim_t = 1.5

	if cur_weapon == 0:
		punch_t = 0.2
		var flat := Vector3(dir.x, 0, dir.z).normalized()
		for p in peds:
			if p.dead:
				continue
			var to := p.position - player.position
			to.y = 0.0
			if to.length() < float(w["range"]) and flat.angle_to(to.normalized()) < 1.0:
				_damage_ped(p, float(w["dmg"]))
		return

	ammo_mag[cur_weapon] -= 1
	_alarm(player.position, 30.0)
	_spark(origin + dir * 0.8, Color(1, 0.85, 0.3), 0.12, 0.05)
	for i in int(w["pellets"]):
		var jitter := Vector3(randf_range(-1, 1), randf_range(-1, 1) * 0.5, randf_range(-1, 1)) * float(w["spread"])
		_bullet(origin + dir * 0.6, (dir + jitter).normalized(), float(w["range"]), float(w["dmg"]))
	if ammo_mag[cur_weapon] <= 0 and ammo_res[cur_weapon] > 0:
		reloading = true
		reload_t = 1.3


func _bullet(from: Vector3, dir: Vector3, rng: float, dmg: float) -> void:
	var to := from + dir * rng
	var q := PhysicsRayQueryParameters3D.create(from, to, 3)
	q.exclude = [player.get_rid(), car.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	var end := to
	if not hit.is_empty():
		end = hit["position"]
		var col = hit["collider"]
		if col is Ped:
			_damage_ped(col as Ped, dmg)
		elif col is Cop:
			_damage_cop(col as Cop, dmg)
		_spark(end, Color(1, 0.9, 0.5), 0.14, 0.1)
	_tracer(from, end, true)


func _tracer(from: Vector3, to: Vector3, player_shot: bool) -> void:
	var d := to - from
	var l := d.length()
	if l < 0.05:
		return
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.05, 0.05, l)
	mi.mesh = bm
	mi.material_override = tr_mat_p if player_shot else tr_mat_c
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	mi.global_position = from + d * 0.5
	var up := Vector3.UP
	if absf(d.normalized().y) > 0.98:
		up = Vector3.RIGHT
	mi.look_at(to, up)
	fx.append({"n": mi, "t": 0.06, "g": 0.0})


func _spark(pos: Vector3, color: Color, radius: float, life: float, grow: float = 0.0) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = _spherem(radius)
	mi.material_override = _unshaded(color)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	mi.global_position = pos
	fx.append({"n": mi, "t": life, "g": grow})


func _update_fx(delta: float) -> void:
	for i in range(fx.size() - 1, -1, -1):
		var f: Dictionary = fx[i]
		f["t"] = float(f["t"]) - delta
		var n: Node3D = f["n"]
		if float(f["g"]) > 0.0:
			n.scale += Vector3.ONE * float(f["g"]) * delta
		if float(f["t"]) <= 0.0:
			n.queue_free()
			fx.remove_at(i)


# ---------------------------------------------------------------- UI

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	ui = Control.new()
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.draw.connect(_draw_ui)
	layer.add_child(ui)

	var lbl := Label.new()
	lbl.text = "Phase 4"
	lbl.position = Vector2(30, 20)
	lbl.add_theme_font_size_override("font_size", 36)
	layer.add_child(lbl)

	mini = Control.new()
	mini.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mini.clip_contents = true
	mini.draw.connect(_draw_mini)
	layer.add_child(mini)

	big = Control.new()
	big.set_anchors_preset(Control.PRESET_FULL_RECT)
	big.mouse_filter = Control.MOUSE_FILTER_IGNORE
	big.draw.connect(_draw_big)
	big.visible = false
	layer.add_child(big)

	wheel = Control.new()
	wheel.set_anchors_preset(Control.PRESET_FULL_RECT)
	wheel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wheel.draw.connect(_draw_wheel)
	wheel.visible = false
	layer.add_child(wheel)

	add_child(layer)


func _process(delta: float) -> void:
	var r := _mini_rect()
	mini.position = r.position
	mini.size = r.size
	mini.queue_redraw()
	ui.queue_redraw()
	if map_open:
		big.queue_redraw()
	if wheel_open:
		wheel.queue_redraw()
	if arrived_t > 0.0:
		arrived_t -= delta
	_update_fx(delta)


func _star_pts(c: Vector2, r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 10:
		var ang := -PI * 0.5 + float(i) * PI / 5.0
		var rad := r if i % 2 == 0 else r * 0.45
		pts.append(c + Vector2(cos(ang), sin(ang)) * rad)
	return pts


func _draw_ui() -> void:
	var s := _vp()
	if hurt_flash > 0.0:
		ui.draw_rect(Rect2(Vector2.ZERO, s), Color(1, 0, 0, hurt_flash * 0.5))

	if stick_id != -1 and not map_open:
		ui.draw_circle(stick_origin, RADIUS, Color(1, 1, 1, 0.15))
		ui.draw_circle(stick_origin + stick_vec * RADIUS, 45.0, Color(1, 1, 1, 0.5))

	var jc := _jump_center()
	var a := 0.4 if jump_id != -1 else 0.18
	ui.draw_circle(jc, 70.0, Color(1, 1, 1, a))
	_txt(ui, "BRAKE" if in_car else "JUMP", jc, 28)

	if in_car or near_car:
		var ac := _act_center()
		ui.draw_circle(ac, 70.0, Color(0.2, 0.7, 1.0, 0.4))
		_txt(ui, "EXIT" if in_car else "ENTER", ac, 28)

	if not in_car:
		var fc := _fire_center()
		ui.draw_circle(fc, 90.0, Color(1, 0.2, 0.2, 0.55 if fire_id != -1 else 0.3))
		_txt(ui, "PUNCH" if cur_weapon == 0 else "FIRE", fc, 32)
		var wc := _wpn_center()
		ui.draw_circle(wc, 62.0, Color(0.9, 0.9, 0.3, 0.3))
		_txt(ui, "GUNS", wc, 26)

	if in_car:
		_draw_gauge()

	# health + weapon
	ui.draw_rect(Rect2(30, 84, 320, 24), Color(0, 0, 0, 0.5))
	var hc := Color(0.9, 0.2, 0.2).lerp(Color(0.3, 0.9, 0.4), clampf(hp / 100.0, 0.0, 1.0))
	ui.draw_rect(Rect2(32, 86, 316.0 * clampf(hp / 100.0, 0.0, 1.0), 20), hc)
	var w: Dictionary = WEAPONS[cur_weapon]
	var info := String(w["name"])
	if cur_weapon > 0:
		info += "   %d / %d" % [ammo_mag[cur_weapon], ammo_res[cur_weapon]]
	if reloading:
		info += "   RELOAD"
	ui.draw_string(ThemeDB.fallback_font, Vector2(30, 152), info, HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color.WHITE)

	# wanted stars
	var blink := evade_t > 0.0 and (int(time * 4.0) % 2 == 0)
	for i in MAX_STARS:
		var cpos := Vector2(s.x * 0.5 + (float(i) - 2.0) * 72.0, 60.0)
		var pts := _star_pts(cpos, 30.0)
		if i < stars and not blink:
			ui.draw_colored_polygon(pts, Color(1, 0.85, 0.2))
		else:
			var cl := PackedVector2Array(pts)
			cl.append(pts[0])
			ui.draw_polyline(cl, Color(1, 1, 1, 0.4), 3.0, true)

	# lock-on reticle
	if is_instance_valid(lock_node) and cur_weapon > 0 and not in_car and not dead:
		var wp := lock_node.position + Vector3(0, 1.1, 0)
		if not cam.is_position_behind(wp):
			var sp := cam.unproject_position(wp)
			ui.draw_arc(sp, 36.0, 0.0, TAU, 32, Color(1, 0.2, 0.2, 0.9), 4.0, true)
			ui.draw_line(sp + Vector2(-48, 0), sp + Vector2(-24, 0), Color(1, 0.2, 0.2), 4.0)
			ui.draw_line(sp + Vector2(48, 0), sp + Vector2(24, 0), Color(1, 0.2, 0.2), 4.0)
			ui.draw_line(sp + Vector2(0, -48), sp + Vector2(0, -24), Color(1, 0.2, 0.2), 4.0)
			ui.draw_line(sp + Vector2(0, 48), sp + Vector2(0, 24), Color(1, 0.2, 0.2), 4.0)

	var mr := _mini_rect()
	if dest_set:
		_txt(ui, "%d m" % int(_route_len()), Vector2(mr.position.x + mr.size.x * 0.5, mr.end.y + 28.0), 30, Color(1, 0.8, 0.2))
	if arrived_t > 0.0:
		_txt(ui, "ARRIVED", Vector2(s.x * 0.5, 150.0), 60, Color(0.4, 1, 0.5))

	if dead:
		ui.draw_rect(Rect2(Vector2.ZERO, s), Color(0.4, 0, 0, 0.5))
		_txt(ui, "WASTED", s * 0.5, 130, Color(0.9, 0.1, 0.1))


func _draw_wheel() -> void:
	var s := _vp()
	wheel.draw_rect(Rect2(Vector2.ZERO, s), Color(0, 0, 0, 0.65))
	for i in WEAPONS.size():
		var pos := _wheel_pos(i)
		var sel := i == cur_weapon
		wheel.draw_circle(pos, 92.0, Color(0.2, 0.7, 1.0, 0.6) if sel else Color(0.14, 0.16, 0.2, 0.9))
		wheel.draw_arc(pos, 92.0, 0.0, TAU, 40, Color(1, 1, 1, 0.8 if sel else 0.3), 4.0, true)
		var w: Dictionary = WEAPONS[i]
		_txt(wheel, String(w["name"]), pos + Vector2(0, -12), 26)
		if i > 0:
			_txt(wheel, "%d / %d" % [ammo_mag[i], ammo_res[i]], pos + Vector2(0, 26), 22, Color(1, 1, 1, 0.75))
	_txt(wheel, "WEAPONS", s * 0.5, 40)


func _draw_gauge() -> void:
	var s := _vp()
	var c := Vector2(s.x * 0.5, s.y - 160.0)
	var r := 130.0
	var kmh := absf(car_speed) * 3.6
	var ratio := clampf(kmh / GAUGE_MAX, 0.0, 1.0)
	var a0 := deg_to_rad(135.0)
	var sweep := deg_to_rad(270.0)

	ui.draw_circle(c, r + 16.0, Color(0.03, 0.04, 0.06, 0.75))
	ui.draw_arc(c, r, a0, a0 + sweep, 64, Color(1, 1, 1, 0.18), 10.0, true)
	ui.draw_arc(c, r, a0 + sweep * 0.82, a0 + sweep, 24, Color(0.9, 0.15, 0.15, 0.55), 10.0, true)
	var col := Color(0.2, 0.85, 1.0).lerp(Color(1.0, 0.25, 0.2), clampf((ratio - 0.55) / 0.45, 0.0, 1.0))
	if ratio > 0.005:
		ui.draw_arc(c, r, a0, a0 + sweep * ratio, 64, col, 10.0, true)

	for i in range(0, 12):
		var f := float(i) / 11.0
		var ang := a0 + sweep * f
		var dir := Vector2(cos(ang), sin(ang))
		ui.draw_line(c + dir * (r - 28.0), c + dir * (r - 8.0), Color(1, 1, 1, 0.9), 3.0, true)
		if i % 2 == 0:
			_txt(ui, str(i * 20), c + dir * (r - 50.0), 20, Color(1, 1, 1, 0.85))
		if i < 11:
			var ang2 := a0 + sweep * ((float(i) + 0.5) / 11.0)
			var d2 := Vector2(cos(ang2), sin(ang2))
			ui.draw_line(c + d2 * (r - 18.0), c + d2 * (r - 8.0), Color(1, 1, 1, 0.5), 2.0, true)

	var na := a0 + sweep * ratio
	var nd := Vector2(cos(na), sin(na))
	ui.draw_line(c - nd * 14.0, c + nd * (r - 20.0), Color(1, 0.3, 0.2), 5.0, true)
	ui.draw_circle(c, 14.0, Color(0.15, 0.15, 0.18))
	ui.draw_circle(c, 7.0, Color(1, 0.3, 0.2))

	var g := "N"
	var gc := Color(1, 1, 1, 0.6)
	if car_speed > 0.8:
		g = "D"
		gc = Color(0.3, 1, 0.5)
	elif car_speed < -0.8:
		g = "R"
		gc = Color(1, 0.6, 0.2)
	_txt(ui, g, c + Vector2(0, -48), 36, gc)
	_txt(ui, str(int(kmh)), c + Vector2(0, 56), 58)
	_txt(ui, "KM/H", c + Vector2(0, 96), 20, Color(1, 1, 1, 0.6))


func _draw_map_content(c: Control, origin: Vector2, w_off: Vector2, sc: float, k: float, bounds: Rect2) -> void:
	for r in block_rects:
		c.draw_rect(Rect2(origin + (r.position + w_off) * sc, r.size * sc), Color(0.28, 0.3, 0.34))
	for r in bld_rects:
		c.draw_rect(Rect2(origin + (r.position + w_off) * sc, r.size * sc), Color(0.5, 0.55, 0.62))

	if route.size() >= 2:
		var pts := PackedVector2Array()
		for v in route:
			pts.append(origin + (v + w_off) * sc)
		c.draw_polyline(pts, Color(1.0, 0.78, 0.15), 4.0 * k, true)

	if dest_set:
		var dp := origin + (dest + w_off) * sc
		dp = Vector2(
			clampf(dp.x, bounds.position.x + 12.0, bounds.end.x - 12.0),
			clampf(dp.y, bounds.position.y + 12.0, bounds.end.y - 12.0)
		)
		c.draw_circle(dp, 10.0 * k, Color(1, 0.3, 0.2))
		c.draw_circle(dp, 4.0 * k, Color.WHITE)

	for cop in cops:
		var cpp := origin + (Vector2(cop.position.x, cop.position.z) + w_off) * sc
		c.draw_circle(cpp, 8.0 * k, Color(0.2, 0.4, 1.0))

	if not in_car:
		var cp := origin + (Vector2(car.position.x, car.position.z) + w_off) * sc
		c.draw_rect(Rect2(cp - Vector2(6, 6) * k, Vector2(12, 12) * k), Color(1, 0.2, 0.2))

	var p3 := car.position if in_car else player.position
	var pp := origin + (Vector2(p3.x, p3.z) + w_off) * sc
	var yaw := car.rotation.y if in_car else model.rotation.y
	var d := Vector2(-sin(yaw), -cos(yaw))
	var perp := Vector2(-d.y, d.x)
	var tri := PackedVector2Array([
		pp + d * 16.0 * k,
		pp - d * 10.0 * k + perp * 10.0 * k,
		pp - d * 10.0 * k - perp * 10.0 * k
	])
	c.draw_colored_polygon(tri, Color(0.2, 0.85, 1.0))


func _draw_mini() -> void:
	var sz := mini.size
	var ctr := sz * 0.5
	var p3 := car.position if in_car else player.position
	var ppos := Vector2(p3.x, p3.z)
	var sc := sz.x / 170.0
	mini.draw_rect(Rect2(Vector2.ZERO, sz), Color(0.1, 0.12, 0.15))
	_draw_map_content(mini, ctr, -ppos, sc, 1.0, Rect2(Vector2.ZERO, sz))
	mini.draw_rect(Rect2(Vector2.ZERO, sz), Color(1, 1, 1, 0.85), false, 4.0)
	_txt(mini, "N", Vector2(sz.x * 0.5, 22.0), 24)
	var ic := Vector2(sz.x - 34.0, sz.y - 34.0)
	mini.draw_rect(Rect2(ic - Vector2(22, 22), Vector2(44, 44)), Color(0, 0, 0, 0.6))
	mini.draw_line(ic + Vector2(-10, 0), ic + Vector2(10, 0), Color.WHITE, 4.0)
	mini.draw_line(ic + Vector2(0, -10), ic + Vector2(0, 10), Color.WHITE, 4.0)


func _draw_big() -> void:
	var s := _vp()
	var br := _big_rect()
	var sc := br.size.x / (MAP_HALF * 2.0)
	big.draw_rect(Rect2(Vector2.ZERO, s), Color(0, 0, 0, 0.82))
	big.draw_rect(br, Color(0.1, 0.12, 0.15))
	_draw_map_content(big, br.position, Vector2(MAP_HALF, MAP_HALF), sc, 1.7, br)
	big.draw_rect(br, Color(1, 1, 1, 0.9), false, 4.0)

	var cr := _close_rect()
	big.draw_rect(cr, Color(0.8, 0.2, 0.2, 0.9))
	_txt(big, "CLOSE", cr.position + cr.size * 0.5, 36)
	var kr := _clear_rect()
	big.draw_rect(kr, Color(0.25, 0.3, 0.4, 0.9))
	_txt(big, "CLEAR", kr.position + kr.size * 0.5, 36)

	var lx := br.position.x * 0.5
	_txt(big, "TAP THE MAP", Vector2(lx, 200.0), 40)
	_txt(big, "TO PICK A DESTINATION", Vector2(lx, 250.0), 28, Color(1, 1, 1, 0.7))
	if dest_set:
		_txt(big, "%d m" % int(_route_len()), Vector2(lx, 340.0), 64, Color(1, 0.8, 0.2))


# ---------------------------------------------------------------- map logic

func _set_map(open: bool) -> void:
	map_open = open
	big.visible = open
	if open:
		stick_id = -1
		stick_vec = Vector2.ZERO
		look_id = -1
		jump_id = -1
		fire_id = -1


func _set_wheel(open: bool) -> void:
	wheel_open = open
	wheel.visible = open
	if open:
		stick_id = -1
		stick_vec = Vector2.ZERO
		look_id = -1
		jump_id = -1
		fire_id = -1


func _set_dest(w: Vector2) -> void:
	dest = Vector2(clampf(w.x, -MAP_HALF, MAP_HALF), clampf(w.y, -MAP_HALF, MAP_HALF))
	dest_set = true
	dest_marker.position = Vector3(dest.x, 60.0, dest.y)
	dest_marker.visible = true
	_update_route()


func _clear_route() -> void:
	dest_set = false
	route.clear()
	dest_marker.visible = false


func _update_route() -> void:
	if not dest_set:
		return
	var p3 := car.position if in_car else player.position
	var p := Vector2(p3.x, p3.z)
	var path := astar.get_point_path(_node_for(p), _node_for(dest))
	route.clear()
	route.append(p)
	var start_i := 0
	if path.size() >= 2:
		var seg := path[1] - path[0]
		var t := (p - path[0]).dot(seg) / seg.length_squared()
		if t > 0.0 and t < 1.0 and (path[0] + seg * t).distance_to(p) < 9.0:
			start_i = 1
	for i in range(start_i, path.size()):
		route.append(path[i])
	route.append(dest)


func _route_len() -> float:
	var total := 0.0
	for i in range(route.size() - 1):
		total += route[i].distance_to(route[i + 1])
	return total


# ---------------------------------------------------------------- input

func _toggle_car() -> void:
	fire_id = -1
	if in_car:
		in_car = false
		player.position = car.position + car.global_transform.basis.x * 3.2 + Vector3(0, 0.3, 0)
		player.velocity = Vector3.ZERO
		player.visible = true
		player_col.set_deferred("disabled", false)
		model.rotation.y = car.rotation.y
		cam_pitch = 0.85
	else:
		in_car = true
		player.visible = false
		player_col.set_deferred("disabled", true)
		cam_pitch = 0.5
		cam_yaw = car.rotation.y
	_set_weapon(cur_weapon)


func _input(event: InputEvent) -> void:
	var half := _vp().x * 0.5
	if event is InputEventScreenTouch:
		var p: Vector2 = event.position
		if event.pressed:
			if map_open:
				if _close_rect().has_point(p):
					_set_map(false)
				elif _clear_rect().has_point(p):
					_clear_route()
				elif _big_rect().has_point(p):
					var sc := _big_rect().size.x / (MAP_HALF * 2.0)
					_set_dest((p - _big_rect().position) / sc - Vector2(MAP_HALF, MAP_HALF))
				return
			if wheel_open:
				for i in WEAPONS.size():
					if p.distance_to(_wheel_pos(i)) < 92.0:
						_set_weapon(i)
						break
				_set_wheel(false)
				return
			if dead:
				return
			if _mini_rect().has_point(p):
				_set_map(true)
				return
			if (in_car or near_car) and p.distance_to(_act_center()) < 95.0:
				_toggle_car()
				return
			if not in_car:
				if p.distance_to(_fire_center()) < 115.0:
					fire_id = event.index
					fire_queued = true
					return
				if p.distance_to(_wpn_center()) < 85.0:
					_set_wheel(true)
					return
			if p.distance_to(_jump_center()) < 100.0:
				jump_id = event.index
				if not in_car:
					want_jump = true
				return
			if p.x < half and stick_id == -1:
				stick_id = event.index
				stick_origin = p
				stick_vec = Vector2.ZERO
			elif p.x >= half and look_id == -1:
				look_id = event.index
		else:
			if event.index == stick_id:
				stick_id = -1
				stick_vec = Vector2.ZERO
			elif event.index == look_id:
				look_id = -1
			elif event.index == jump_id:
				jump_id = -1
			elif event.index == fire_id:
				fire_id = -1
	elif event is InputEventScreenDrag:
		if map_open or wheel_open:
			return
		if event.index == stick_id:
			stick_vec = (event.position - stick_origin).limit_length(RADIUS) / RADIUS
		elif event.index == look_id:
			cam_yaw -= event.relative.x * 0.005
			cam_pitch = clampf(cam_pitch + event.relative.y * 0.004, 0.2, 1.35)


# ---------------------------------------------------------------- physics

func _physics_process(delta: float) -> void:
	time += delta
	aim_t = maxf(aim_t - delta, 0.0)
	punch_t = maxf(punch_t - delta, 0.0)
	hurt_flash = maxf(hurt_flash - delta, 0.0)

	var input := stick_vec
	if input == Vector2.ZERO:
		input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dead:
		input = Vector2.ZERO

	near_car = (not in_car) and (not dead) and player.position.distance_to(car.position) < 6.0

	if in_car:
		_drive(delta, input, not dead, jump_id != -1)
		player.position = car.position
	else:
		_drive(delta, Vector2.ZERO, false, true)
		_walk(delta, input)

	if not in_car and not dead and cur_weapon > 0:
		var w: Dictionary = WEAPONS[cur_weapon]
		lock_node = _find_target(player.position + Vector3(0, 1.35, 0), cam_yaw, float(w["range"]), 0.9)
	else:
		lock_node = null

	_try_fire(delta)
	_update_peds(delta)
	_update_cops(delta)
	_update_wanted(delta)
	_update_camera(delta)

	if in_car and absf(car_speed) > 7.0 and not dead:
		for p in peds:
			if not p.dead and p.position.distance_to(car.position) < 2.8:
				_kill_ped(p)

	if dead:
		wasted_t -= delta
		if wasted_t <= 0.0:
			_respawn()
	elif stars == 0 and hp < 100.0:
		hp = minf(hp + 2.0 * delta, 100.0)

	route_timer += delta
	if dest_set and route_timer > 0.4:
		route_timer = 0.0
		_update_route()
		var p3 := car.position if in_car else player.position
		if Vector2(p3.x, p3.z).distance_to(dest) < 10.0:
			_clear_route()
			arrived_t = 3.0


func _walk(delta: float, input: Vector2) -> void:
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
	if aim_t > 0.0 and cur_weapon > 0:
		model.rotation.y = lerp_angle(model.rotation.y, cam_yaw, 1.0 - exp(-12.0 * delta))
	elif target.length() > 0.1:
		var want_yaw := atan2(-target.x, -target.z)
		model.rotation.y = lerp_angle(model.rotation.y, want_yaw, 1.0 - exp(-14.0 * delta))

	_animate(delta, player.is_on_floor())


func _drive(delta: float, input: Vector2, driven: bool, handbrake: bool) -> void:
	var prev_speed := car_speed
	var ratio := clampf(absf(car_speed) / CAR_MAX, 0.0, 1.0)
	var throttle := -input.y if driven else 0.0
	var steer_in := input.x if driven else 0.0
	steer_in = steer_in * 0.6 + steer_in * absf(steer_in) * 0.4

	if throttle > 0.05:
		if car_speed < -0.5:
			car_speed = move_toward(car_speed, 0.0, CAR_BRAKE * delta)
		else:
			car_speed += CAR_ACCEL * throttle * (1.0 - ratio * ratio) * delta
	elif throttle < -0.05:
		if car_speed > 0.5:
			car_speed = move_toward(car_speed, 0.0, CAR_BRAKE * (-throttle) * delta)
		else:
			car_speed = move_toward(car_speed, -12.0 * (-throttle), 8.0 * delta)
	else:
		car_speed = move_toward(car_speed, 0.0, 5.0 * delta)

	if handbrake:
		car_speed = move_toward(car_speed, 0.0, (28.0 if driven else 14.0) * delta)
	car_speed = clampf(car_speed, -14.0, CAR_MAX)

	var max_steer := lerpf(0.55, 0.09, pow(ratio, 0.6))
	car_steer = lerpf(car_steer, steer_in * max_steer, 1.0 - exp(-10.0 * delta))
	var rot_rate := car_speed / WHEELBASE * tan(car_steer)
	if handbrake and driven and absf(car_speed) > 8.0:
		rot_rate *= 1.6
	car.rotation.y -= rot_rate * delta

	var f := -car.global_transform.basis.z
	car.velocity.x = f.x * car_speed
	car.velocity.z = f.z * car_speed
	if car.is_on_floor():
		car.velocity.y = -1.0
	else:
		car.velocity.y -= GRAVITY * delta
	car.move_and_slide()
	car_speed = car.velocity.dot(f)

	var accel := (car_speed - prev_speed) / maxf(delta, 0.0001)
	car_accel_s = lerpf(car_accel_s, clampf(accel, -30.0, 30.0), 1.0 - exp(-6.0 * delta))
	car_visual.rotation.x = car_accel_s * 0.0035
	car_visual.rotation.z = lerpf(car_visual.rotation.z, car_steer * ratio * 0.25, 1.0 - exp(-8.0 * delta))

	for i in car_wheels.size():
		var w := car_wheels[i]
		w.rotation.x = fmod(w.rotation.x - car_speed * delta / WHEEL_R, TAU)
		if i < 2:
			w.rotation.y = -car_steer


func _update_camera(delta: float) -> void:
	var ratio := clampf(absf(car_speed) / CAR_MAX, 0.0, 1.0)
	var base := car.position if in_car else player.position
	var dist := 10.0
	var h := 1.8
	var follow := 14.0
	if in_car:
		dist = 14.0 + ratio * 2.0
		h = 1.8
		follow = 18.0
		if look_id == -1:
			cam_yaw = lerp_angle(cam_yaw, car.rotation.y, 1.0 - exp(-2.5 * delta))
	var tgt := base + Vector3(0, h, 0)
	var off := Vector3(0, 0, dist).rotated(Vector3.RIGHT, -cam_pitch).rotated(Vector3.UP, cam_yaw)
	cam.position = cam.position.lerp(tgt + off, 1.0 - exp(-follow * delta))
	cam.look_at(tgt)
	var fov_t := 70.0 + (14.0 * ratio if in_car else 0.0)
	cam.fov = lerpf(cam.fov, fov_t, 1.0 - exp(-4.0 * delta))


# ---------------------------------------------------------------- animation

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

	var arm_l_t := -swing * 1.1 + sway
	var arm_r_t := swing * 1.1 - sway
	if aim_t > 0.0 and cur_weapon > 0:
		arm_r_t = 1.5
		arm_l_t = 1.2
	if punch_t > 0.0:
		arm_r_t = 1.6

	leg_l.rotation.x = lerpf(leg_l.rotation.x, swing, k)
	leg_r.rotation.x = lerpf(leg_r.rotation.x, -swing, k)
	arm_l.rotation.x = lerpf(arm_l.rotation.x, arm_l_t, k)
	arm_r.rotation.x = lerpf(arm_r.rotation.x, arm_r_t, k)
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
