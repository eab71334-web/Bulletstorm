extends Node
# extras.gd - batch 1

const BLOCK := 54.0
const ANIM_DIR := "res://game/anims/"
const WEAPON_TAGS := [[], ["pistol", "w1"], ["smg", "w2"], ["shotgun", "w3"], ["rifle", "w4"]]
const AMB_GLB := "res://game/ambulance.glb"
const MEDIC_GLB := "res://game/peds/medic.glb"
const AMB_SPEED := 24.0
const DOWN_TIME := 50.0
const APP_NAMES := ["MAP", "MY CAR", "GUNS", "TAXI", "CAMERA", "PHOTOS", "CLOCK", "STORE", "SETTINGS"]


class ArmIK extends SkeletonModifier3D:
	var ok := false
	var b_ur := -1
	var b_fr := -1
	var b_hr := -1
	var b_ul := -1
	var b_fl := -1
	var b_hl := -1
	var rmode := 0
	var lmode := 0
	var rw := 0.0
	var lw := 0.0
	var aim_dir := Vector3.FORWARD
	var fwd := Vector3.FORWARD
	var side := Vector3.RIGHT

	func setup(sk: Skeleton3D) -> void:
		var re := RegEx.new()
		re.compile("[_.]\\d+$")
		for i in sk.get_bone_count():
			var l := sk.get_bone_name(i).to_lower()
			l = re.sub(l, "")
			l = re.sub(l, "")
			if l.contains("thumb") or l.contains("index") or l.contains("middle") or l.contains("ring") or l.contains("pinky") or l.contains("finger"):
				continue
			if l.contains("twist") or l.contains("roll") or l.contains("helper") or l.contains("shoulder") or l.contains("clav"):
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
			elif l.contains("arm"):
				role = "u"
			if role == "":
				continue
			if right:
				if role == "u" and b_ur < 0:
					b_ur = i
				elif role == "f" and b_fr < 0:
					b_fr = i
				elif role == "h" and b_hr < 0:
					b_hr = i
			else:
				if role == "u" and b_ul < 0:
					b_ul = i
				elif role == "f" and b_fl < 0:
					b_fl = i
				elif role == "h" and b_hl < 0:
					b_hl = i
		ok = b_ur >= 0 and b_fr >= 0 and b_hr >= 0

	func _process_modification() -> void:
		_run()

	func _process_modification_with_delta(_delta: float) -> void:
		_run()

	func _run() -> void:
		if not ok:
			return
		var sk := get_skeleton()
		if sk == null:
			return
		_arm(sk, b_ur, b_fr, b_hr, rmode, rw, false)
		_arm(sk, b_ul, b_fl, b_hl, lmode, lw, true)

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
		else:
			du = (Vector3.DOWN * 0.8 + fwd * 0.5).normalized()
			df = (Vector3.UP * 0.7 + fwd * 0.6 - side * 0.3).normalized()
		_point(sk, bu, bf, (inv * du).normalized(), w)
		_point(sk, bf, bh, (inv * df).normalized(), w)

	func _point(sk: Skeleton3D, b: int, child: int, target: Vector3, w: float) -> void:
		var pose: Transform3D = sk.get_bone_global_pose(b)
		var cp: Transform3D = sk.get_bone_global_pose(child)
		var cur := cp.origin - pose.origin
		if cur.length() < 0.0001:
			return
		cur = cur.normalized()
		var q := Quaternion(cur, target)
		var nb := (Basis(q) * pose.basis).orthonormalized()
		var ob := pose.basis.orthonormalized()
		pose.basis = ob.slerp(nb, w)
		sk.set_bone_global_pose(b, pose)


class Amb extends CharacterBody3D:
	var target: Node3D
	var state := 0
	var speed := 0.0
	var path := PackedVector2Array()
	var path_i := 0
	var repath := 0.0
	var stuck_t := 0.0
	var reverse_t := 0.0
	var timer := 0.0
	var life := 0.0
	var treated := false
	var exit_pos := Vector2.ZERO
	var medics: Array = []
	var mat_a: StandardMaterial3D
	var mat_b: StandardMaterial3D
	var siren: AudioStreamPlayer3D


class Medic extends CharacterBody3D:
	var amb: Amb
	var legs: Array = []
	var walk_t := 0.0


var g
var rng := RandomNumberGenerator.new()
var suffix_re := RegEx.new()
var anim_src := {}
var report: Array[String] = []
var player_ik: ArmIK
var orig_names := {}
var phone_swapped := false

var tracked := {}
var ambs: Array[Amb] = []
var inv_cops: Array = []
var seen_cops := {}
var exploded := {}
var scene_cd := 0.0

var car_hp := 100.0
var car_wrecked := false
var wreck_t := 0.0
var shake := 0.0
var prev_hp := 100.0
var prev_speed := 0.0
var fire_t := 0.0
var wrecks: Array[Dictionary] = []
var fades: Array[Dictionary] = []
var wreck_mats := {}
var char_mat: StandardMaterial3D

var pl: CanvasLayer
var pc: Control
var phone_t := 0.0
var phone_scale := 0.55
var sb_body: StyleBoxFlat
var sb_screen: StyleBoxFlat
var sb_notch: StyleBoxFlat
var sb_apps: Array[StyleBoxFlat] = []


func _ready() -> void:
	rng.randomize()
	suffix_re.compile("[_.]\\d+$")
	char_mat = StandardMaterial3D.new()
	char_mat.albedo_color = Color(0.04, 0.04, 0.05)
	char_mat.roughness = 1.0
	g.sfx["explosion"] = _synth_explosion()
	_load_anim_files()
	_setup_player()
	_build_phone()
	_report_to_screen()


# ---------------------------------------------------------------- animation files

func _parse(low: String) -> Array:
	for s in ["crouch", "offset", "d90", "u90", "root_motion", "bwd", "back", "left", "right", "strafe", "turn"]:
		if low.contains(s):
			return []
	var w := 0
	for i in range(1, WEAPON_TAGS.size()):
		for tag in WEAPON_TAGS[i]:
			if low.contains(String(tag)):
				w = i
	if low.contains("phone") or low.contains("call") or low.contains("text"):
		w = 9
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
	if base == "" and w > 0 and w < 9:
		base = "aim"
	if base == "":
		return []
	return [w, base]


func _load_anim_files() -> void:
	var da := DirAccess.open(ANIM_DIR)
	if da == null:
		report.append("NO ANIMS FOLDER")
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
		var parsed := _parse(low)
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
		inst.free()


func canon(n: String) -> String:
	var l := n.to_lower()
	if l.contains(":"):
		l = l.get_slice(":", l.get_slice_count(":") - 1)
	for pre in ["mixamorig", "bip001", "bip01", "def-", "def_", "cc_base_", "jnt_"]:
		l = l.replace(pre, "")
	l = suffix_re.sub(l, "")
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


