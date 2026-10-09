extends Node3D

# ===================== الملفات (كلها اختيارية) =====================
const GLB_PATH := "res://game/character.glb"
const GLB_YAW := PI
const CHAR_HEIGHT := 1.8
const CHAR_SCALE_MANUAL := 0.0
const CAR_GLB_PATH := "res://game/car.glb"
const CAR_GLB_YAW := PI
const POLICE_GLB_PATH := "res://game/police.glb"
const POLICE_GLB_YAW := PI
const OFFICER_GLB_PATH := "res://game/peds/officer.glb"
const PED_GLB_COUNT := 6
const PED_GLB_YAW := PI
const WEAPON_GLB_DIR := "res://game/weapons/"
const WEAPON_GLB_YAW := 0.0
const BULLET_DIR := "res://game/bullets/"
const BULLET_GLB_YAW := 0.0
const BULLET_GLB_SPEED := 90.0
const BULLET_LEN := 0.35
const PHONE_GLB_PATH := "res://game/phone.glb"
const PHONE_GLB_YAW := 0.0
const PHONE_HAND_POS := Vector3(0.0, 0.07, 0.03)
const PHONE_HAND_ROT := Vector3(0.0, 0.0, 0.0)
const PHONE_X_FRAC := 0.70
const ANIM_DIR := "res://game/anims/"
const SND_DIR := "res://game/sounds/"
const GUN_HAND_POS := Vector3(0.0, 0.08, 0.02)
const GUN_HAND_ROT := Vector3(90.0, 0.0, 0.0)
const WEAPON_ANIM_TAGS := [[], ["pistol", "w1"], ["smg", "w2"], ["shotgun", "w3"], ["rifle", "w4"]]
const ARM_POSE := [[0.0, 0.0, 0.0], [1.5, 0.2, 0.0], [1.45, 1.2, 0.08], [1.3, 1.0, 0.1], [1.55, 1.35, 0.12]]

const CAR_LENGTH := 5.4
const POLICE_LENGTH := 5.2
const CAR_SCALE := 1.25
const WHEEL_R := 0.475

const MAX_SPEED := 8.5
const RUN_SPEED := 4.5
const JUMP_V := 9.0
const GRAVITY := 25.0
const RADIUS := 110.0
const BLOCK := 54.0
const ROAD_MAX := 162.0

const CAR_MAX := 45.0
const CAR_ACCEL := 16.0
const CAR_BRAKE := 32.0
const WHEELBASE := 4.2
const GAUGE_MAX := 220.0
const MAP_HALF := 180.0
const MINI_SIZE := 300.0
const MINI_VIEW := 160.0

const PED_COUNT := 24
const MAX_STARS := 5
const COP_MAX := 31.0
const BULLET_SPEED := 260.0

const WEAPON_FILES := ["", "pistol", "smg", "shotgun", "rifle"]
const WEAPONS := [
	{"name": "FISTS", "dmg": 15.0, "rate": 0.45, "auto": false, "pellets": 1, "spread": 0.0, "range": 2.3, "len": 0.0},
	{"name": "PISTOL", "dmg": 26.0, "rate": 0.28, "auto": false, "pellets": 1, "spread": 0.012, "range": 80.0, "len": 0.3},
	{"name": "SMG", "dmg": 11.0, "rate": 0.075, "auto": true, "pellets": 1, "spread": 0.045, "range": 70.0, "len": 0.5},
	{"name": "SHOTGUN", "dmg": 13.0, "rate": 0.85, "auto": false, "pellets": 8, "spread": 0.09, "range": 35.0, "len": 0.8},
	{"name": "RIFLE", "dmg": 20.0, "rate": 0.11, "auto": true, "pellets": 1, "spread": 0.02, "range": 110.0, "len": 0.9},
]
const MAG_SIZE := [0, 12, 30, 6, 30]
const DEFAULT_RES := [0, 60, 180, 24, 120]
const RECOIL := [0.0, 0.035, 0.012, 0.06, 0.02]
const FLASH_SIZE := [0.0, 0.8, 1.0, 1.5, 1.2]
const TRACER_COL := [Color.WHITE, Color(1.0, 0.85, 0.45), Color(1.0, 0.7, 0.3), Color(1.0, 0.9, 0.6), Color(1.0, 0.95, 0.7)]
const APP_NAMES := ["MAP", "MY CAR", "GUNS", "TAXI", "CAMERA", "PHOTOS", "CLOCK", "STORE", "SETTINGS"]


