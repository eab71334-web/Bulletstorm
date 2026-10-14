extends Node
# net.gd - LAN multiplayer (ENet) + auto discovery + phone calls / SMS / voice
# Works the same on iPhone and Android (UDP on the same Wi-Fi).

const PROTO := 1
const GAME_PORT := 24565
const DISC_PORT := 24566
const MAX_PLAYERS := 4
const VOICE_BUS := "VoiceCap"

var g
var active := false
var is_host := false
var connecting := false
var my_id := 1
var players: Dictionary = {}
var states: Dictionary = {}
var found: Dictionary = {}
var status := ""
var conn_t := 0.0
var sess_id := 0
var lan_ip := ""
var pvp := true
var car_seats: Array = [0, 0, 0, 0]
var car_owner := 1
var busy: Dictionary = {}

var bcast: PacketPeerUDP
var listen: PacketPeerUDP
var disc_ok := false
var disc_t := 0.0
var snap_t := 0.0
var state_t := 0.0

var voice_peer := 0
var cap: AudioEffectCapture
var mic_player: AudioStreamPlayer
var voice_players: Dictionary = {}
var voice_buf := PackedByteArray()
var voice_acc := 0.0
var voice_rate := 12000


func _ready() -> void:
	sess_id = randi()
	lan_ip = _guess_ip()
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_conn_failed)
	multiplayer.server_disconnected.connect(_on_server_lost)
	_open_listener()


# ---------------------------------------------------------------- helpers

static func digits(s: String) -> String:
	var o := ""
	for ch in s:
		if ch >= "0" and ch <= "9":
			o += ch
	return o


func _my_info() -> Dictionary:
	return {"name": String(g.prof["name"]), "skin": int(g.prof["skin"]), "number": String(g.prof["number"])}


func _clean(n: String) -> String:
	var s := n.strip_edges().substr(0, 16)
	return s if s != "" else "Player"


func _guess_ip() -> String:
	var best := ""
	for a in IP.get_local_addresses():
		var s := String(a)
		if s.count(".") != 3 or s.begins_with("127.") or s.begins_with("169.254."):
			continue
		if s.begins_with("192.168."):
			return s
		if best == "" and (s.begins_with("10.") or s.begins_with("172.")):
			best = s
		elif best == "":
			best = s
	return best


func _bcast_targets() -> Array:
	var out: Array = ["255.255.255.255"]
	for a in IP.get_local_addresses():
		var s := String(a)
		if s.count(".") != 3 or s.begins_with("127.") or s.begins_with("169.254."):
			continue
		var p := s.split(".")
		out.append("%s.%s.%s.255" % [p[0], p[1], p[2]])
	return out


func find_by_number(num: String) -> int:
	var d := digits(num)
	if d == "":
		return 0
	for id in players.keys():
		if String(players[id]["number"]) == d:
			return int(id)
	return 0


func _number_taken(num: String, except_id: int) -> bool:
	for id in players.keys():
		if int(id) != except_id and String(players[id]["number"]) == num:
			return true
	return false


func _unique_number(n: String, id: int) -> String:
	var d := digits(n)
	if d.length() == 8 and not _number_taken(d, id):
		return d
	while true:
		var s := "7"
		for i in 7:
			s += str(randi() % 10)
		if not _number_taken(s, id):
			return s
	return d


# ---------------------------------------------------------------- discovery

func _open_listener() -> void:
	listen = PacketPeerUDP.new()
	disc_ok = listen.bind(DISC_PORT, "*") == OK
	bcast = PacketPeerUDP.new()
	bcast.set_broadcast_enabled(true)


func _send_beacon() -> void:
	var pkt := JSON.stringify({"g": "TOWERWARS", "v": PROTO, "id": sess_id, "name": String(g.prof["name"]), "n": players.size(), "max": MAX_PLAYERS, "port": GAME_PORT}).to_utf8_buffer()
	for ip in _bcast_targets():
		bcast.set_dest_address(String(ip), DISC_PORT)
		bcast.put_packet(pkt)