func retarget(ap: AnimationPlayer, sk: Skeleton3D, tag: String, rep: Array[String]) -> Dictionary:
	var out := {}
	if ap == null or sk == null or anim_src.is_empty():
		return out
	if not ap.has_animation_library(""):
		ap.add_animation_library("", AnimationLibrary.new())
	var lib := ap.get_animation_library("")
	var base := ap.get_node(ap.root_node)
	var sk_path := str(base.get_path_to(sk))
	var bone_map := {}
	for i in sk.get_bone_count():
		var bn := sk.get_bone_name(i)
		bone_map[canon(bn)] = bn
	for k in anim_src.keys():
		var anim := (anim_src[k] as Animation).duplicate() as Animation
		var tot := anim.get_track_count()
		var miss := ""
		for t in range(tot - 1, -1, -1):
			var ttype := anim.track_get_type(t)
			var tp := anim.track_get_path(t)
			if ttype != Animation.TYPE_ROTATION_3D or tp.get_subname_count() == 0:
				anim.remove_track(t)
				continue
			var raw := tp.get_subname(0)
			var nb := canon(raw)
			if not bone_map.has(nb):
				miss = raw
				anim.remove_track(t)
				continue
			anim.track_set_path(t, NodePath(sk_path + ":" + String(bone_map[nb])))
		var kept := anim.get_track_count()
		var line := "%s %d/%d" % [k, kept, tot]
		if kept < 6:
			line += " X(" + miss + ")"
		rep.append(line)
		if kept < 6:
			continue
		var bname := String(k).get_slice("_", 1)
		var looped := bname in ["idle", "aim", "walk", "run"]
		anim.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
		var nm := "y%s_%s" % [tag, k]
		lib.add_animation(nm, anim)
		out[k] = nm
	return out


func _setup_player() -> void:
	var sk: Skeleton3D = g.char_skeleton
	if sk == null:
		report.append("NO SKELETON")
		return
	player_ik = ArmIK.new()
	sk.add_child(player_ik)
	player_ik.setup(sk)
	if not player_ik.ok:
		report.append("IK FAIL ur=%d fr=%d hr=%d" % [player_ik.b_ur, player_ik.b_fr, player_ik.b_hr])
	var ap: AnimationPlayer = g.anim_player
	if ap == null:
		return
	var res := retarget(ap, sk, "p", report)
	if res.is_empty():
		return
	for w in range(1, 5):
		for b in ["raise", "fire", "aim"]:
			var k := "%d_%s" % [w, b]
			if not res.has(k) and res.has("0_" + b):
				res[k] = res["0_" + b]
	g.weapon_anims = res
	var v := String(res.get("0_idle", ""))
	if v != "":
		g.a_idle = v
	v = String(res.get("0_walk", ""))
	if v != "":
		g.a_walk = v
	v = String(res.get("0_run", ""))
	if v != "":
		g.a_run = v
	v = String(res.get("0_jump", ""))
	if v != "":
		g.a_jump = v
	v = String(res.get("0_aim", ""))
	if v != "":
		g.a_aim = v
	if String(g.a_run) == "":
		g.a_run = g.a_walk


func _report_to_screen() -> void:
	var lines: Array[String] = []
	var ik_ok := player_ik != null and player_ik.ok
	var hb: String = g.hand_bone_name
	lines.append("EXTRAS OK | IK: %s | HAND: %s" % ["YES" if ik_ok else "NO", hb if hb != "" else "NOT FOUND"])
	var cur := ""
	for r in report:
		if cur.length() + r.length() > 80:
			lines.append(cur)
			cur = ""
		cur += r + "   "
	if cur != "":
		lines.append(cur)
	g._toast("\n".join(PackedStringArray(lines)), 18.0)


# ---------------------------------------------------------------- main loop

func _physics_process(delta: float) -> void:
	scene_cd = maxf(scene_cd - delta, 0.0)
	_update_player_ik(delta)
	_swap_phone_anims()
	_actors(delta)
	_poll_peds()
	_update_tracked(delta)
	_update_ambs(delta)
	_poll_cops()
	_update_investigators(delta)
	_update_car_damage(delta)
	_update_wrecks(delta)
	_update_fades(delta)
	_shake_cam(delta)
	_phone_tick(delta)


func _update_player_ik(delta: float) -> void:
	if player_ik == null or not player_ik.ok:
		return
	var armed: bool = g.aim_t > 0.0 and g.cur_weapon > 0 and not g.in_car and not g.dead
	var phone_up: bool = g.phone_open and not g.in_car
	var yaw: float = g.model.rotation.y
	player_ik.fwd = Vector3(-sin(yaw), 0.0, -cos(yaw))
	player_ik.side = Vector3(cos(yaw), 0.0, -sin(yaw))
	var fallback: bool = g.weapon_anims.is_empty()
	var tr := 0.0
	var tl := 0.0
	if armed:
		var shoulder: Vector3 = g.player.position + Vector3(0, 1.4, 0)
		var ap: Vector3 = g._aim_point(60.0)
		var d: Vector3 = ap - shoulder
		if d.length() > 1.0:
			player_ik.aim_dir = player_ik.aim_dir.slerp(d.normalized(), 1.0 - exp(-14.0 * delta))
		player_ik.rmode = 1
		player_ik.lmode = 1 if g.cur_weapon >= 2 else 2
		tr = 1.0
		tl = 1.0
	elif phone_up:
		player_ik.rmode = 3
		player_ik.lmode = 2
		tr = 1.0
		tl = 1.0
	elif fallback:
		player_ik.rmode = 2
		player_ik.lmode = 2
		tr = 1.0
		tl = 1.0
	player_ik.rw = move_toward(player_ik.rw, tr, delta * 6.0)
	player_ik.lw = move_toward(player_ik.lw, tl, delta * 6.0)


func _swap_phone_anims() -> void:
	var wa: Dictionary = g.weapon_anims
	var want: bool = g.phone_open and not g.in_car and wa.has("9_idle")
	if want and not phone_swapped:
		orig_names = {"i": g.a_idle, "w": g.a_walk, "r": g.a_run}
		phone_swapped = true
	if want:
		g.a_idle = String(wa.get("9_idle", g.a_idle))
		g.a_walk = String(wa.get("9_walk", g.a_walk))
		g.a_run = String(wa.get("9_run", g.a_run))
	elif phone_swapped:
		g.a_idle = orig_names["i"]
		g.a_walk = orig_names["w"]
		g.a_run = orig_names["r"]
		phone_swapped = false


# ---------------------------------------------------------------- peds and officers: arms + gun

func _init_actor(p) -> void:
	p.set_meta("x_init", true)
	var sk: Skeleton3D = g._find_skeleton(p)
	if sk == null:
		p.set_meta("anim_ok", true)
		return
	var ik := ArmIK.new()
	sk.add_child(ik)
	ik.setup(sk)
	p.set_meta("ik", ik)
	var ok := false
	if p.anim != null:
		var rep: Array[String] = []
		var res := retarget(p.anim, sk, "a", rep)
		if not res.is_empty():
			p.anims = res
			p.a_idle = String(res.get("0_idle", p.a_idle))
			p.a_walk = String(res.get("0_walk", p.a_walk))
			p.a_run = String(res.get("0_run", p.a_run))
		if p.a_run == "":
			p.a_run = p.a_walk
		ok = p.a_idle != "" or p.a_walk != ""
	p.set_meta("anim_ok", ok)
	if p.get("aiming") != null:
		_give_gun(p, sk)