class ArmIK extends SkeletonModifier3D:
	var ok := false
	var legs_ok := false
	var b_ur := -1
	var b_fr := -1
	var b_hr := -1
	var b_ul := -1
	var b_fl := -1
	var b_hl := -1
	var b_tr := -1
	var b_cr := -1
	var b_pr := -1
	var b_tl := -1
	var b_cl := -1
	var b_pl := -1
	var rmode := 0
	var lmode := 0
	var rw := 0.0
	var lw := 0.0
	var leg_w := 0.0
	var phase := 0.0
	var swing := 0.5
	var aim_dir := Vector3.FORWARD
	var fwd := Vector3.FORWARD
	var side := Vector3.RIGHT

	func _set(is_right: bool, role: String, i: int) -> void:
		if is_right:
			if role == "u" and b_ur < 0: b_ur = i
			elif role == "f" and b_fr < 0: b_fr = i
			elif role == "h" and b_hr < 0: b_hr = i
			elif role == "t" and b_tr < 0: b_tr = i
			elif role == "c" and b_cr < 0: b_cr = i
			elif role == "p" and b_pr < 0: b_pr = i
		else:
			if role == "u" and b_ul < 0: b_ul = i
			elif role == "f" and b_fl < 0: b_fl = i
			elif role == "h" and b_hl < 0: b_hl = i
			elif role == "t" and b_tl < 0: b_tl = i
			elif role == "c" and b_cl < 0: b_cl = i
			elif role == "p" and b_pl < 0: b_pl = i

	func setup(sk: Skeleton3D) -> void:
		var re := RegEx.new()
		re.compile("[_.]\\d{3}$")
		for i in sk.get_bone_count():
			var l := re.sub(sk.get_bone_name(i).to_lower(), "")
			if l.contains("thumb") or l.contains("index") or l.contains("middle") or l.contains("ring") or l.contains("pinky") or l.contains("finger"):
				continue
			if l.contains("twist") or l.contains("roll") or l.contains("helper") or l.contains("shoulder") or l.contains("clav") or l.contains("toe"):
				continue
			var right := l.contains("right") or l.ends_with("_r") or l.ends_with(".r") or l.contains("_r_")
			var left := l.contains("left") or l.ends_with("_l") or l.ends_with(".l") or l.contains("_l_")
			if not right and not left:
				continue
			var role := ""
			if l.contains("forearm") or l.contains("lowerarm") or l.contains("fore_arm"):
				role = "f"
			elif l.contains("hand"):
				role = "h"
			elif l.contains("upleg") or l.contains("thigh") or l.contains("upperleg"):
				role = "t"
			elif l.contains("foot"):
				role = "p"
			elif l.contains("leg") or l.contains("calf") or l.contains("shin"):
				role = "c"
			elif l.contains("arm"):
				role = "u"
			if role == "":
				continue
			_set(right, role, i)
		ok = b_ur >= 0 and b_fr >= 0 and b_hr >= 0
		legs_ok = b_tr >= 0 and b_cr >= 0 and b_pr >= 0 and b_tl >= 0 and b_cl >= 0 and b_pl >= 0

	func _process_modification() -> void:
		_run()

	func _process_modification_with_delta(_delta: float) -> void:
		_run()

	func _run() -> void:
		var sk := get_skeleton()
		if sk == null:
			return
		if ok:
			_arm(sk, b_ur, b_fr, b_hr, rmode, rw, false)
			_arm(sk, b_ul, b_fl, b_hl, lmode, lw, true)
		if legs_ok and leg_w > 0.01:
			_leg(sk, b_tr, b_cr, b_pr, phase, leg_w)
			_leg(sk, b_tl, b_cl, b_pl, phase + PI, leg_w)

	func _arm(sk: Skeleton3D, bu: int, bf: int, bh: int, mode: int, w: float, is_left: bool) -> void:
		if w <= 0.01 or mode == 0 or bu < 0 or bf < 0 or bh < 0:
			return
		var inv := sk.global_transform.basis.inverse()
		var du := Vector3.DOWN
		var df := Vector3.DOWN
		if mode == 1:
			du = aim_dir
			df = aim_dir
			if is_left:
				du = (aim_dir + side * 0.18).normalized()
				df = (aim_dir + side * 0.1).normalized()
		elif mode == 2:
			var sd := -0.12 if is_left else 0.12
			du = (Vector3.DOWN + side * sd).normalized()
			df = (Vector3.DOWN + side * sd * 0.5 + fwd * 0.12).normalized()
		elif mode == 4:
			var sgn := -1.0 if is_left else 1.0
			var a := sin(phase + (0.0 if is_left else PI)) * swing * 0.7
			var a2 := a + 0.25 + swing * 0.55
			du = (Vector3.DOWN * cos(a) + fwd * sin(a) + side * sgn * 0.12).normalized()
			df = (Vector3.DOWN * cos(a2) + fwd * sin(a2) + side * sgn * 0.06).normalized()
		else:
			du = (Vector3.DOWN * 0.8 + fwd * 0.5).normalized()
			df = (Vector3.UP * 0.7 + fwd * 0.6 - side * 0.3).normalized()
		_point(sk, bu, bf, (inv * du).normalized(), w)
		_point(sk, bf, bh, (inv * df).normalized(), w)

	func _leg(sk: Skeleton3D, bt: int, bc: int, bp: int, ph: float, w: float) -> void:
		var inv := sk.global_transform.basis.inverse()
		var a := sin(ph) * swing * 0.9
		var bend := maxf(cos(ph), 0.0) * (0.35 + swing * 0.9)
		var b := a - bend
		var du := (Vector3.DOWN * cos(a) + fwd * sin(a)).normalized()
		var df := (Vector3.DOWN * cos(b) + fwd * sin(b)).normalized()
		_point(sk, bt, bc, (inv * du).normalized(), w)
		_point(sk, bc, bp, (inv * df).normalized(), w)

	func _point(sk: Skeleton3D, b: int, child: int, target: Vector3, w: float) -> void:
		var pose: Transform3D = sk.get_bone_global_pose(b)
		var cp: Transform3D = sk.get_bone_global_pose(child)
		var cur := cp.origin - pose.origin
		if cur.length() < 0.0001:
			return
		cur = cur.normalized()
		var q := Quaternion(cur, target)
		var sc := pose.basis.get_scale()
		var ob := pose.basis.orthonormalized()
		var nb := (Basis(q) * ob).orthonormalized()
		var rb := ob.slerp(nb, w)
		pose.basis = Basis(rb.x * sc.x, rb.y * sc.y, rb.z * sc.z)
		sk.set_bone_global_pose(b, pose)


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
	var anim: AnimationPlayer
	var anims := {}
	var a_walk := ""
	var a_run := ""
	var a_idle := ""
	var a_cur := ""
	var anim_ok := false
	var ckey := ""
	var ik: ArmIK
	var prop: Node3D
	var prop_par: Node3D


class Cop extends CharacterBody3D:
	var hp := 160.0
	var dead := false
	var speed := 0.0
	var path := PackedVector2Array()
	var path_i := 0
	var repath := 0.0
	var stuck_t := 0.0
	var reverse_t := 0.0
	var leave_t := 0.0
	var abandon_t := 0.0
	var crew := 2
	var outs: Array = []
	var siren: AudioStreamPlayer3D
	var mat_a: StandardMaterial3D
	var mat_b: StandardMaterial3D


class Officer extends Ped:
	var home: Cop
	var shoot_cd := 1.0
	var leave_t := 0.0
	var far_t := 0.0
	var fire_t := 0.0
	var aiming := false
	var moving := false