func _poll_discovery() -> void:
	if listen == null or not disc_ok:
		return
	while listen.get_available_packet_count() > 0:
		var raw := listen.get_packet()
		var ip := listen.get_packet_ip()
		var d = JSON.parse_string(raw.get_string_from_utf8())
		if typeof(d) != TYPE_DICTIONARY:
			continue
		if String(d.get("g", "")) != "TOWERWARS" or int(d.get("v", 0)) != PROTO:
			continue
		if int(d.get("id", 0)) == sess_id:
			continue
		found[ip] = {"name": String(d.get("name", "?")), "n": int(d.get("n", 1)), "max": int(d.get("max", MAX_PLAYERS)), "seen": Time.get_ticks_msec()}
	var now := Time.get_ticks_msec()
	for k in found.keys():
		if now - int(found[k]["seen"]) > 3500:
			found.erase(k)


# ---------------------------------------------------------------- connection

func start_host() -> bool:
	if active:
		return is_host
	var peer := ENetMultiplayerPeer.new()
	if peer.create_server(GAME_PORT, MAX_PLAYERS - 1) != OK:
		status = "Cannot open the game (port busy)"
		return false
	multiplayer.multiplayer_peer = peer
	active = true
	is_host = true
	my_id = 1
	players = {1: _my_info()}
	states.clear()
	busy.clear()
	car_seats = [0, 0, 0, 0]
	car_owner = 1
	status = "Hosting"
	return true


func stop_host() -> void:
	if not is_host:
		return
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	active = false
	is_host = false
	players.clear()
	states.clear()


func join(ip: String) -> bool:
	if active and not is_host:
		leave()
	if is_host:
		stop_host()
	var peer := ENetMultiplayerPeer.new()
	if peer.create_client(ip.strip_edges(), GAME_PORT) != OK:
		status = "Cannot connect"
		return false
	multiplayer.multiplayer_peer = peer
	connecting = true
	conn_t = 0.0
	status = "Connecting..."
	return true


func leave() -> void:
	voice_stop()
	var was_client := (active or connecting) and not is_host
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	active = false
	is_host = false
	connecting = false
	players.clear()
	states.clear()
	my_id = 1
	if was_client:
		g.net_lost("")


func _fail(msg: String) -> void:
	status = msg
	connecting = false
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	active = false


func _on_connected() -> void:
	my_id = multiplayer.get_unique_id()
	active = true
	is_host = false
	send_srv("c_hello", {"proto": PROTO, "name": String(g.prof["name"]), "skin": int(g.prof["skin"]), "number": String(g.prof["number"])})


func _on_conn_failed() -> void:
	_fail("Connection failed")


func _on_server_lost() -> void:
	voice_stop()
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	active = false
	is_host = false
	connecting = false
	players.clear()
	status = "The host left the game"
	g.net_lost(status)


func _on_peer_disconnected(id: int) -> void:
	if not is_host:
		return
	var nm := String(players.get(id, {}).get("name", "?"))
	players.erase(id)
	states.erase(id)
	busy.erase(id)
	for i in 4:
		if car_seats[i] == id:
			car_seats[i] = 0
	_update_car_owner()
	_broadcast_car()
	for pid in players.keys():
		send_to(int(pid), "h_left", {"id": id, "name": nm})


# ---------------------------------------------------------------- transport

func send_to(id: int, kind: String, data: Dictionary, reliable: bool = true) -> void:
	if id == my_id:
		_dispatch(my_id, kind, data)
		return
	if not active:
		return
	if reliable:
		rpc_id(id, "r_evt", kind, data)
	else:
		rpc_id(id, "u_evt", kind, data)


func send_srv(kind: String, data: Dictionary, reliable: bool = true) -> void:
	send_to(1, kind, data, reliable)


@rpc("any_peer", "call_remote", "reliable")
func r_evt(kind: String, data: Dictionary) -> void:
	_dispatch(multiplayer.get_remote_sender_id(), kind, data)


@rpc("any_peer", "call_remote", "unreliable")
func u_evt(kind: String, data: Dictionary) -> void:
	_dispatch(multiplayer.get_remote_sender_id(), kind, data)


func _dispatch(sender: int, kind: String, data: Dictionary) -> void:
	if kind.begins_with("c_"):
		if is_host:
			_srv(sender, kind, data)
	elif kind.begins_with("h_"):
		if sender == 1 or sender == my_id:
			_cli(kind, data)


# ---------------------------------------------------------------- process / ticks