func _give_gun(p, sk: Skeleton3D) -> void:
	var hb: String = g._find_hand_bone(sk)
	if hb == "":
		return
	var att := BoneAttachment3D.new()
	sk.add_child(att)
	att.bone_name = hb
	var holder := Node3D.new()
	holder.rotation_degrees = Vector3(90, 0, 0)
	att.add_child(holder)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.05, 0.12, 0.22)
	mi.mesh = bm
	mi.position = Vector3(0, 0, -0.1)
	mi.material_override = g._mat(Color(0.07, 0.07, 0.09))
	holder.add_child(mi)
	p.set_meta("prop", holder)
	p.set_meta("prop_par", att)


func _actors(delta: float) -> void:
	var all: Array = []
	all.append_array(g.officers)
	all.append_array(g.peds)
	var ppos: Vector3 = g.player.position
	for p in all:
		if not is_instance_valid(p):
			continue
		if not p.has_meta("x_init"):
			_init_actor(p)
		var ik: ArmIK = p.get_meta("ik", null)
		if ik == null or not ik.ok:
			continue
		if p.position.distance_to(ppos) > 80.0:
			continue
		var prop = p.get_meta("prop", null)
		if prop != null and is_instance_valid(prop):
			var par: Node3D = p.get_meta("prop_par")
			var ps: Vector3 = par.global_transform.basis.get_scale()
			if ps.x > 0.0001 and ps.y > 0.0001 and ps.z > 0.0001:
				prop.scale = Vector3(1.0 / ps.x, 1.0 / ps.y, 1.0 / ps.z)
			prop.visible = bool(p.aiming) and not p.dead
		var tr := 0.0
		if p.dead:
			ik.rw = move_toward(ik.rw, 0.0, delta * 6.0)
			ik.lw = ik.rw
			continue
		var yaw: float = p.rotation.y
		ik.fwd = Vector3(-sin(yaw), 0.0, -cos(yaw))
		ik.side = Vector3(cos(yaw), 0.0, -sin(yaw))
		var aiming: bool = p.get("aiming") != null and bool(p.aiming)
		if aiming:
			var tgt: Vector3 = g.car.position if g.in_car else g.player.position
			var chest: Vector3 = p.position + Vector3(0, 1.4, 0)
			ik.aim_dir = (tgt + Vector3(0, 1.1, 0) - chest).normalized()
			ik.rmode = 1
			ik.lmode = 1
			tr = 1.0
		elif not bool(p.get_meta("anim_ok", false)):
			ik.rmode = 2
			ik.lmode = 2
			tr = 1.0
		ik.rw = move_toward(ik.rw, tr, delta * 6.0)
		ik.lw = ik.rw


# ---------------------------------------------------------------- hit by car, downed, ambulance

func _poll_peds() -> void:
	var cs: float = absf(g.car_speed)
	for p in g.peds:
		if not is_instance_valid(p) or not p.dead:
			continue
		var id: int = p.get_instance_id()
		if tracked.has(id):
			continue
		var by_car: bool = g.in_car and cs > 4.0 and p.position.distance_to(g.car.position) < 5.5
		if by_car:
			_launch(p, cs)
		else:
			tracked[id] = {"mode": "dead"}
			_dispatch_scene(p.position)


func _launch(p, spd: float) -> void:
	var dir: Vector3 = -g.car.global_transform.basis.z * signf(g.car_speed)
	dir.y = 0.0
	tracked[p.get_instance_id()] = {
		"mode": "fly",
		"hp": 40.0 - spd * 2.2,
		"t": 0.0,
		"vel": dir.normalized() * spd * 0.85 + Vector3(0, 3.5 + spd * 0.15, 0),
		"spin": Vector3(rng.randf_range(-6, 6), rng.randf_range(-3, 3), rng.randf_range(-6, 6))
	}
	if p.anim != null:
		p.anim.stop()
	g._sfx3d("crash", p.position, -2.0, 1.4, 120.0)
	g._sfx3d("scream", p.position, 0.0, 1.0, 100.0)
	g.car_speed = g.car_speed * 0.88


func _mode_of(p) -> String:
	if not is_instance_valid(p):
		return ""
	var st = tracked.get(p.get_instance_id(), null)
	if st == null:
		return ""
	return String(st["mode"])


func _update_tracked(delta: float) -> void:
	for id in tracked.keys():
		var p = instance_from_id(id)
		if p == null or not is_instance_valid(p):
			tracked.erase(id)
			continue
		var st: Dictionary = tracked[id]
		var mode := String(st["mode"])
		if mode == "fly":
			p.dead_t = 0.0
			var v: Vector3 = st["vel"]
			v.y -= 22.0 * delta
			st["vel"] = v
			p.position += v * delta
			p.rotation += st["spin"] * delta
			if p.position.y <= 0.15 and v.y < 0.0:
				p.position.y = 0.3
				p.rotation = Vector3(-PI * 0.5, p.rotation.y, 0.0)
				g._sfx3d("crash", p.position, -6.0, 1.8, 80.0)
				if float(st["hp"]) <= 0.0:
					st["mode"] = "dead"
				else:
					st["mode"] = "down"
					st["t"] = DOWN_TIME
					p.hp = float(st["hp"])
					_dispatch_amb(p)
					_dispatch_scene(p.position)
		elif mode == "down":
			p.dead_t = 0.0
			st["t"] = float(st["t"]) - delta
			if float(st["t"]) <= 0.0:
				st["mode"] = "dead"
		elif mode == "revive":
			p.dead = false
			p.dead_t = 0.0
			p.rotation.x = 0.0
			p.collision_layer = 2
			p.panic = 0.0
			p.hp = maxf(p.hp, 25.0)
			_snap_ped(p)
			tracked.erase(id)


func _snap_ped(p) -> void:
	var sp: Vector2 = g._snap_to_road(Vector2(p.position.x, p.position.z))
	var ix := roundi(sp.x / BLOCK)
	var iz := roundi(sp.y / BLOCK)
	var on_v := absf(sp.x - float(ix) * BLOCK) < 0.5
	if on_v:
		var z0 := clampi(floori(sp.y / BLOCK), -3, 2)
		p.a_ix = clampi(ix, -3, 3)
		p.a_iz = z0
		p.b_ix = p.a_ix
		p.b_iz = z0 + 1
		p.t = clampf((sp.y - float(z0) * BLOCK) / BLOCK, 0.0, 0.99)
	else:
		var x0 := clampi(floori(sp.x / BLOCK), -3, 2)
		p.a_ix = x0
		p.a_iz = clampi(iz, -3, 3)
		p.b_ix = x0 + 1
		p.b_iz = p.a_iz
		p.t = clampf((sp.x - float(x0) * BLOCK) / BLOCK, 0.0, 0.99)
	p.lane = 5.5