var player: CharacterBody3D
var player_col: CollisionShape3D
var model: Node3D
var char_skeleton: Skeleton3D
var player_ik: ArmIK
var hold_parent: Node3D
var hand_scaled := false
var gun_node: Node3D
var gun_mesh: MeshInstance3D
var gun_visuals: Array[Node3D] = []
var phone_node: Node3D
var cam: Camera3D
var ui: Control
var mini_panel: Panel
var mini: Control
var big: Control
var wheel: Control
var pc: Control

var cam_yaw := 0.0
var cam_pitch := 0.18
var aim_pitch := 0.1
var aim_blend := 0.0
var recoil := 0.0
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
var ik_phase := 0.0

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
var a_aim := ""
var a_cur := ""
var weapon_anims := {}
var fire_anim_t := 0.0
var raise_t := 0.0
var prev_armed := false
var hand_bone_name := ""
var char_scale_dbg := ""
var anim_files := 0
var anim_total := 0
var anim_kept := 0
var anim_src := {}
var anim_cache := {}
var anim_flags := {}
var anim_stats := {}
var anim_miss := {}
var suffix_re := RegEx.new()

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
var phone_open := false
var phone_t := 0.0
var phone_scale := 0.55
var phone_raise_t := 0.0
var bld_rects: Array[Rect2] = []
var block_rects: Array[Rect2] = []
var dest_set := false
var dest := Vector2.ZERO
var route: Array[Vector2] = []
var route_timer := 0.0
var astar := AStar2D.new()
var dest_marker: MeshInstance3D
var arrived_t := 0.0
var toast_msg := ""
var toast_t := 0.0

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
var shot_count := 0

var peds: Array[Ped] = []
var cops: Array[Cop] = []
var officers: Array[Officer] = []
var stars := 0
var wanted_cool := 0.0
var evade_t := 0.0
var spawn_t := 0.0
var ped_spawn_t := 0.0

var fx: Array[Dictionary] = []
var tr_mat_c: StandardMaterial3D
var tracer_mats: Array[StandardMaterial3D] = []
var bullet_tmpl: Array[Node3D] = []
var flash_mat: StandardMaterial3D
var spark_mat: StandardMaterial3D
var brass_mat: StandardMaterial3D
var flash_cone: CylinderMesh
var flash_core: SphereMesh
var spark_mesh: SphereMesh
var smoke_mesh: SphereMesh
var casing_mesh: BoxMesh

var sfx := {}
var engine_snd: AudioStreamPlayer
var skid_snd: AudioStreamPlayer
var step_t := 0.0
var scream_cd := 0.0
var crash_cd := 0.0

var ped_torso_mesh: BoxMesh
var ped_head_mesh: SphereMesh
var ped_leg_mesh: BoxMesh
var ped_arm_mesh: BoxMesh
var shirt_mats: Array[StandardMaterial3D] = []
var skin_mats: Array[StandardMaterial3D] = []
var pant_mat: StandardMaterial3D
var off_shirt: StandardMaterial3D
var off_pants: StandardMaterial3D
var ped_glbs: Array[String] = []

var sb_body: StyleBoxFlat
var sb_screen: StyleBoxFlat
var sb_notch: StyleBoxFlat
var sb_apps: Array[StyleBoxFlat] = []
var sb_pill: StyleBoxFlat
var sb_btn: StyleBoxFlat
var sb_map: StyleBoxFlat
var apps = null


func _ready() -> void:
	randomize()
	suffix_re.compile("[_.]\\d{3}$")
	_init_assets()
	_load_anim_sources()
	_build_sounds()
	_build_bullet_templates()
	_build_world()
	_build_city()
	_build_player()
	_build_car()
	_build_ui()
	_build_marker()
	_set_weapon(1, false)
	for i in PED_COUNT:
		_spawn_ped()
	var ikt := "IK: YES" if (player_ik != null and player_ik.ok) else "IK: NO"
	var lgt := "LEGS: YES" if (player_ik != null and player_ik.legs_ok) else "LEGS: NO"
	var lines: Array[String] = []
	lines.append("%s | %s | HAND: %s | %s" % [ikt, lgt, hand_bone_name if hand_bone_name != "" else "NOT FOUND", char_scale_dbg])
	lines.append("ANIM FILES: %d | TRACKS: %d/%d" % [anim_files, anim_kept, anim_total])
	var st: Dictionary = anim_stats.get("player", {})
	for k in ["0_idle", "0_walk", "0_run"]:
		if st.has(k):
			lines.append("%s  %s" % [k, st[k]])
		else:
			lines.append("%s  MISSING" % k)
	var miss: Dictionary = anim_miss.get("player", {})
	if miss.has("0_walk") and not (miss["0_walk"] as Array).is_empty():
		lines.append("WALK MISS: " + ", ".join(PackedStringArray(miss["0_walk"])))
	if char_skeleton != null:
		var names: Array[String] = []
		for i in char_skeleton.get_bone_count():
			var bn := char_skeleton.get_bone_name(i)
			var lw := bn.to_lower()
			if (lw.contains("arm") or lw.contains("leg")) and names.size() < 4:
				names.append(bn)
		lines.append("CHAR BONES: " + ", ".join(PackedStringArray(names)))
	_toast("\n".join(PackedStringArray(lines)), 16.0)
	if ResourceLoader.exists("res://game/apps.gd"):
		var sc = load("res://game/apps.gd")
		if sc != null:
			apps = Node.new()
			apps.set_script(sc)
			apps.set("g", self)
			add_child(apps)


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