func _process(delta: float) -> void:
	_poll_discovery()
	if is_host and active:
		disc_t -= delta
		if disc_t <= 0.0:
			disc_t = 1.0
			_send_beacon()
	if connecting:
		conn_t += delta
		if conn_t > 7.0:
			_fail("Connection timed out")
	if active and (is_host or not players.is_empty()):
		state_t -= delta
		snap_t -= delta
		if not is_host:
			if state_t <= 0.0:
				state_t = 1.0 / 15.0
				send_srv("c_state", g.net_local_state(), false)
		elif snap_t <= 0.0 and multiplayer.get_peers().size() > 0:
			snap_t = 1.0 / 12.0
			_send_snapshot()
	_voice_tick(delta)


func _send_snapshot() -> void:
	var pl := PackedFloat32Array()
	for id in players.keys():
		var st: Dictionary = g.net_local_state() if int(id) == my_id else states.get(id, {})
		if st.is_empty():
			continue
		var p: Vector3 = st.get("p", Vector3.ZERO)
		pl.append_array(PackedFloat32Array([float(id), p.x, p.y, p.z, float(st.get("y", 0.0)), float(st.get("f", 0)), float(st.get("s", 0.0)), float(st.get("hp", 100.0)), float(st.get("w", 1))]))
	var car := PackedFloat32Array()
	var ost: Dictionary = g.net_local_state() if car_owner == my_id else states.get(car_owner, {})
	if ost.has("car"):
		car = ost["car"]
	var peds: PackedFloat32Array = g.net_collect_peds()
	for id in players.keys():
		if int(id) != my_id:
			send_to(int(id), "h_snap", {"pl": pl, "peds": peds, "car": car}, false)
	g.net_apply_snapshot(pl, PackedFloat32Array(), car, false)


# ---------------------------------------------------------------- car seats

func srv_car_enter(id: int) -> int:
	for i in 4:
		if car_seats[i] == id:
			return i
	if car_seats[0] == 0:
		car_seats[0] = id
		_update_car_owner()
		return 0
	for i in range(1, 4):
		if car_seats[i] == 0:
			car_seats[i] = id
			return i
	return -1


func srv_car_exit(id: int) -> void:
	for i in 4:
		if car_seats[i] == id:
			car_seats[i] = 0
	_update_car_owner()


func _update_car_owner() -> void:
	car_owner = int(car_seats[0]) if int(car_seats[0]) != 0 else 1


func _broadcast_car() -> void:
	for pid in players.keys():
		send_to(int(pid), "h_car", {"seats": car_seats.duplicate(), "owner": car_owner})


func request_car_enter() -> void:
	if not active:
		g._enter_car(0)
		return
	if is_host:
		var seat := srv_car_enter(1)
		if seat < 0:
			g._toast("CAR IS FULL")
			return
		g._enter_car(seat)
		_broadcast_car()
	else:
		send_srv("c_car_enter", {})


func request_car_exit() -> void:
	if not active:
		return
	if is_host:
		srv_car_exit(1)
		_broadcast_car()
	else:
		send_srv("c_car_exit", {})


# ---------------------------------------------------------------- host side

func _srv(sender: int, kind: String, d: Dictionary) -> void:
	match kind:
		"c_hello":
			_srv_hello(sender, d)
		"c_state":
			if players.has(sender):
				states[sender] = d
		"c_msg":
			_srv_msg(sender, d)
		"c_call_start":
			_srv_call_start(sender, d)
		"c_call_answer":
			var caller := int(d.get("from", 0))
			if bool(d.get("ok", false)):
				busy[sender] = caller
				busy[caller] = sender
			send_to(caller, "h_call_result", {"ok": bool(d.get("ok", false)), "peer": sender})
		"c_call_end":
			var other := int(d.get("other", 0))
			busy.erase(sender)
			busy.erase(other)
			send_to(other, "h_call_ended", {})
		"c_voice":
			send_to(int(d.get("to", 0)), "h_voice", {"from": sender, "d": d.get("d", PackedByteArray()), "r": int(d.get("r", 12000))}, false)
		"c_hit_player":
			var tid := int(d.get("target", 0))
			if pvp and players.has(tid) and tid != sender:
				send_to(tid, "h_damage", {"dmg": float(d.get("dmg", 0.0)), "by": sender})
		"c_hit_ped":
			g.net_host_hit_ped(int(d.get("nid", -1)), float(d.get("dmg", 0.0)), sender)
		"c_shot":
			if sender != my_id:
				g._alarm(d.get("from", Vector3.ZERO), 30.0)
			for pid in players.keys():
				if int(pid) != sender:
					send_to(int(pid), "h_shot", {"from": d.get("from", Vector3.ZERO), "to": d.get("to", Vector3.ZERO), "w": int(d.get("w", 1))}, false)
		"c_car_enter":
			var seat := srv_car_enter(sender)
			if seat < 0:
				send_to(sender, "h_car_full", {})
			else:
				send_to(sender, "h_car_ok", {"seat": seat})
				_broadcast_car()
		"c_car_exit":
			srv_car_exit(sender)
			_broadcast_car()
		"c_died":
			var vn := String(players.get(sender, {}).get("name", "?"))
			var kid := int(d.get("killer", 0))
			var kn := String(players.get(kid, {}).get("name", ""))
			for pid in players.keys():
				send_to(int(pid), "h_kill", {"killer": kn, "victim": vn})