func _far_node(from: Vector2, min_d: float) -> Vector2:
	var pos := Vector2.ZERO
	for i in 16:
		pos = Vector2(rng.randi_range(-3, 3) * BLOCK, rng.randi_range(-3, 3) * BLOCK)
		if pos.distance_to(from) >= min_d:
			return pos
	return pos


func _flash(ma, mb) -> void:
	if ma == null or mb == null:
		return
	var on := int(float(Time.get_ticks_msec()) / 160.0) % 2 == 0
	ma.emission_energy_multiplier = 4.0 if on else 0.2
	mb.emission_energy_multiplier = 0.2 if on else 4.0


func _clear(v, from: Vector3, to: Vector3) -> bool:
	var q := PhysicsRayQueryParameters3D.create(from, to, 1)
	q.exclude = [v.get_rid(), g.player.get_rid(), g.car.get_rid()]
	return v.get_world_3d().direct_space_state.intersect_ray(q).is_empty()


func _ray_dist(v, origin: Vector3, dir: Vector3, length: float) -> float:
	var q := PhysicsRayQueryParameters3D.create(origin, origin + dir * length, 1)
	q.exclude = [v.get_rid(), g.player.get_rid(), g.car.get_rid()]
	var hit: Dictionary = v.get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty():
		return length
	return origin.distance_to(hit["position"])


func _ai_drive(v, goal: Vector2, max_speed: float, delta: float, stop_d: float) -> float:
	var cp := Vector2(v.position.x, v.position.z)
	var d := cp.distance_to(goal)
	var aim := goal
	var eye: Vector3 = v.position + Vector3(0, 1.0, 0)
	var direct := d < 60.0 and _clear(v, eye, Vector3(goal.x, 1.0, goal.y))
	if not direct:
		v.repath -= delta
		if v.repath <= 0.0:
			v.repath = 1.0
			v.path = g.astar.get_point_path(g._node_for(cp), g._node_for(goal))
			v.path_i = 0
		while v.path_i < v.path.size() and cp.distance_to(v.path[v.path_i]) < 10.0:
			v.path_i += 1
		if v.path_i < v.path.size():
			aim = v.path[v.path_i]
	var vec := aim - cp
	var desired := atan2(-vec.x, -vec.y)
	var diff := wrapf(desired - v.rotation.y, -PI, PI)
	var fwd: Vector3 = -v.global_transform.basis.z
	var org: Vector3 = v.position + Vector3(0, 0.8, 0)
	var dc := _ray_dist(v, org, fwd, 14.0)
	var dl := _ray_dist(v, org, fwd.rotated(Vector3.UP, 0.55), 10.0)
	var dr := _ray_dist(v, org, fwd.rotated(Vector3.UP, -0.55), 10.0)
	var w := clampf(1.0 - dc / 14.0, 0.0, 1.0)
	var avoid := clampf((dl - dr) / 10.0, -1.0, 1.0)
	var tgt_speed := 0.0
	if v.reverse_t > 0.0:
		v.reverse_t -= delta
		tgt_speed = -9.0
		v.rotation.y -= clampf(diff, -1.0, 1.0) * 1.5 * delta
	else:
		var turn := clampf(diff, -2.6 * delta, 2.6 * delta) * (1.0 - w) + avoid * 2.4 * delta * w
		v.rotation.y += turn
		tgt_speed = max_speed * clampf(dc / 14.0, 0.25, 1.0)
		if absf(diff) > 0.8:
			tgt_speed = minf(tgt_speed, 12.0)
		if d < stop_d + 6.0:
			tgt_speed = minf(tgt_speed, 6.0)
		if d < stop_d:
			tgt_speed = 0.0
	v.speed = move_toward(v.speed, tgt_speed, 16.0 * delta)
	var f: Vector3 = -v.global_transform.basis.z
	v.velocity.x = f.x * v.speed
	v.velocity.z = f.z * v.speed
	if v.is_on_floor():
		v.velocity.y = -1.0
	else:
		v.velocity.y -= 25.0 * delta
	v.move_and_slide()
	var actual: float = v.velocity.dot(f)
	if v.reverse_t <= 0.0 and tgt_speed > 8.0 and absf(actual) < 2.5:
		v.stuck_t += delta
		if v.stuck_t > 1.2:
			v.reverse_t = 1.0
			v.stuck_t = 0.0
	else:
		v.stuck_t = 0.0
	v.speed = actual
	return d


func _make_amb() -> Amb:
	var a := Amb.new()
	var col := CollisionShape3D.new()
	var bx := BoxShape3D.new()
	bx.size = Vector3(2.4, 2.2, 5.0)
	col.shape = bx
	col.position.y = 1.15
	a.add_child(col)
	var vis := Node3D.new()
	a.add_child(vis)
	var glb = g._fit_glb(AMB_GLB, PI, 5.4, false, true)
	if glb != null:
		vis.add_child(glb)
	else:
		var white = g._mat(Color(0.95, 0.95, 0.97))
		var red = g._mat(Color(0.85, 0.1, 0.1))
		var dark = g._mat(Color(0.05, 0.05, 0.06))
		var glass = g._mat(Color(0.08, 0.1, 0.14))
		g._part(vis, g._boxm(Vector3(2.2, 1.6, 3.6)), Vector3(0, 1.2, 0.5), white)
		g._part(vis, g._boxm(Vector3(2.1, 1.2, 1.5)), Vector3(0, 0.95, -1.9), white)
		g._part(vis, g._boxm(Vector3(1.9, 0.55, 0.1)), Vector3(0, 1.25, -2.66), glass)
		g._part(vis, g._boxm(Vector3(2.22, 0.25, 3.6)), Vector3(0, 1.0, 0.5), red)
		for sx in [-1.12, 1.12]:
			g._part(vis, g._boxm(Vector3(0.06, 0.9, 0.28)), Vector3(sx, 1.6, 0.4), red)
			g._part(vis, g._boxm(Vector3(0.06, 0.28, 0.9)), Vector3(sx, 1.6, 0.4), red)
		var ma := StandardMaterial3D.new()
		ma.albedo_color = Color(1, 0.1, 0.1)
		ma.emission_enabled = true
		ma.emission = Color(1, 0.1, 0.1)
		var mb := StandardMaterial3D.new()
		mb.albedo_color = Color(0.9, 0.9, 1.0)
		mb.emission_enabled = true
		mb.emission = Color(0.8, 0.85, 1.0)
		g._part(vis, g._boxm(Vector3(0.7, 0.14, 0.3)), Vector3(-0.5, 2.05, -1.7), ma)
		g._part(vis, g._boxm(Vector3(0.7, 0.14, 0.3)), Vector3(0.5, 2.05, -1.7), mb)
		a.mat_a = ma
		a.mat_b = mb
		for wp in [Vector3(-1.05, 0.45, -1.6), Vector3(1.05, 0.45, -1.6), Vector3(-1.05, 0.45, 1.7), Vector3(1.05, 0.45, 1.7)]:
			var cyl := CylinderMesh.new()
			cyl.top_radius = 0.45
			cyl.bottom_radius = 0.45
			cyl.height = 0.35
			var mi: MeshInstance3D = g._part(vis, cyl, wp, dark)
			mi.rotation_degrees = Vector3(0, 0, 90)
	if g.sfx.has("siren"):
		a.siren = AudioStreamPlayer3D.new()
		a.siren.stream = g.sfx["siren"]
		a.siren.pitch_scale = 1.3
		a.siren.max_distance = 220.0
		a.siren.unit_size = 25.0
		a.add_child(a.siren)
	return a