func _additive(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
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


func _phone_btn_center() -> Vector2:
	return Vector2(100, 110)


func _mini_rect() -> Rect2:
	var s := _vp()
	return Rect2(s.x - MINI_SIZE - 40.0, 40.0, MINI_SIZE, MINI_SIZE)


func _big_rect() -> Rect2:
	var s := _vp()
	var d := s.y - 48.0
	return Rect2((s.x - d) / 2.0, 24.0, d, d)


func _close_rect() -> Rect2:
	return Rect2(_vp().x - 280.0, 30.0, 240.0, 90.0)


func _clear_rect() -> Rect2:
	return Rect2(_vp().x - 280.0, 140.0, 240.0, 90.0)


func _prect() -> Rect2:
	var s := _vp()
	var sz := Vector2(440.0, 900.0) * phone_scale
	var k := phone_t * phone_t * (3.0 - 2.0 * phone_t)
	var y := lerpf(s.y + 30.0, s.y - sz.y - 20.0, k)
	return Rect2(s.x * PHONE_X_FRAC - sz.x * 0.5, y, sz.x, sz.y)


func _icon_rect(i: int) -> Rect2:
	var col := i % 3
	var row := i / 3
	return Rect2(46.0 + float(col) * 128.0, 190.0 + float(row) * 160.0, 104.0, 104.0)


func _wheel_pos(i: int) -> Vector2:
	var a := -PI * 0.5 + TAU * float(i) / float(WEAPONS.size())
	return _vp() * 0.5 + Vector2(cos(a), sin(a)) * 250.0


func _txt(c: Control, t: String, p: Vector2, size: int, col: Color = Color.WHITE) -> void:
	c.draw_string(ThemeDB.fallback_font, p + Vector2(-150.0, size * 0.35), t, HORIZONTAL_ALIGNMENT_CENTER, 300, size, col)


func _toast(m: String, t: float = 2.5) -> void:
	toast_msg = m
	toast_t = t


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
	if ix < 3:
		r.append(Vector2i(ix + 1, iz))
	if iz > -3:
		r.append(Vector2i(ix, iz - 1))
	if iz < 3:
		r.append(Vector2i(ix, iz + 1))
	return r


func _snap_to_road(w: Vector2) -> Vector2:
	var rx := clampf(roundf(w.x / BLOCK) * BLOCK, -ROAD_MAX, ROAD_MAX)
	var rz := clampf(roundf(w.y / BLOCK) * BLOCK, -ROAD_MAX, ROAD_MAX)
	if absf(w.x - rx) < absf(w.y - rz):
		return Vector2(rx, clampf(w.y, -ROAD_MAX, ROAD_MAX))
	return Vector2(clampf(w.x, -ROAD_MAX, ROAD_MAX), rz)


func _first(list: Array) -> String:
	for s in list:
		if String(s) != "":
			return String(s)
	return ""


func _init_assets() -> void:
	tr_mat_c = _additive(Color(1.0, 0.45, 0.25))
	for i in WEAPONS.size():
		tracer_mats.append(_additive(TRACER_COL[i]))
	flash_mat = _additive(Color(1.0, 0.8, 0.45, 0.95))
	spark_mat = _additive(Color(1.0, 0.8, 0.35))
	brass_mat = _mat(Color(0.85, 0.65, 0.2))
	brass_mat.metallic = 0.9
	brass_mat.roughness = 0.3
	flash_cone = CylinderMesh.new()
	flash_cone.top_radius = 0.0
	flash_cone.bottom_radius = 0.08
	flash_cone.height = 0.3
	flash_core = _spherem(0.07)
	spark_mesh = _spherem(0.022)
	smoke_mesh = _spherem(0.07)
	casing_mesh = _boxm(Vector3(0.016, 0.016, 0.055))

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
	off_shirt = _mat(Color(0.1, 0.18, 0.45))
	off_pants = _mat(Color(0.05, 0.07, 0.15))
	for i in range(1, PED_GLB_COUNT + 1):
		var path := "res://game/peds/ped%d.glb" % i
		if ResourceLoader.exists(path):
			ped_glbs.append(path)

	sb_body = StyleBoxFlat.new()
	sb_body.bg_color = Color(0.03, 0.03, 0.05)
	sb_body.set_corner_radius_all(64)
	sb_body.border_color = Color(0.55, 0.55, 0.62)
	sb_body.set_border_width_all(6)
	sb_screen = StyleBoxFlat.new()
	sb_screen.bg_color = Color(0.07, 0.1, 0.22)
	sb_screen.set_corner_radius_all(46)
	sb_notch = StyleBoxFlat.new()
	sb_notch.bg_color = Color(0.0, 0.0, 0.0)
	sb_notch.set_corner_radius_all(13)
	var icol := [
		Color(0.2, 0.75, 0.45), Color(0.25, 0.5, 0.95), Color(0.95, 0.75, 0.2), Color(0.95, 0.55, 0.15),
		Color(0.55, 0.45, 0.9), Color(0.9, 0.4, 0.6), Color(0.3, 0.3, 0.38), Color(0.2, 0.7, 0.8), Color(0.5, 0.5, 0.55)
	]
	for c in icol:
		var sb := StyleBoxFlat.new()
		sb.bg_color = c
		sb.set_corner_radius_all(28)
		sb_apps.append(sb)
	sb_pill = StyleBoxFlat.new()
	sb_pill.bg_color = Color(0.05, 0.06, 0.08, 0.7)
	sb_pill.set_corner_radius_all(22)
	sb_pill.border_color = Color(1, 1, 1, 0.8)
	sb_pill.set_border_width_all(2)
	sb_btn = StyleBoxFlat.new()
	sb_btn.bg_color = Color(1, 1, 1, 0.12)
	sb_btn.set_corner_radius_all(26)
	sb_btn.border_color = Color(1, 1, 1, 0.9)
	sb_btn.set_border_width_all(3)
	sb_map = StyleBoxFlat.new()
	sb_map.bg_color = Color(0.05, 0.06, 0.08, 0.96)
	sb_map.set_corner_radius_all(28)
	sb_map.border_color = Color(1, 1, 1, 0.9)
	sb_map.set_border_width_all(4)


func _build_bullet_templates() -> void:
	bullet_tmpl.append(null)
	for i in range(1, WEAPONS.size()):
		var path := BULLET_DIR + String(WEAPON_FILES[i]) + ".glb"
		bullet_tmpl.append(_fit_glb(path, BULLET_GLB_YAW, BULLET_LEN, false, false))


# ---------------------------------------------------------------- glb helpers

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


func _fit_glb(path: String, yaw: float, target: float, by_height: bool, ground: bool) -> Node3D:
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
	var len := bb.size.y
	if not by_height:
		len = bb.size.z
		if bb.size.x > bb.size.z:
			base_yaw = PI * 0.5
			len = bb.size.x
	var s := target / maxf(len, 0.001)
	var py := -bb.position.y
	if not ground:
		py = -(bb.position.y + bb.size.y * 0.5)
	inst.position = Vector3(-(bb.position.x + bb.size.x * 0.5), py, -(bb.position.z + bb.size.z * 0.5))
	holder.scale = Vector3.ONE * s
	holder.rotation.y = base_yaw + yaw
	return holder


func _find_skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n as Skeleton3D
	for c in n.get_children():
		var r := _find_skeleton(c)
		if r != null:
			return r
	return null


func _bone_range(sk: Skeleton3D, holder: Node3D) -> Vector2:
	var xf := Transform3D.IDENTITY
	var n: Node = sk
	var stop := holder.get_parent()
	while n != null and n != stop:
		if n is Node3D:
			xf = (n as Node3D).transform * xf
		n = n.get_parent()
	var mn := 1e9
	var mx := -1e9
	for i in sk.get_bone_count():
		var y := (xf * sk.get_bone_global_rest(i).origin).y
		mn = minf(mn, y)
		mx = maxf(mx, y)
	return Vector2(mn, mx)


func _fit_by_bones(holder: Node3D, sk: Skeleton3D, target_h: float) -> void:
	if sk == null:
		return
	var pad := 1.07
	for i in sk.get_bone_count():
		var l := sk.get_bone_name(i).to_lower()
		if l.contains("headtop") or l.contains("head_end") or l.contains("headend"):
			pad = 1.0
	var mm := _bone_range(sk, holder)
	var h := mm.y - mm.x
	if h < 0.0001:
		return
	holder.scale *= target_h / (h * pad)
	var mm2 := _bone_range(sk, holder)
	holder.position.y -= mm2.x


func _find_hand_bone(sk: Skeleton3D) -> String:
	for i in sk.get_bone_count():
		var n := sk.get_bone_name(i)
		var l := n.to_lower()
		if not l.contains("hand"):
			continue
		if l.contains("thumb") or l.contains("index") or l.contains("middle") or l.contains("ring") or l.contains("pinky") or l.contains("finger"):
			continue
		var right := l.contains("right") or l.ends_with("_r") or l.ends_with(".r") or l.contains("r_hand") or l.contains("hand_r") or l.contains("hand.r")
		if right:
			return n
	return ""


func _find_anim(ap: AnimationPlayer, keys: Array) -> String:
	for n in ap.get_animation_list():
		var l := String(n).to_lower()
		for k in keys:
			if l.contains(k):
				return String(n)
	return ""


func _set_loop(ap: AnimationPlayer, n: String) -> void:
	if n != "":
		ap.get_animation(n).loop_mode = Animation.LOOP_LINEAR


# ---------------------------------------------------------------- animations (FBX / GLB files)

func canon(n: String) -> String:
	var l := n.to_lower()
	if l.contains(":"):
		l = l.get_slice(":", l.get_slice_count(":") - 1)
	for pre in ["mixamorig", "bip001", "bip01", "def-", "def_", "cc_base_", "jnt_"]:
		l = l.replace(pre, "")
	l = suffix_re.sub(l, "")
	var side := ""
	if l.contains("left"):
		side = "l"
		l = l.replace("left", "")
	elif l.contains("right"):
		side = "r"
		l = l.replace("right", "")
	else:
		for suf in ["_l", ".l", "-l"]:
			if l.ends_with(suf):
				side = "l"
				l = l.trim_suffix(suf)
		for suf in ["_r", ".r", "-r"]:
			if l.ends_with(suf):
				side = "r"
				l = l.trim_suffix(suf)
	var o := ""
	for ch in l:
		if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9"):
			o += ch
	for pair in [["upperarm", "arm"], ["lowerarm", "forearm"], ["clavicle", "shoulder"], ["pelvis", "hips"], ["thigh", "upleg"], ["upperleg", "upleg"], ["calf", "leg"], ["shin", "leg"], ["lowerleg", "leg"], ["spine01", "spine"], ["spine02", "spine1"], ["spine03", "spine2"], ["neck01", "neck"], ["toes", "toebase"], ["ball", "toebase"]]:
		if o == pair[0]:
			o = pair[1]
	return side + o


func _anim_parse(low: String) -> Array:
	var skip := ["crouch", "offset", "d90", "u90", "root_motion", "bwd", "back", "left", "right", "strafe", "turn"]
	for s in skip:
		if low.contains(s):
			return []
	var widx := 0
	for i in range(1, WEAPONS.size()):
		for tag in WEAPON_ANIM_TAGS[i]:
			if low.contains(String(tag)):
				widx = i
	if low.contains("phone") or low.contains("call") or low.contains("text"):
		widx = 9
	var base := ""
	if low.contains("raise") or low.contains("draw") or low.contains("equip") or low.contains("unholster"):
		base = "raise"
	elif low.contains("fire") or low.contains("shoot"):
		base = "fire"
	elif low.contains("aim"):
		base = "aim"
	elif low.contains("idle"):
		base = "idle"
	elif low.contains("jump") or low.contains("fall"):
		base = "jump"
	elif low.contains("sprint") or low.contains("run") or low.contains("jog"):
		base = "run"
	elif low.contains("walk"):
		base = "walk"
	if base == "" and widx == 9:
		base = "raise"
	if base == "" and widx > 0:
		base = "aim"
	if base == "":
		return []
	return [widx, base]


func _load_anim_sources() -> void:
	var da := DirAccess.open(ANIM_DIR)
	if da == null:
		return
	var seen := {}
	for f in da.get_files():
		var fn := String(f)
		if fn.ends_with(".import"):
			fn = fn.trim_suffix(".import")
		elif fn.ends_with(".remap"):
			fn = fn.trim_suffix(".remap")
		var low := fn.to_lower()
		if not (low.ends_with(".fbx") or low.ends_with(".glb") or low.ends_with(".gltf")):
			continue
		if seen.has(fn):
			continue
		seen[fn] = true
		var parsed := _anim_parse(low)
		if parsed.is_empty():
			continue
		var key := "%d_%s" % [parsed[0], parsed[1]]
		if anim_src.has(key):
			continue
		var scn := load(ANIM_DIR + fn) as PackedScene
		if scn == null:
			continue
		var inst := scn.instantiate()
		var src := inst.find_child("AnimationPlayer", true, false) as AnimationPlayer
		if src != null:
			var best: Animation = null
			for n in src.get_animation_list():
				if String(n) == "RESET":
					continue
				var a := src.get_animation(n)
				if best == null or a.length > best.length:
					best = a
			if best != null:
				anim_src[key] = best
				anim_files += 1
		inst.free()


func _retarget(ap: AnimationPlayer, sk: Skeleton3D, ckey: String) -> Dictionary:
	var result := {}
	if sk == null or anim_src.is_empty():
		return result
	if not ap.has_animation_library(""):
		ap.add_animation_library("", AnimationLibrary.new())
	var lib := ap.get_animation_library("")
	if anim_cache.has(ckey):
		var cached: Dictionary = anim_cache[ckey]
		for k in cached.keys():
			lib.add_animation("x_" + String(k), cached[k])
			result[k] = "x_" + String(k)
		return result

	var base := ap.get_node(ap.root_node)
	var sk_path := str(base.get_path_to(sk))
	var bone_map := {}
	for i in sk.get_bone_count():
		var bn := sk.get_bone_name(i)
		bone_map[canon(bn)] = bn
	var store := {}
	var flags := {}
	var stats := {}
	var misses := {}
	for k in anim_src.keys():
		var anim := (anim_src[k] as Animation).duplicate() as Animation
		var tot := anim.get_track_count()
		var arm_n := 0
		var leg_n := 0
		var miss: Array = []
		for t in range(tot - 1, -1, -1):
			var ttype := anim.track_get_type(t)
			var tp := anim.track_get_path(t)
			if ttype != Animation.TYPE_ROTATION_3D or tp.get_subname_count() == 0:
				anim.remove_track(t)
				continue
			var raw := tp.get_subname(0)
			var nb := canon(raw)
			if not bone_map.has(nb):
				if miss.size() < 4:
					miss.append(raw)
				anim.remove_track(t)
				continue
			if nb in ["rarm", "larm", "rforearm", "lforearm"]:
				arm_n += 1
			elif nb in ["rupleg", "lupleg", "rleg", "lleg"]:
				leg_n += 1
			anim.track_set_path(t, NodePath(sk_path + ":" + String(bone_map[nb])))
		var kept := anim.get_track_count()
		var arms := arm_n >= 2
		var legs := leg_n >= 2
		stats[k] = "%d/%d A:%s L:%s" % [kept, tot, "Y" if arms else "N", "Y" if legs else "N"]
		misses[k] = miss
		if ckey == "player":
			anim_total += tot
			anim_kept += kept
		if kept < 6:
			continue
		var base_name := String(k).get_slice("_", 1)
		var looped := base_name in ["idle", "aim", "walk", "run"]
		anim.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
		var aname := "x_" + String(k)
		lib.add_animation(aname, anim)
		store[k] = anim
		flags[aname] = [arms, legs]
		result[k] = aname
	anim_cache[ckey] = store
	anim_flags[ckey] = flags
	anim_stats[ckey] = stats
	anim_miss[ckey] = misses
	return result


func _flags(ckey: String, aname: String) -> Array:
	if aname == "":
		return [false, false]
	var d: Dictionary = anim_flags.get(ckey, {})
	if d.has(aname):
		return d[aname]
	return [true, true]


func _wa(w: int, base: String) -> String:
	return String(weapon_anims.get("%d_%s" % [w, base], ""))


func _any(base: String) -> String:
	for i in range(1, WEAPONS.size()):
		var n := _wa(i, base)
		if n != "":
			return n
	return ""


func _wx(w: int, base: String) -> String:
	return _first([_wa(w, base), _wa(0, base), _any(base)])


func _setup_anim(p: Ped, root: Node3D, ckey: String) -> void:
	p.ckey = ckey
	var sk := _find_skeleton(root)
	_fit_by_bones(root, sk, 1.8)
	p.anim = root.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if p.anim == null and sk != null:
		p.anim = AnimationPlayer.new()
		root.add_child(p.anim)
	if p.anim == null:
		return
	p.a_walk = _find_anim(p.anim, ["walk"])
	p.a_run = _find_anim(p.anim, ["run", "sprint", "jog"])
	p.a_idle = _find_anim(p.anim, ["idle", "stand"])
	_set_loop(p.anim, p.a_walk)
	_set_loop(p.anim, p.a_run)
	_set_loop(p.anim, p.a_idle)
	var res := _retarget(p.anim, sk, ckey)
	if not res.is_empty():
		p.anims = res
		var g := String(res.get("0_idle", ""))
		if g != "":
			p.a_idle = g
		g = String(res.get("0_walk", ""))
		if g != "":
			p.a_walk = g
		g = String(res.get("0_run", ""))
		if g != "":
			p.a_run = g
	if p.a_run == "":
		p.a_run = p.a_walk
	p.anim_ok = p.a_idle != "" or p.a_walk != ""
	if sk != null:
		var ik := ArmIK.new()
		sk.add_child(ik)
		ik.setup(sk)
		p.ik = ik
		if p is Officer:
			_give_gun(p, sk)


func _give_gun(p: Ped, sk: Skeleton3D) -> void:
	var hb := _find_hand_bone(sk)
	if hb == "":
		return
	var att := BoneAttachment3D.new()
	sk.add_child(att)
	att.bone_name = hb
	var holder := Node3D.new()
	holder.rotation_degrees = Vector3(90, 0, 0)
	att.add_child(holder)
	var mi := MeshInstance3D.new()
	mi.mesh = _boxm(Vector3(0.05, 0.12, 0.22))
	mi.position = Vector3(0, 0, -0.1)
	mi.material_override = _mat(Color(0.07, 0.07, 0.09))
	holder.add_child(mi)
	p.prop = holder
	p.prop_par = att


func _ped_play(p: Ped, want: String) -> void:
	if p.anim == null or want == "" or want == p.a_cur:
		return
	p.a_cur = want
	p.anim.play(want, 0.2)


# ---------------------------------------------------------------- sounds (synth + optional files)

func _wav(samples: PackedFloat32Array, rate: int, loop: bool) -> AudioStreamWAV:
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.stereo = false
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		bytes.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 30000.0))
	w.data = bytes
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = samples.size()
	return w