func _srv_hello(id: int, d: Dictionary) -> void:
	if int(d.get("proto", 0)) != PROTO:
		send_to(id, "h_reject", {"why": "Different game version"})
		_kick_later(id)
		return
	if players.size() >= MAX_PLAYERS:
		send_to(id, "h_reject", {"why": "Game is full"})
		_kick_later(id)
		return
	var num := _unique_number(String(d.get("number", "")), id)
	players[id] = {"name": _clean(String(d.get("name", "Player"))), "skin": int(d.get("skin", 0)), "number": num}
	send_to(id, "h_welcome", {"id": id, "number": num, "players": players, "pvp": pvp, "seats": car_seats, "owner": car_owner})
	for pid in players.keys():
		if int(pid) != id:
			send_to(int(pid), "h_joined", {"id": id, "info": players[id]})


func _kick_later(id: int) -> void:
	await get_tree().create_timer(0.4).timeout
	if multiplayer.multiplayer_peer != null and is_host:
		multiplayer.multiplayer_peer.disconnect_peer(id)


func _srv_msg(sender: int, d: Dictionary) -> void:
	var to := digits(String(d.get("to", "")))
	var tid := find_by_number(to)
	if tid == 0 or tid == sender:
		send_to(sender, "h_msg_fail", {"to": to})
		return
	var me: Dictionary = players.get(sender, {})
	send_to(tid, "h_msg", {"from": String(me.get("number", "")), "name": String(me.get("name", "?")), "text": String(d.get("text", "")).substr(0, 140)})


func _srv_call_start(sender: int, d: Dictionary) -> void:
	var tid := find_by_number(String(d.get("to", "")))
	if tid == 0 or tid == sender:
		send_to(sender, "h_call_fail", {"why": "nonumber"})
		return
	if busy.has(tid) or busy.has(sender):
		send_to(sender, "h_call_fail", {"why": "busy"})
		return
	var me: Dictionary = players.get(sender, {})
	send_to(tid, "h_ring", {"from": sender, "name": String(me.get("name", "?")), "number": String(me.get("number", ""))})
	send_to(sender, "h_calling", {"to": tid})


# ---------------------------------------------------------------- client side

func _cli(kind: String, d: Dictionary) -> void:
	match kind:
		"h_reject":
			status = String(d.get("why", "Rejected"))
			var why := status
			_fail(why)
			g.net_lost(why)
		"h_welcome":
			my_id = int(d["id"])
			players = d["players"]
			pvp = bool(d.get("pvp", true))
			car_seats = d.get("seats", [0, 0, 0, 0])
			car_owner = int(d.get("owner", 1))
			g.prof["number"] = String(d["number"])
			g.save_profile()
			connecting = false
			status = "Connected"
			g.net_joined(players)
		"h_joined":
			players[int(d["id"])] = d["info"]
			g.net_player_joined(int(d["id"]), d["info"])
		"h_left":
			players.erase(int(d["id"]))
			g.net_player_left(int(d["id"]), String(d.get("name", "")))
		"h_snap":
			if not is_host:
				g.net_apply_snapshot(d["pl"], d["peds"], d["car"], true)
		"h_msg":
			if g.apps != null:
				g.apps.receive_message(String(d["from"]), String(d["name"]), String(d["text"]))
		"h_msg_fail":
			if g.apps != null:
				g.apps.msg_failed(String(d["to"]))
		"h_ring":
			if g.apps != null:
				g.apps.incoming_call(int(d["from"]), String(d["name"]), String(d["number"]))
		"h_calling":
			pass
		"h_call_fail":
			if g.apps != null:
				g.apps.call_failed(String(d.get("why", "")))
		"h_call_result":
			if g.apps != null:
				g.apps.call_result(bool(d.get("ok", false)), int(d.get("peer", 0)))
		"h_call_ended":
			if g.apps != null:
				g.apps.call_remote_ended()
		"h_voice":
			_voice_play(int(d["from"]), d["d"], int(d["r"]))
		"h_damage":
			g.net_damage(float(d["dmg"]), int(d["by"]))
		"h_shot":
			g.net_remote_shot(d["from"], d["to"], int(d["w"]))
		"h_car_ok":
			g._enter_car(int(d["seat"]))
		"h_car_full":
			g._toast("CAR IS FULL")
		"h_car":
			car_seats = d["seats"]
			car_owner = int(d["owner"])
		"h_kill":
			g.net_kill_feed(String(d["killer"]), String(d["victim"]))
		"h_reward":
			if g.apps != null:
				g.apps.add_money(int(d["n"]))