func _make_medic() -> Medic:
	var m := Medic.new()
	m.collision_layer = 2
	m.collision_mask = 1
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 1.8
	col.shape = cap
	col.position.y = 0.9
	m.add_child(col)
	var glb = g._fit_glb(MEDIC_GLB, PI, 1.8, true, true)
	if glb != null:
		m.add_child(glb)
		return m
	var shirt = g._mat(Color(0.05, 0.6, 0.5))
	var pants = g._mat(Color(0.9, 0.9, 0.92))
	var skin = g._mat(Color(0.8, 0.62, 0.48))
	g._part(m, g._boxm(Vector3(0.42, 0.6, 0.24)), Vector3(0, 1.15, 0), shirt)
	g._part(m, g._spherem(0.13), Vector3(0, 1.62, 0), skin)
	for sx in [-0.1, 0.1]:
		var pv := Node3D.new()
		pv.position = Vector3(sx, 0.85, 0)
		m.add_child(pv)
		g._part(pv, g._boxm(Vector3(0.16, 0.85, 0.18)), Vector3(0, -0.425, 0), pants)
		m.legs.append(pv)
	return m


func _dispatch_amb(p) -> void:
	for a in ambs:
		if is_instance_valid(a) and a.target == p:
			return
	var a := _make_amb()
	var pos: Vector3 = p.position
	var sp := _far_node(Vector2(pos.x, pos.z), 95.0)
	g.add_child(a)
	a.position = Vector3(sp.x + 3.5, 0.1, sp.y)
	a.rotation.y = atan2(-(pos.x - sp.x), -(pos.z - sp.y))
	a.target = p
	ambs.append(a)
	if a.siren != null:
		a.siren.play()


func _spawn_medics(a: Amb) -> void:
	var right: Vector3 = a.global_transform.basis.x
	for i in 2:
		var m := _make_medic()
		m.amb = a
		g.add_child(m)
		var sd := -1.0 if i == 0 else 1.0
		m.position = a.position + right * 2.8 * sd + Vector3(0, 0.2, 0)
		a.medics.append(m)


func _move_medic(m: Medic, goal: Vector3, delta: float) -> float:
	var flat := Vector3(goal.x - m.position.x, 0.0, goal.z - m.position.z)
	var d := flat.length()
	var moving := d > 1.4
	var vel := Vector3.ZERO
	if moving:
		vel = flat.normalized() * 5.2
		m.rotation.y = lerp_angle(m.rotation.y, atan2(-flat.x, -flat.z), 1.0 - exp(-10.0 * delta))
	m.velocity.x = vel.x
	m.velocity.z = vel.z
	if m.is_on_floor():
		m.velocity.y = -1.0
	else:
		m.velocity.y -= 25.0 * delta
	m.move_and_slide()
	if m.legs.size() == 2:
		if moving:
			m.walk_t += delta * 11.0
		var sw := sin(m.walk_t) * (0.8 if moving else 0.0)
		m.legs[0].rotation.x = sw
		m.legs[1].rotation.x = -sw
	return d


func _update_ambs(delta: float) -> void:
	for i in range(ambs.size() - 1, -1, -1):
		var a := ambs[i]
		if not is_instance_valid(a):
			ambs.remove_at(i)
			continue
		_flash(a.mat_a, a.mat_b)
		var mode := _mode_of(a.target)
		if mode != "down" and not a.treated:
			a.treated = true
			if a.state == 0:
				a.state = 2
		if a.state == 0:
			var tp := Vector2(a.target.position.x, a.target.position.z)
			var d := _ai_drive(a, tp, AMB_SPEED, delta, 7.5)
			if d < 9.0 and absf(a.speed) < 2.5:
				_spawn_medics(a)
				a.state = 1
				a.timer = 0.0
		elif a.state == 1:
			var all_near := true
			var alive := 0
			for m in a.medics.duplicate():
				if not is_instance_valid(m):
					a.medics.erase(m)
					continue
				alive += 1
				if not a.treated:
					var dd := _move_medic(m, a.target.position, delta)
					if dd > 1.9:
						all_near = false
				else:
					var db := _move_medic(m, a.position, delta)
					if db < 3.4:
						m.queue_free()
						a.medics.erase(m)
			if not a.treated and all_near and alive > 0:
				a.timer += delta
				if a.timer > 4.0:
					a.treated = true
					if is_instance_valid(a.target) and tracked.has(a.target.get_instance_id()):
						tracked[a.target.get_instance_id()]["mode"] = "revive"
			if a.treated and a.medics.is_empty():
				a.state = 2
		else:
			if a.exit_pos == Vector2.ZERO:
				a.exit_pos = _far_node(Vector2(a.position.x, a.position.z), 140.0)
			var d2 := _ai_drive(a, a.exit_pos, AMB_SPEED, delta, 6.0)
			a.life += delta
			if a.life > 30.0 or d2 < 10.0:
				for m in a.medics:
					if is_instance_valid(m):
						m.queue_free()
				a.queue_free()
				ambs.remove_at(i)


# ---------------------------------------------------------------- police investigate the body

func _dispatch_scene(pos: Vector3) -> void:
	if inv_cops.size() >= 1 or scene_cd > 0.0:
		return
	scene_cd = 40.0
	var c = g._make_cop()
	var sp := _far_node(Vector2(pos.x, pos.z), 95.0)
	g.add_child(c)
	c.position = Vector3(sp.x + 3.5, 0.1, sp.y)
	c.rotation.y = atan2(-(pos.x - sp.x), -(pos.z - sp.y))
	c.set_meta("goal", Vector2(pos.x, pos.z))
	c.set_meta("stage", 0)
	c.set_meta("wait", 0.0)
	inv_cops.append(c)
	if c.siren != null:
		c.siren.play()


func _update_investigators(delta: float) -> void:
	for i in range(inv_cops.size() - 1, -1, -1):
		var c = inv_cops[i]
		if not is_instance_valid(c) or c.dead:
			inv_cops.remove_at(i)
			continue
		_flash(c.mat_a, c.mat_b)
		var stage: int = c.get_meta("stage")
		var goal: Vector2 = c.get_meta("goal")
		var d := _ai_drive(c, goal, 26.0, delta, 11.0)
		if stage == 0:
			if d < 14.0 and absf(c.speed) < 2.0:
				var wt: float = float(c.get_meta("wait")) + delta
				c.set_meta("wait", wt)
				if wt > 9.0:
					c.set_meta("stage", 1)
					c.set_meta("goal", _far_node(Vector2(c.position.x, c.position.z), 140.0))
		else:
			c.leave_t += delta
			if c.leave_t > 25.0 or d < 12.0:
				if c.siren != null:
					c.siren.stop()
				c.queue_free()
				inv_cops.remove_at(i)
				continue
		if g.stars == 0 and g.aim_t > 0.0 and g.cur_weapon > 0 and not g.in_car and c.position.distance_to(g.player.position) < 30.0:
			g._add_wanted(1)