func _synth_shot(dur: float, vol: float, cutoff: float, dscale: float) -> AudioStreamWAV:
	var rate := 22050
	var n := int(dur * rate)
	var s := PackedFloat32Array()
	s.resize(n)
	var lp := 0.0
	var a := clampf(cutoff / float(rate) * 2.0, 0.02, 0.95)
	for i in n:
		var t := float(i) / rate
		var noise := randf() * 2.0 - 1.0
		lp += (noise - lp) * a
		var env := exp(-t / (dur * dscale))
		var thump := sin(TAU * 70.0 * t) * exp(-t * 18.0) * 0.8
		var crack := noise * exp(-t * 90.0) * 0.6
		s[i] = (lp * env * 1.3 + thump + crack) * vol
	return _wav(s, rate, false)


func _synth_step() -> AudioStreamWAV:
	var rate := 22050
	var n := int(0.13 * rate)
	var s := PackedFloat32Array()
	s.resize(n)
	var lp := 0.0
	for i in n:
		var t := float(i) / rate
		lp += ((randf() * 2.0 - 1.0) - lp) * 0.18
		s[i] = (lp * exp(-t * 38.0) * 0.9 + sin(TAU * 95.0 * t) * exp(-t * 45.0) * 0.5) * 0.7
	return _wav(s, rate, false)