# ---------------------------------------------------------------- voice chat

func voice_start(peer: int) -> void:
	voice_peer = peer
	_ensure_voice()


func voice_stop() -> void:
	voice_peer = 0
	voice_buf = PackedByteArray()
	for k in voice_players.keys():
		var vp: Dictionary = voice_players[k]
		if is_instance_valid(vp["p"]):
			(vp["p"] as Node).queue_free()
	voice_players.clear()


func _ensure_voice() -> void:
	if mic_player != null:
		return
	if OS.get_name() == "Android":
		OS.request_permission("RECORD_AUDIO")
	var idx := AudioServer.get_bus_index(VOICE_BUS)
	if idx < 0:
		AudioServer.add_bus()
		idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, VOICE_BUS)
		cap = AudioEffectCapture.new()
		AudioServer.add_bus_effect(idx, cap)
		AudioServer.set_bus_volume_db(idx, -60.0)
	else:
		cap = AudioServer.get_bus_effect(idx, 0) as AudioEffectCapture
	mic_player = AudioStreamPlayer.new()
	mic_player.stream = AudioStreamMicrophone.new()
	mic_player.bus = VOICE_BUS
	add_child(mic_player)
	mic_player.play()


func _voice_tick(delta: float) -> void:
	if voice_peer == 0 or cap == null:
		return
	var n := cap.get_frames_available()
	if n <= 0:
		return
	var buf := cap.get_buffer(n)
	var mr := AudioServer.get_mix_rate()
	var ds := maxi(int(round(mr / 12000.0)), 1)
	voice_rate = int(mr / float(ds))
	var i := 0
	while i < buf.size():
		var s := int(clampf((buf[i].x + buf[i].y) * 0.75, -1.0, 1.0) * 32000.0)
		voice_buf.append(s & 0xFF)
		voice_buf.append((s >> 8) & 0xFF)
		i += ds
	voice_acc += delta
	if voice_acc >= 0.06 and voice_buf.size() > 0:
		voice_acc = 0.0
		send_srv("c_voice", {"to": voice_peer, "d": voice_buf, "r": voice_rate}, false)
		voice_buf = PackedByteArray()


func _voice_play(from: int, d: PackedByteArray, rate: int) -> void:
	if voice_peer == 0:
		return
	var vp = voice_players.get(from, null)
	if vp == null:
		var pl := AudioStreamPlayer.new()
		var gen := AudioStreamGenerator.new()
		gen.mix_rate = float(rate)
		gen.buffer_length = 0.6
		pl.stream = gen
		pl.volume_db = 6.0
		add_child(pl)
		pl.play()
		vp = {"p": pl, "pb": pl.get_stream_playback()}
		voice_players[from] = vp
	var pb: AudioStreamGeneratorPlayback = vp["pb"]
	if pb == null:
		return
	var m := mini(d.size() / 2, pb.get_frames_available())
	var frames := PackedVector2Array()
	frames.resize(m)
	for i in m:
		var v := (int(d[i * 2 + 1]) << 8) | int(d[i * 2])
		if v >= 32768:
			v -= 65536
		var f := float(v) / 32768.0
		frames[i] = Vector2(f, f)
	pb.push_buffer(frames)