# ---------------------------------------------------------------- vehicle damage and explosions

func damage_car(amount: float) -> void:
	if car_wrecked:
		return
	car_hp -= amount
	if car_hp <= 0.0:
		_explode_car()


func respawn_car() -> void:
	car_wrecked = false
	car_hp = 100.0
	_restore_visual(g.car_visual)
	wreck_mats.clear()
	g.car_speed = 0.0


func _explode_car() -> void:
	car_wrecked = true
	car_hp = 0.0
	wreck_t = 0.0
	var pos: Vector3 = g.car.position + Vector3(0, 0.8, 0)
	_explode(pos, 1.0)
	_char_visual(g.car_visual)
	g.car_speed = 0.0
	_blast(pos, 10.0, 120.0)
	if g.in_car:
		g._hurt_player(260.0)


func _char_visual(n: Node) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		wreck_mats[mi.get_instance_id()] = mi.material_override
		mi.material_override = char_mat
	for c in n.get_children():
		_char_visual(c)


func _restore_visual(n: Node) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		var id := mi.get_instance_id()
		if wreck_mats.has(id):
			mi.material_override = wreck_mats[id]
	for c in n.get_children():
		_restore_visual(c)


func _update_car_damage(delta: float) -> void:
	var hp_now: float = g.hp
	if g.in_car and hp_now < prev_hp and not car_wrecked:
		damage_car((prev_hp - hp_now) * 1.4)
	prev_hp = hp_now
	var sp: float = g.car_speed
	var dv: float = absf(prev_speed) - absf(sp)
	if dv > 9.0 and not car_wrecked:
		damage_car(dv * 1.8)
	if dv > 6.0:
		for c in g.cops:
			if is_instance_valid(c) and not c.dead and c.position.distance_to(g.car.position) < 5.0:
				g._damage_cop(c, dv * 6.0)
	prev_speed = sp
	if car_wrecked:
		g.near_car = false
		wreck_t += delta
	fire_t -= delta
	if fire_t <= 0.0:
		fire_t = 0.12
		var cpos: Vector3 = g.car.position
		var front: Vector3 = cpos + (-g.car.global_transform.basis.z) * 1.8 + Vector3(0, 1.0, 0)
		if car_wrecked:
			if wreck_t < 70.0:
				_flame(cpos + Vector3(rng.randf_range(-1.0, 1.0), 0.7, rng.randf_range(-2.0, 2.0)))
			if rng.randf() < 0.5:
				_puff(cpos + Vector3(0, 1.2, 0), 0.5, 3.5, 0.5, 2.5)
		elif car_hp < 22.0:
			_flame(front)
			_puff(front, 0.3, 2.0, 0.55, 2.0)
		elif car_hp < 45.0:
			_puff(front, 0.25, 1.6, 0.4, 1.8)


func _poll_cops() -> void:
	var lst: Array = []
	lst.append_array(g.cops)
	lst.append_array(inv_cops)
	for c in lst:
		if is_instance_valid(c):
			seen_cops[c.get_instance_id()] = c
	for id in seen_cops.keys():
		var c = seen_cops[id]
		if not is_instance_valid(c):
			seen_cops.erase(id)
			continue
		if c.dead:
			_cop_destroyed(c)
			seen_cops.erase(id)


func _cop_destroyed(c) -> void:
	var id: int = c.get_instance_id()
	if exploded.has(id):
		return
	exploded[id] = true
	var pos: Vector3 = c.position + Vector3(0, 0.8, 0)
	_explode(pos, 0.9)
	_make_wreck(c.position, c.rotation.y)
	_blast(pos, 8.0, 90.0)


func _blast(pos: Vector3, radius: float, dmg: float) -> void:
	for p in g.peds:
		if is_instance_valid(p) and not p.dead:
			var d: float = p.position.distance_to(pos)
			if d < radius:
				g._damage_ped(p, dmg * (1.0 - d / radius))
	for o in g.officers:
		if is_instance_valid(o) and not o.dead:
			var d2: float = o.position.distance_to(pos)
			if d2 < radius:
				g._damage_ped(o, dmg * (1.0 - d2 / radius))
	var lst: Array = []
	lst.append_array(g.cops)
	lst.append_array(inv_cops)
	for c in lst:
		if is_instance_valid(c) and not c.dead:
			var d3: float = c.position.distance_to(pos + Vector3(0, -0.8, 0))
			if d3 > 1.5 and d3 < radius:
				g._damage_cop(c, dmg * 0.8 * (1.0 - d3 / radius))
				if c.dead:
					_cop_destroyed(c)
	var pd: float = g.player.position.distance_to(pos)
	if pd < radius and not g.in_car:
		g._hurt_player(dmg * 0.6 * (1.0 - pd / radius))