func _synth_crash() -> AudioStreamWAV:
	var rate := 22050
	var n := int(0.7 * rate)
	var s := PackedFloat32Array()
	s.resize(n)
	var lp := 0.0
	for i in n:
		var t := float(i) / rate
		lp += ((randf() * 2.0 - 1.0) - lp) * 0.35
		var ring := sin(TAU * 310.0 * t) * 0.25 + sin(TAU * 437.0 * t) * 0.2
		s[i] = (lp * exp(-t * 7.0) * 1.1 + sin(TAU * 52.0 * t) * exp(-t * 9.0) + ring * exp(-t * 6.0)) * 0.8
	return _wav(s, rate, false)


func _synth_scream() -> AudioStreamWAV:
	var rate := 22050
	var dur := 0.8
	var n := int(dur * rate)
	var s := PackedFloat32Array()
	s.resize(n)
	var ph := 0.0
	for i in n:
		var t := float(i) / rate
		var f := 620.0 + 380.0 * sin(t * 5.0) + 260.0 * t
		ph += TAU * f / rate
		var env := pow(sin(PI * t / dur), 0.6)
		var v := sin(ph) + 0.5 * sin(ph * 2.0) + 0.3 * sin(ph * 3.0) + (randf() * 2.0 - 1.0) * 0.12
		s[i] = v * env * 0.3
	return _wav(s, rate, false)