func _explode(pos: Vector3, sc: float) -> void:
	shake = maxf(shake, sc)
	g._sfx3d("explosion", pos, 6.0, rng.randf_range(0.92, 1.05), 340.0)
	for i in 6:
		var m: StandardMaterial3D = g._additive(Color(1.0, rng.randf_range(0.35, 0.65), 0.1, 0.9))
		var mi := MeshInstance3D.new()
		mi.mesh = g._spherem(1.0)
		mi.material_override = m
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		g.add_child(mi)
		mi.global_position = pos + Vector3(rng.randf_range(-1.2, 1.2), rng.randf_range(0.0, 1.4), rng.randf_range(-1.2, 1.2)) * sc
		mi.scale = Vector3.ONE * 0.5 * sc
		g._fx_add(mi, 0.7 + rng.randf() * 0.3, 7.0 * sc, Vector3(0, 3.0, 0), 0.0, m, 0.9)
	var cm: StandardMaterial3D = g._additive(Color(1.0, 0.95, 0.8, 1.0))
	var core := MeshInstance3D.new()
	core.mesh = g._spherem(1.0)
	core.material_override = cm
	core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	g.add_child(core)
	core.global_position = pos + Vector3(0, 0.6, 0)
	core.scale = Vector3.ONE * 0.8 * sc
	g._fx_add(core, 0.28, 14.0 * sc, Vector3.ZERO, 0.0, cm, 1.0)
	var rm: StandardMaterial3D = g._additive(Color(1.0, 0.9, 0.7, 0.5))
	var ring := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 1.0
	cyl.bottom_radius = 1.0
	cyl.height = 0.08
	ring.mesh = cyl
	ring.material_override = rm
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	g.add_child(ring)
	ring.global_position = Vector3(pos.x, 0.3, pos.z)
	g._fx_add(ring, 0.6, 22.0 * sc, Vector3.ZERO, 0.0, rm, 0.5)
	var l := OmniLight3D.new()
	l.light_color = Color(1.0, 0.6, 0.25)
	l.light_energy = 9.0
	l.omni_range = 45.0
	g.add_child(l)
	l.global_position = pos + Vector3(0, 1.5, 0)
	fades.append({"n": l, "t": 0.5, "life": 0.5, "e0": 9.0})
	for i in 9:
		_puff(pos + Vector3(rng.randf_range(-1.5, 1.5), 1.0 + float(i) * 0.4, rng.randf_range(-1.5, 1.5)), 1.1 * sc, 4.5, 0.55, 3.0)
	var dm: StandardMaterial3D = g._mat(Color(0.08, 0.07, 0.07))
	var om: StandardMaterial3D = g._unshaded(Color(1.0, 0.45, 0.1))
	for i in 14:
		var bm: BoxMesh = g._boxm(Vector3(rng.randf_range(0.1, 0.45), rng.randf_range(0.05, 0.25), rng.randf_range(0.1, 0.5)))
		var piece := MeshInstance3D.new()
		piece.mesh = bm
		piece.material_override = dm if i % 3 != 0 else om
		g.add_child(piece)
		piece.global_position = pos
		var vel := Vector3(rng.randf_range(-9, 9), rng.randf_range(5, 14), rng.randf_range(-9, 9)) * sc
		g._fx_add(piece, 3.0, 0.0, vel, 20.0, null, 1.0, Vector3(rng.randf_range(-15, 15), rng.randf_range(-15, 15), rng.randf_range(-15, 15)), true)
	for i in 4:
		var wc := CylinderMesh.new()
		wc.top_radius = 0.42
		wc.bottom_radius = 0.42
		wc.height = 0.3
		var wheel := MeshInstance3D.new()
		wheel.mesh = wc
		wheel.material_override = dm
		g.add_child(wheel)
		wheel.global_position = pos
		var wv := Vector3(rng.randf_range(-8, 8), rng.randf_range(6, 11), rng.randf_range(-8, 8)) * sc
		g._fx_add(wheel, 3.5, 0.0, wv, 20.0, null, 1.0, Vector3(rng.randf_range(-12, 12), 0, rng.randf_range(-12, 12)), true)


func _puff(pos: Vector3, size: float, life: float, alpha: float, rise: float) -> void:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(0.12, 0.12, 0.13, alpha)
	var mi := MeshInstance3D.new()
	mi.mesh = g._spherem(1.0)
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	g.add_child(mi)
	mi.global_position = pos
	mi.scale = Vector3.ONE * size
	g._fx_add(mi, life, size * 0.9, Vector3(rng.randf_range(-0.6, 0.6), rise, rng.randf_range(-0.6, 0.6)), 0.0, m, alpha)


func _flame(pos: Vector3) -> void:
	var m: StandardMaterial3D = g._additive(Color(1.0, rng.randf_range(0.4, 0.75), 0.1, 0.85))
	var mi := MeshInstance3D.new()
	mi.mesh = g._spherem(1.0)
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	g.add_child(mi)
	mi.global_position = pos
	mi.scale = Vector3.ONE * rng.randf_range(0.25, 0.5)
	g._fx_add(mi, 0.55, 0.2, Vector3(0, 2.4, 0), 0.0, m, 0.85)


func _make_wreck(pos: Vector3, yaw: float) -> void:
	var w := Node3D.new()
	g.add_child(w)
	w.position = pos
	w.rotation.y = yaw + rng.randf_range(-0.3, 0.3)
	w.rotation.z = rng.randf_range(-0.12, 0.12)
	g._part(w, g._boxm(Vector3(2.1, 0.9, 4.8)), Vector3(0, 0.55, 0), char_mat)
	g._part(w, g._boxm(Vector3(1.6, 0.5, 2.0)), Vector3(0, 1.2, 0.3), char_mat)
	wrecks.append({"n": w, "t": 50.0, "acc": 0.0})


func _update_wrecks(delta: float) -> void:
	for i in range(wrecks.size() - 1, -1, -1):
		var w: Dictionary = wrecks[i]
		var n: Node3D = w["n"]
		if not is_instance_valid(n):
			wrecks.remove_at(i)
			continue
		w["t"] = float(w["t"]) - delta
		w["acc"] = float(w["acc"]) + delta
		if float(w["acc"]) > 0.14:
			w["acc"] = 0.0
			_flame(n.position + Vector3(rng.randf_range(-1.0, 1.0), 0.8, rng.randf_range(-2.0, 2.0)))
			if rng.randf() < 0.4:
				_puff(n.position + Vector3(0, 1.3, 0), 0.5, 3.0, 0.45, 2.4)
		if float(w["t"]) <= 0.0:
			n.queue_free()
			wrecks.remove_at(i)


func _update_fades(delta: float) -> void:
	for i in range(fades.size() - 1, -1, -1):
		var f: Dictionary = fades[i]
		var l = f["n"]
		if not is_instance_valid(l):
			fades.remove_at(i)
			continue
		f["t"] = float(f["t"]) - delta
		l.light_energy = float(f["e0"]) * clampf(float(f["t"]) / float(f["life"]), 0.0, 1.0)
		if float(f["t"]) <= 0.0:
			l.queue_free()
			fades.remove_at(i)


func _shake_cam(delta: float) -> void:
	if shake <= 0.01:
		return
	shake = move_toward(shake, 0.0, delta * 1.6)
	var amp := shake * 0.35
	var cp: Vector3 = g.cam.position
	g.cam.position = cp + Vector3(rng.randf_range(-amp, amp), rng.randf_range(-amp, amp), rng.randf_range(-amp, amp))


func _synth_explosion() -> AudioStreamWAV:
	var rate := 22050
	var n := int(1.8 * float(rate))
	var s := PackedFloat32Array()
	s.resize(n)
	var lp := 0.0
	for i in n:
		var t := float(i) / float(rate)
		lp += ((randf() * 2.0 - 1.0) - lp) * (0.35 * exp(-t * 1.5) + 0.04)
		var boom := sin(TAU * (48.0 - 20.0 * t) * t) * exp(-t * 2.2)
		s[i] = (lp * exp(-t * 2.5) * 1.6 + boom * 1.2) * 0.85
	return g._wav(s, rate, false)


# ---------------------------------------------------------------- phone (slides up from the bottom)

func _build_phone() -> void:
	pl = CanvasLayer.new()
	pl.layer = 4
	add_child(pl)
	pc = Control.new()
	pc.set_anchors_preset(Control.PRESET_FULL_RECT)
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pc.draw.connect(_draw_phone)
	pl.add_child(pc)
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
	for c in [Color(0.2, 0.75, 0.45), Color(0.25, 0.5, 0.95), Color(0.95, 0.75, 0.2), Color(0.95, 0.55, 0.15), Color(0.5, 0.5, 0.55), Color(0.5, 0.5, 0.55), Color(0.5, 0.5, 0.55), Color(0.5, 0.5, 0.55), Color(0.5, 0.5, 0.55)]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = c
		sb.set_corner_radius_all(28)
		sb_apps.append(sb)


func _prect() -> Rect2:
	var s: Vector2 = g._vp()
	var sz := Vector2(440.0, 900.0) * phone_scale
	var k := phone_t * phone_t * (3.0 - 2.0 * phone_t)
	var y := lerpf(s.y + 30.0, s.y - sz.y - 24.0, k)
	return Rect2(s.x * 0.5 - sz.x * 0.5, y, sz.x, sz.y)


func _icon_rect(i: int) -> Rect2:
	var col := i % 3
	var row := i / 3
	return Rect2(46.0 + float(col) * 128.0, 190.0 + float(row) * 160.0, 104.0, 104.0)


func _phone_tick(delta: float) -> void:
	phone_t = move_toward(phone_t, 1.0 if g.phone_open else 0.0, delta * 3.6)
	g.phone.visible = false
	pc.visible = phone_t > 0.001
	if pc.visible:
		pc.queue_redraw()


func _input(event: InputEvent) -> void:
	if phone_t < 0.4 or not (event is InputEventScreenTouch):
		return
	var e := event as InputEventScreenTouch
	if not e.pressed:
		return
	var r := _prect()
	if not r.has_point(e.position):
		return
	get_viewport().set_input_as_handled()
	var lp := (e.position - r.position) / phone_scale
	if lp.distance_to(Vector2(330, 130)) < 30.0:
		phone_scale = maxf(0.4, phone_scale - 0.08)
		return
	if lp.distance_to(Vector2(380, 130)) < 30.0:
		phone_scale = minf(1.1, phone_scale + 0.08)
		return
	if lp.distance_to(Vector2(220, 845)) < 40.0:
		g._set_phone(false)
		return
	for i in 9:
		if _icon_rect(i).has_point(lp):
			_app(i)
			return


func _app(i: int) -> void:
	if i == 0:
		g._set_phone(false)
		g._set_map(true)
	elif i == 1:
		if car_wrecked:
			respawn_car()
		g._phone_app(1)
	elif i == 2:
		g._set_phone(false)
		g._set_wheel(true)
	elif i == 3:
		g._phone_app(3)
	else:
		g._toast("COMING SOON")


func _glyph(i: int, c: Vector2) -> void:
	var w := Color(1, 1, 1, 0.95)
	if i == 0:
		pc.draw_circle(c + Vector2(0, -8), 18.0, w)
		pc.draw_colored_polygon(PackedVector2Array([c + Vector2(-13, 2), c + Vector2(13, 2), c + Vector2(0, 28)]), w)
		pc.draw_circle(c + Vector2(0, -8), 7.0, Color(0.2, 0.75, 0.45))
	elif i == 1 or i == 3:
		g._icon(pc, "car", c, 22.0)
	elif i == 2:
		g._icon(pc, "guns", c, 22.0)
	elif i == 4:
		pc.draw_rect(Rect2(c + Vector2(-26, -16), Vector2(52, 36)), w, false, 4.0)
		pc.draw_arc(c + Vector2(0, 2), 11.0, 0.0, TAU, 24, w, 4.0, true)
	elif i == 5:
		pc.draw_rect(Rect2(c + Vector2(-26, -22), Vector2(52, 44)), w, false, 4.0)
		pc.draw_colored_polygon(PackedVector2Array([c + Vector2(-22, 18), c + Vector2(-6, -2), c + Vector2(6, 10), c + Vector2(14, 2), c + Vector2(22, 18)]), w)
	elif i == 6:
		pc.draw_arc(c, 26.0, 0.0, TAU, 32, w, 4.0, true)
		pc.draw_line(c, c + Vector2(0, -16), w, 4.0)
		pc.draw_line(c, c + Vector2(12, 6), w, 4.0)
	elif i == 7:
		pc.draw_rect(Rect2(c + Vector2(-22, -8), Vector2(44, 32)), w, false, 4.0)
		pc.draw_arc(c + Vector2(0, -8), 12.0, PI, TAU, 16, w, 4.0, true)
	else:
		pc.draw_arc(c, 17.0, 0.0, TAU, 24, w, 4.0, true)
		for k in 8:
			var a := float(k) * TAU / 8.0
			pc.draw_line(c + Vector2(cos(a), sin(a)) * 19.0, c + Vector2(cos(a), sin(a)) * 27.0, w, 5.0)


func _draw_phone() -> void:
	var r := _prect()
	var vs: Vector2 = g._vp()
	if r.position.y > vs.y:
		return
	pc.draw_set_transform(r.position, 0.0, Vector2(phone_scale, phone_scale))
	pc.draw_style_box(sb_body, Rect2(0, 0, 440, 900))
	pc.draw_style_box(sb_screen, Rect2(20, 20, 400, 860))
	pc.draw_circle(Vector2(320, 270), 120.0, Color(0.35, 0.25, 0.8, 0.16))
	pc.draw_circle(Vector2(130, 650), 140.0, Color(0.1, 0.55, 0.9, 0.12))
	pc.draw_style_box(sb_notch, Rect2(165, 30, 110, 26))
	var t := Time.get_time_dict_from_system()
	pc.draw_string(ThemeDB.fallback_font, Vector2(52, 90), "%02d:%02d" % [t["hour"], t["minute"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color.WHITE)
	pc.draw_string(ThemeDB.fallback_font, Vector2(290, 90), "5G", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(1, 1, 1, 0.8))
	pc.draw_rect(Rect2(342, 70, 40, 20), Color(1, 1, 1, 0.9), false, 2.0)
	pc.draw_rect(Rect2(345, 73, 28, 14), Color(0.4, 0.9, 0.5))
	g._txt(pc, "LOS CITY", Vector2(140, 135), 34, Color(1, 1, 1, 0.9))
	for sgn in [0, 1]:
		var cc := Vector2(330 + sgn * 50, 130)
		pc.draw_circle(cc, 22.0, Color(1, 1, 1, 0.14))
		pc.draw_arc(cc, 22.0, 0.0, TAU, 20, Color(1, 1, 1, 0.8), 2.0, true)
		g._txt(pc, "+" if sgn == 1 else "-", cc, 30)
	for i in 9:
		var ir := _icon_rect(i)
		var soon := i >= 4
		pc.draw_style_box(sb_apps[i], ir)
		_glyph(i, ir.position + ir.size * 0.5 + Vector2(0, -2))
		g._txt(pc, String(APP_NAMES[i]), ir.position + Vector2(52, 124), 19, Color(1, 1, 1, 0.55 if soon else 0.95))
		if soon:
			pc.draw_rect(ir, Color(0, 0, 0, 0.35))
	var hc := Vector2(220, 845)
	pc.draw_circle(hc, 30.0, Color(1, 1, 1, 0.2))
	pc.draw_arc(hc, 30.0, 0.0, TAU, 28, Color(1, 1, 1, 0.85), 3.0, true)
	pc.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