func _synth_siren() -> AudioStreamWAV:
	var rate := 22050
	var dur := 1.6
	var n := int(dur * rate)
	var s := PackedFloat32Array()
	s.resize(n)
	var ph := 0.0
	for i in n:
		var t := float(i) / rate
		var f := 760.0 + 420.0 * (0.5 - 0.5 * cos(TAU * t / dur))
		ph += TAU * f / rate
		s[i] = (sin(ph) + 0.35 * sin(ph * 3.0) + 0.15 * sin(ph * 5.0)) * 0.3
	return _wav(s, rate, true)


func _synth_engine() -> AudioStreamWAV:
	var rate := 22050
	var n := rate
	var s := PackedFloat32Array()
	s.resize(n)
	var lp := 0.0
	for i in n:
		var t := float(i) / rate
		var v := 0.0
		for k in range(1, 7):
			v += sin(TAU * 55.0 * float(k) * t) / float(k)
		lp += ((randf() * 2.0 - 1.0) - lp) * 0.1
		var am := 0.75 + 0.25 * sin(TAU * 11.0 * t)
		s[i] = (v * 0.28 * am + lp * 0.07)
	return _wav(s, rate, true)


func _synth_skid() -> AudioStreamWAV:
	var rate := 22050
	var n := rate
	var s := PackedFloat32Array()
	s.resize(n)
	var lp := 0.0
	for i in n:
		var x := randf() * 2.0 - 1.0
		lp += (x - lp) * 0.25
		s[i] = (x - lp) * 0.35
	return _wav(s, rate, true)


func _synth_click(count: int) -> AudioStreamWAV:
	var rate := 22050
	var n := int(0.55 * rate)
	var s := PackedFloat32Array()
	s.resize(n)
	for c in count:
		var start := int(float(c) * 0.28 * rate)
		for i in range(0, int(0.02 * rate)):
			if start + i < n:
				s[start + i] = (randf() * 2.0 - 1.0) * exp(-float(i) / (0.004 * rate)) * 0.8
	return _wav(s, rate, false)


func _synth_radio() -> AudioStreamWAV:
	var rate := 22050
	var n := int(0.4 * rate)
	var s := PackedFloat32Array()
	s.resize(n)
	for i in n:
		var t := float(i) / rate
		var f := 1250.0 if t < 0.12 else (900.0 if t < 0.24 else 0.0)
		var tone := sin(TAU * f * t) * 0.35 if f > 0.0 else 0.0
		s[i] = tone + (randf() * 2.0 - 1.0) * 0.06 * exp(-t * 4.0)
	return _wav(s, rate, false)


func _make_loop(s: AudioStream) -> void:
	if s is AudioStreamWAV:
		var w := s as AudioStreamWAV
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = int(w.get_length() * float(w.mix_rate))
	elif s is AudioStreamOggVorbis:
		(s as AudioStreamOggVorbis).loop = true
	elif s is AudioStreamMP3:
		(s as AudioStreamMP3).loop = true


func _load_sound_file(key: String) -> AudioStream:
	for ext in ["ogg", "wav", "mp3"]:
		var p := "%s%s.%s" % [SND_DIR, key, ext]
		if ResourceLoader.exists(p):
			var s := load(p) as AudioStream
			if s != null:
				if key in ["engine", "siren", "skid"]:
					_make_loop(s)
				return s
	return null


func _build_sounds() -> void:
	sfx["pistol"] = _synth_shot(0.28, 0.9, 1800.0, 0.35)
	sfx["smg"] = _synth_shot(0.18, 0.8, 2600.0, 0.5)
	sfx["shotgun"] = _synth_shot(0.55, 1.0, 900.0, 0.2)
	sfx["rifle"] = _synth_shot(0.4, 1.0, 1400.0, 0.25)
	sfx["step"] = _synth_step()
	sfx["crash"] = _synth_crash()
	sfx["scream"] = _synth_scream()
	sfx["siren"] = _synth_siren()
	sfx["engine"] = _synth_engine()
	sfx["skid"] = _synth_skid()
	sfx["reload"] = _synth_click(2)
	sfx["radio"] = _synth_radio()
	for k in sfx.keys():
		var f := _load_sound_file(String(k))
		if f != null:
			sfx[k] = f
	engine_snd = AudioStreamPlayer.new()
	engine_snd.stream = sfx["engine"]
	engine_snd.volume_db = -80.0
	add_child(engine_snd)
	skid_snd = AudioStreamPlayer.new()
	skid_snd.stream = sfx["skid"]
	skid_snd.volume_db = -12.0
	add_child(skid_snd)


func _sfx3d(key: String, pos: Vector3, vol_db: float = 0.0, pitch: float = 1.0, maxd: float = 140.0) -> void:
	if not sfx.has(key):
		return
	var p := AudioStreamPlayer3D.new()
	p.stream = sfx[key]
	p.volume_db = vol_db
	p.pitch_scale = pitch
	p.max_distance = maxd
	p.unit_size = 12.0
	add_child(p)
	p.global_position = pos
	p.finished.connect(p.queue_free)
	p.play()


func _update_car_audio(delta: float, throttle: float, hb: bool, prev_speed: float) -> void:
	crash_cd = maxf(crash_cd - delta, 0.0)
	scream_cd = maxf(scream_cd - delta, 0.0)
	if in_car and engine_snd.stream != null:
		if not engine_snd.playing:
			engine_snd.play()
		var r := clampf(absf(car_speed) / CAR_MAX, 0.0, 1.0)
		engine_snd.pitch_scale = 0.65 + r * 1.9 + absf(throttle) * 0.15
		engine_snd.volume_db = -13.0 + absf(throttle) * 5.0 + r * 3.0
	elif engine_snd.playing:
		engine_snd.stop()
	var want_skid := in_car and hb and absf(car_speed) > 10.0
	if want_skid and not skid_snd.playing and skid_snd.stream != null:
		skid_snd.play()
	elif not want_skid and skid_snd.playing:
		skid_snd.stop()
	if prev_speed - car_speed > 9.0 and absf(prev_speed) > 10.0 and crash_cd <= 0.0:
		crash_cd = 0.8
		_sfx3d("crash", car.position, 2.0, randf_range(0.9, 1.1), 160.0)


# ---------------------------------------------------------------- effects

func _fx_add(n: Node3D, life: float, g: float = 0.0, v: Vector3 = Vector3.ZERO, grav: float = 0.0, mat: StandardMaterial3D = null, a0: float = 1.0, spin: Vector3 = Vector3.ZERO, on_floor: bool = false) -> void:
	fx.append({"n": n, "t": life, "life": maxf(life, 0.001), "g": g, "v": v, "grav": grav, "mat": mat, "a0": a0, "spin": spin, "floor": on_floor})


func _update_fx(delta: float) -> void:
	for i in range(fx.size() - 1, -1, -1):
		var f: Dictionary = fx[i]
		var n: Node3D = f["n"]
		if not is_instance_valid(n):
			fx.remove_at(i)
			continue
		f["t"] = float(f["t"]) - delta
		var v: Vector3 = f["v"]
		var grav := float(f["grav"])
		if v != Vector3.ZERO or grav != 0.0:
			v.y -= grav * delta
			f["v"] = v
			n.position += v * delta
		var g := float(f["g"])
		if g > 0.0:
			n.scale += Vector3.ONE * g * delta
		var spin: Vector3 = f["spin"]
		if spin != Vector3.ZERO:
			n.rotation += spin * delta
		var m = f["mat"]
		if m != null:
			var c: Color = (m as StandardMaterial3D).albedo_color
			c.a = float(f["a0"]) * clampf(float(f["t"]) / float(f["life"]), 0.0, 1.0)
			(m as StandardMaterial3D).albedo_color = c
		var dead_fx := float(f["t"]) <= 0.0
		if bool(f["floor"]) and n.position.y < 0.03:
			dead_fx = true
		if dead_fx:
			n.queue_free()
			fx.remove_at(i)


func _tracer(from: Vector3, to: Vector3, widx: int, player_shot: bool) -> void:
	var d := to - from
	var l := d.length()
	if l < 0.05:
		return
	var dir := d / l
	var mi: Node3D
	var spd := BULLET_SPEED
	if player_shot and widx > 0 and bullet_tmpl[widx] != null:
		mi = bullet_tmpl[widx].duplicate() as Node3D
		spd = BULLET_GLB_SPEED
	else:
		var m := MeshInstance3D.new()
		m.mesh = _boxm(Vector3(0.03, 0.03, 1.2 if widx != 3 else 0.7))
		m.material_override = tracer_mats[widx] if player_shot else tr_mat_c
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi = m
	add_child(mi)
	mi.global_position = from
	var up := Vector3.UP
	if absf(dir.y) > 0.98:
		up = Vector3.RIGHT
	mi.look_at(from + dir, up)
	_fx_add(mi, maxf(l / spd, 0.03), 0.0, dir * spd)


func _muzzle_flash(pos: Vector3, dir: Vector3, size: float) -> void:
	var n := Node3D.new()
	add_
