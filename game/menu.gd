extends Node
# menu.gd - GTA-style intro, main menu, character, settings, LAN lobby

const MT := {
	"en": {"play": "PLAY", "resume": "RESUME", "multi": "MULTIPLAYER", "char": "CHARACTER", "set": "SETTINGS", "back": "BACK", "tag": "OPEN WORLD   |   LOS CITY", "name": "PLAYER NAME", "skin": "CHARACTER", "num": "YOUR PHONE NUMBER", "newnum": "NEW NUMBER", "pop": "POPULATION", "qual": "GRAPHICS / RESOLUTION", "fps": "FRAME RATE", "shadow": "SHADOWS", "police": "POLICE", "pvp": "PLAYER VS PLAYER", "lan": "OPEN TO FRIENDS (LAN)", "showfps": "SHOW FPS", "sens": "CAMERA SENSITIVITY", "vol": "VOLUME", "low": "LOW", "norm": "NORMAL", "high": "HIGH", "med": "MEDIUM", "off": "OFF", "on": "ON", "plow": "LOW", "pnorm": "NORMAL", "phigh": "HIGH", "games": "GAMES ON YOUR WI-FI", "none": "No games found.\nAsk your friend to start the game on the same Wi-Fi.", "join": "JOIN", "ip": "OR ENTER HIS IP ADDRESS", "yourip": "YOUR IP", "host": "Your game is open to friends on the same Wi-Fi", "hostoff": "Your game is private (turn on LAN in settings)", "conn": "Connecting...", "leave": "LEAVE GAME", "tip": "Cross-play: iPhone and Android on the same Wi-Fi.", "phone": "PHONE", "hint": "Name"},
	"ar": {"play": "ابدأ اللعب", "resume": "متابعة", "multi": "لعب جماعي", "char": "الشخصية", "set": "الإعدادات", "back": "رجوع", "tag": "عالم مفتوح   |   لوس سيتي", "name": "اسم اللاعب", "skin": "الشخصية", "num": "رقم هاتفك", "newnum": "رقم جديد", "pop": "عدد السكان", "qual": "الدقة والرسومات", "fps": "معدل الإطارات", "shadow": "الظلال", "police": "الشرطة", "pvp": "قتال اللاعبين", "lan": "مفتوح للأصدقاء (LAN)", "showfps": "عرض الإطارات", "sens": "حساسية الكاميرا", "vol": "الصوت", "low": "منخفضة", "norm": "عادية", "high": "عالية", "med": "متوسطة", "off": "إيقاف", "on": "تشغيل", "plow": "قليل", "pnorm": "عادي", "phigh": "كثير", "games": "ألعاب على شبكتك", "none": "لا توجد ألعاب.\nاطلب من صديقك فتح اللعبة على نفس الواي فاي.", "join": "انضمام", "ip": "أو اكتب عنوان IP الخاص به", "yourip": "عنوان IP الخاص بك", "host": "لعبتك مفتوحة للأصدقاء على نفس الشبكة", "hostoff": "لعبتك خاصة (فعّل LAN من الإعدادات)", "conn": "جاري الاتصال...", "leave": "مغادرة اللعبة", "tip": "اللعب المشترك: آيفون وأندرويد على نفس الواي فاي.", "phone": "الهاتف", "hint": "الاسم"},
}

var g
var lk := "en"
var layer: CanvasLayer
var root: Control
var fade: ColorRect
var bar_t: ColorRect
var bar_b: ColorRect
var title: Label
var tagline: Label
var card: Panel
var card_av: Label
var card_name: Label
var card_num: Label
var scr: Dictionary = {}
var cur := ""
var resumed := false
var intro_done := false
var b_play: Button
var b_leave: Button
var name_edit: LineEdit
var skin_lbl: Label
var num_lbl: Label
var ip_edit: LineEdit
var status_lbl: Label
var host_lbl: Label
var ip_lbl: Label
var list_box: VBoxContainer
var last_sig := "x"
var segs: Dictionary = {}
var sliders: Dictionary = {}
var click_snd: AudioStreamPlayer
var dbg: Label
var safe_btn: Button


func _t(k: String) -> String:
	var d: Dictionary = MT[lk]
	if d.has(k):
		return String(d[k])
	return String(MT["en"].get(k, k))


# ---------------------------------------------------------------- build helpers

func _sb(bg: Color, border: Color, rad: int, bw: int = 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(rad)
	s.border_color = border
	s.set_border_width_all(bw)
	s.content_margin_left = 26
	s.content_margin_right = 26
	return s


func _lbl(text: String, size: int, col: Color = Color.WHITE, al: int = 0) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = al as HorizontalAlignment
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	return l


func _btn(text: String, size: Vector2, accent: bool = false, fs: int = 30) -> Button:
	var b := Button.new()
	b.text = text
	b.size = size
	b.custom_minimum_size = size
	b.focus_mode = Control.FOCUS_NONE
	b.alignment = HORIZONTAL_ALIGNMENT_CENTER if lk == "ar" else HORIZONTAL_ALIGNMENT_LEFT
	var bg := Color(0.14, 0.5, 1.0, 0.95) if accent else Color(0.07, 0.09, 0.14, 0.8)
	var bd := Color(1, 1, 1, 0.5) if accent else Color(1, 1, 1, 0.16)
	b.add_theme_stylebox_override("normal", _sb(bg, bd, 16, 2))
	b.add_theme_stylebox_override("hover", _sb(bg.lightened(0.12), bd, 16, 2))
	b.add_theme_stylebox_override("pressed", _sb(bg.darkened(0.2), bd, 16, 2))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_font_size_override("font_size", fs)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color.WHITE)
	b.pressed.connect(_click)
	return b


func _panel(r: Rect2, alpha: float = 0.72) -> Panel:
	var p := Panel.new()
	p.position = r.position
	p.size = r.size
	p.add_theme_stylebox_override("panel", _sb(Color(0.04, 0.06, 0.1, alpha), Color(1, 1, 1, 0.14), 22, 2))
	return p


func _screen(n: String) -> Control:
	var c := Control.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(c)
	scr[n] = c
	c.visible = false
	return c


func _dbg(t: String) -> void:
	if dbg != null:
		dbg.text = "menu build: " + t


func _safe_play() -> void:
	root.visible = false
	g.menu_active = false
	g.cam_ease = 1.6
	g.net_autostart = true
	g.apply_gset()


func _click() -> void:
	if click_snd != null:
		click_snd.play()


# ---------------------------------------------------------------- build

func _ready() -> void:
	if g.apps != null and String(g.apps.lang) == "ar":
		lk = "ar"
	layer = CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	var th := Theme.new()
	var sf := SystemFont.new()
	sf.font_names = PackedStringArray(["Geeza Pro", "Noto Sans Arabic", "Arial", "Helvetica"])
	var fb: Array[Font] = [ThemeDB.fallback_font]
	sf.fallbacks = fb
	th.default_font = sf
	th.default_font_size = 26
	root.theme = th
	click_snd = AudioStreamPlayer.new()
	click_snd.stream = g._synth_click(1)
	click_snd.volume_db = -6.0
	add_child(click_snd)

	var vp: Vector2 = g._vp()
	dbg = _lbl("menu: start", 20, Color(1, 0.6, 0.2))
	dbg.position = Vector2(30, vp.y - 50)
	dbg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(dbg)
	safe_btn = _btn("PLAY", Vector2(260, 80), true, 32)
	safe_btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	safe_btn.position = Vector2(vp.x * 0.5 - 130.0, vp.y - 130.0)
	safe_btn.pressed.connect(_safe_play)
	root.add_child(safe_btn)
	bar_t = ColorRect.new()
	bar_t.color = Color.BLACK
	bar_t.size = Vector2(vp.x, 0)
	bar_t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bar_t)
	bar_b = ColorRect.new()
	bar_b.color = Color.BLACK
	bar_b.size = Vector2(vp.x, 0)
	bar_b.position = Vector2(0, vp.y)
	bar_b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bar_b)

	title = _lbl("TOWER WARS", 128, Color.WHITE)
	title.position = Vector2(90, 70)
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	title.add_theme_constant_override("outline_size", 10)
	title.modulate.a = 0.0
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(title)
	tagline = _lbl(_t("tag"), 26, Color(1, 0.85, 0.4))
	tagline.position = Vector2(98, 212)
	tagline.modulate.a = 0.0
	tagline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(tagline)

	_dbg("card")
	_build_card(vp)
	_dbg("main")
	_build_main(vp)
	_dbg("char")
	_build_char(vp)
	_dbg("settings")
	_build_settings(vp)
	_dbg("multi")
	_build_multi(vp)
	_dbg("fade")

	fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(fade)
	refresh_profile()
	_dbg("")
	dbg.visible = false
	safe_btn.visible = false
	_intro()


func _build_card(vp: Vector2) -> void:
	card = _panel(Rect2(vp.x - 520, 90, 450, 150), 0.78)
	card.modulate.a = 0.0
	root.add_child(card)
	var av := Panel.new()
	av.position = Vector2(22, 25)
	av.size = Vector2(100, 100)
	av.add_theme_stylebox_override("panel", _sb(Color(0.14, 0.5, 1.0), Color(1, 1, 1, 0.8), 50, 3))
	card.add_child(av)
	card_av = _lbl("P", 56, Color.WHITE, 1)
	card_av.size = Vector2(100, 100)
	card_av.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	av.add_child(card_av)
	card_name = _lbl("", 36, Color.WHITE)
	card_name.position = Vector2(145, 22)
	card_name.size = Vector2(290, 50)
	card_name.clip_text = true
	card.add_child(card_name)
	var pl := _lbl(_t("phone"), 18, Color(1, 1, 1, 0.55))
	pl.position = Vector2(145, 78)
	card.add_child(pl)
	card_num = _lbl("", 34, Color(0.4, 1, 0.55))
	card_num.position = Vector2(145, 98)
	card.add_child(card_num)


func _build_main(vp: Vector2) -> void:
	var s := _screen("main")
	var x := 90.0
	var y := vp.y * 0.42
	b_play = _btn(_t("play"), Vector2(500, 92), true, 36)
	b_play.position = Vector2(x, y)
	b_play.pressed.connect(_on_play)
	s.add_child(b_play)
	var bm := _btn(_t("multi"), Vector2(500, 82))
	bm.position = Vector2(x, y + 106)
	bm.pressed.connect(show_screen.bind("multi"))
	s.add_child(bm)
	var bc := _btn(_t("char"), Vector2(500, 82))
	bc.position = Vector2(x, y + 202)
	bc.pressed.connect(show_screen.bind("char"))
	s.add_child(bc)
	var bs := _btn(_t("set"), Vector2(500, 82))
	bs.position = Vector2(x, y + 298)
	bs.pressed.connect(show_screen.bind("set"))
	s.add_child(bs)
	b_leave = _btn(_t("leave"), Vector2(500, 70), false, 26)
	b_leave.position = Vector2(x, y + 394)
	b_leave.pressed.connect(_on_leave)
	s.add_child(b_leave)


func _build_char(vp: Vector2) -> void:
	var s := _screen("char")
	var px := vp.x - 620.0
	var p := _panel(Rect2(px, 100, 560, 560))
	s.add_child(p)
	var l1 := _lbl(_t("name"), 20, Color(1, 1, 1, 0.55))
	l1.position = Vector2(px + 30, 124)
	s.add_child(l1)
	name_edit = LineEdit.new()
	name_edit.position = Vector2(px + 30, 156)
	name_edit.size = Vector2(500, 70)
	name_edit.max_length = 16
	name_edit.placeholder_text = _t("hint")
	name_edit.add_theme_font_size_override("font_size", 34)
	name_edit.add_theme_stylebox_override("normal", _sb(Color(1, 1, 1, 0.1), Color(1, 1, 1, 0.3), 14, 2))
	name_edit.add_theme_stylebox_override("focus", _sb(Color(1, 1, 1, 0.16), Color(0.3, 0.7, 1.0), 14, 2))
	name_edit.text_changed.connect(_on_name)
	name_edit.text_submitted.connect(_on_name_done)
	s.add_child(name_edit)
	var l2 := _lbl(_t("skin"), 20, Color(1, 1, 1, 0.55))
	l2.position = Vector2(px + 30, 256)
	s.add_child(l2)
	var bl := _btn("<", Vector2(90, 80), false, 40)
	bl.alignment = HORIZONTAL_ALIGNMENT_CENTER
	bl.position = Vector2(px + 30, 290)
	bl.pressed.connect(_on_skin.bind(-1))
	s.add_child(bl)
	skin_lbl = _lbl("1 / 1", 34, Color.WHITE, 1)
	skin_lbl.position = Vector2(px + 130, 310)
	skin_lbl.size = Vector2(300, 50)
	s.add_child(skin_lbl)
	var br := _btn(">", Vector2(90, 80), false, 40)
	br.alignment = HORIZONTAL_ALIGNMENT_CENTER
	br.position = Vector2(px + 440, 290)
	br.pressed.connect(_on_skin.bind(1))
	s.add_child(br)
	var l3 := _lbl(_t("num"), 20, Color(1, 1, 1, 0.55))
	l3.position = Vector2(px + 30, 400)
	s.add_child(l3)
	num_lbl = _lbl("", 48, Color(0.4, 1, 0.55))
	num_lbl.position = Vector2(px + 30, 428)
	s.add_child(num_lbl)
	var bn := _btn(_t("newnum"), Vector2(300, 64), false, 24)
	bn.position = Vector2(px + 30, 500)
	bn.pressed.connect(_on_newnum)
	s.add_child(bn)
	var bb := _btn(_t("back"), Vector2(240, 70), true, 28)
	bb.alignment = HORIZONTAL_ALIGNMENT_CENTER
	bb.position = Vector2(px + 290, 575)
	bb.pressed.connect(show_screen.bind("main"))
	s.add_child(bb)


func _seg_row(parent: VBoxContainer, id: String, label: String, opts: Array) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 72)
	row.add_theme_constant_override("separation", 14)
	var l := _lbl(label, 26, Color.WHITE)
	l.custom_minimum_size = Vector2(430, 0)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(l)
	var arr: Array = []
	for i in opts.size():
		var b := _btn(String(opts[i]), Vector2(170, 60), false, 22)
		b.alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.pressed.connect(_on_seg.bind(id, i))
		row.add_child(b)
		arr.append(b)
	segs[id] = arr
	parent.add_child(row)


func _slider_row(parent: VBoxContainer, id: String, label: String, mn: float, mx: float) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 72)
	row.add_theme_constant_override("separation", 14)
	var l := _lbl(label, 26, Color.WHITE)
	l.custom_minimum_size = Vector2(430, 0)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(l)
	var sl := HSlider.new()
	sl.min_value = mn
	sl.max_value = mx
	sl.step = 0.05
	sl.custom_minimum_size = Vector2(520, 60)
	sl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sl.value_changed.connect(_on_slider.bind(id))
	row.add_child(sl)
	sliders[id] = sl
	parent.add_child(row)


func _build_settings(vp: Vector2) -> void:
	var s := _screen("set")
	var p := _panel(Rect2(60, 100, vp.x - 120, vp.y - 250), 0.8)
	s.add_child(p)
	var sc := ScrollContainer.new()
	sc.position = Vector2(100, 120)
	sc.size = Vector2(vp.x - 200, vp.y - 290)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	s.add_child(sc)
	var vb := VBoxContainer.new()
	vb.custom_minimum_size = Vector2(vp.x - 230, 0)
	vb.add_theme_constant_override("separation", 6)
	sc.add_child(vb)
	_seg_row(vb, "pop", _t("pop"), [_t("plow"), _t("pnorm"), _t("phigh")])
	_seg_row(vb, "quality", _t("qual"), [_t("low"), _t("med"), _t("high")])
	_seg_row(vb, "fpscap", _t("fps"), ["30", "60", "120"])
	_seg_row(vb, "shadows", _t("shadow"), [_t("off"), _t("on")])
	_seg_row(vb, "police", _t("police"), [_t("off"), _t("on")])
	_seg_row(vb, "pvp", _t("pvp"), [_t("off"), _t("on")])
	_seg_row(vb, "lan", _t("lan"), [_t("off"), _t("on")])
	_seg_row(vb, "showfps", _t("showfps"), [_t("off"), _t("on")])
	_slider_row(vb, "sens", _t("sens"), 0.4, 2.0)
	_slider_row(vb, "volume", _t("vol"), 0.0, 1.0)
	var bb := _btn(_t("back"), Vector2(260, 76), true, 28)
	bb.alignment = HORIZONTAL_ALIGNMENT_CENTER
	bb.position = Vector2(vp.x - 340, vp.y - 140)
	bb.pressed.connect(show_screen.bind("main"))
	s.add_child(bb)


func _build_multi(vp: Vector2) -> void:
	var s := _screen("multi")
	var lw := vp.x * 0.44
	s.add_child(_panel(Rect2(60, 100, lw, vp.y - 250)))
	var h1 := _lbl(_t("games"), 24, Color(1, 1, 1, 0.6))
	h1.position = Vector2(90, 118)
	s.add_child(h1)
	var sc := ScrollContainer.new()
	sc.position = Vector2(90, 160)
	sc.size = Vector2(lw - 60, vp.y - 340)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	s.add_child(sc)
	list_box = VBoxContainer.new()
	list_box.custom_minimum_size = Vector2(lw - 80, 0)
	list_box.add_theme_constant_override("separation", 12)
	sc.add_child(list_box)

	var rx := 60.0 + lw + 40.0
	var rw := vp.x - rx - 60.0
	s.add_child(_panel(Rect2(rx, 100, rw, vp.y - 250)))
	var h2 := _lbl(_t("ip"), 24, Color(1, 1, 1, 0.6))
	h2.position = Vector2(rx + 30, 118)
	s.add_child(h2)
	ip_edit = LineEdit.new()
	ip_edit.position = Vector2(rx + 30, 160)
	ip_edit.size = Vector2(rw - 60, 70)
	ip_edit.placeholder_text = "192.168.1.20"
	ip_edit.add_theme_font_size_override("font_size", 32)
	ip_edit.add_theme_stylebox_override("normal", _sb(Color(1, 1, 1, 0.1), Color(1, 1, 1, 0.3), 14, 2))
	ip_edit.add_theme_stylebox_override("focus", _sb(Color(1, 1, 1, 0.16), Color(0.3, 0.7, 1.0), 14, 2))
	ip_edit.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_DEFAULT
	ip_edit.text_submitted.connect(_on_ip_submit)
	s.add_child(ip_edit)
	var bj := _btn(_t("join"), Vector2(rw - 60, 76), true, 30)
	bj.alignment = HORIZONTAL_ALIGNMENT_CENTER
	bj.position = Vector2(rx + 30, 246)
	bj.pressed.connect(_on_ip_join)
	s.add_child(bj)
	status_lbl = _lbl("", 26, Color(1, 0.85, 0.4))
	status_lbl.position = Vector2(rx + 30, 340)
	status_lbl.size = Vector2(rw - 60, 80)
	status_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	s.add_child(status_lbl)
	ip_lbl = _lbl("", 24, Color(1, 1, 1, 0.7))
	ip_lbl.position = Vector2(rx + 30, 440)
	s.add_child(ip_lbl)
	host_lbl = _lbl("", 22, Color(0.4, 1, 0.55))
	host_lbl.position = Vector2(rx + 30, 480)
	host_lbl.size = Vector2(rw - 60, 70)
	host_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	s.add_child(host_lbl)
	var tip := _lbl(_t("tip"), 20, Color(1, 1, 1, 0.45))
	tip.position = Vector2(rx + 30, 560)
	tip.size = Vector2(rw - 60, 60)
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	s.add_child(tip)
	var bb := _btn(_t("back"), Vector2(260, 76), true, 28)
	bb.alignment = HORIZONTAL_ALIGNMENT_CENTER
	bb.position = Vector2(vp.x - 340, vp.y - 140)
	bb.pressed.connect(show_screen.bind("main"))
	s.add_child(bb)


# ---------------------------------------------------------------- flow

func _intro() -> void:
	var vp: Vector2 = g._vp()
	g.menu_cam = 1
	var tw := create_tween().set_parallel(true)
	tw.tween_property(bar_t, "size:y", 70.0, 1.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(bar_b, "size:y", 70.0, 1.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(bar_b, "position:y", vp.y - 70.0, 1.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(fade, "color:a", 0.0, 2.6).set_delay(0.3)
	await get_tree().create_timer(1.8).timeout
	title.pivot_offset = Vector2(300, 60)
	title.scale = Vector2(1.18, 1.18)
	var t2 := create_tween().set_parallel(true)
	t2.tween_property(title, "modulate:a", 1.0, 1.2)
	t2.tween_property(title, "scale", Vector2.ONE, 1.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t2.tween_property(tagline, "modulate:a", 1.0, 1.2).set_delay(0.6)
	t2.tween_property(card, "modulate:a", 1.0, 0.9).set_delay(1.4)
	await get_tree().create_timer(1.8).timeout
	intro_done = true
	show_screen("main")
	g.net_autostart = true
	g.apply_gset()


func show_screen(n: String) -> void:
	cur = n
	for k in scr.keys():
		(scr[k] as Control).visible = (k == n)
	g.menu_cam = 2 if n == "char" else 1
	title.visible = n == "main"
	tagline.visible = n == "main"
	card.visible = n == "main"
	if g.net != null:
		g.net.set_scanning(n == "multi")
	if n == "main":
		b_play.text = _t("resume") if resumed else _t("play")
		b_leave.visible = g.net_client
	elif n == "char":
		name_edit.text = String(g.prof["name"])
		_refresh_char()
	elif n == "set":
		_refresh_settings()
	elif n == "multi":
		last_sig = "x"
		g.net_autostart = true
		g.apply_gset()
		_refresh_multi()
	var s: Control = scr[n]
	var i := 0
	for ch in s.get_children():
		if ch is Control:
			var c := ch as Control
			var tx := c.position.x
			c.position.x = tx - 70.0
			c.modulate.a = 0.0
			var tw := create_tween().set_parallel(true)
			tw.tween_property(c, "position:x", tx, 0.35).set_delay(0.04 * float(i)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tw.tween_property(c, "modulate:a", 1.0, 0.3).set_delay(0.04 * float(i))
			i += 1


func refresh_profile() -> void:
	var nm := String(g.prof["name"])
	card_name.text = nm
	card_av.text = nm.substr(0, 1).to_upper()
	card_num.text = g.fmt_num(String(g.prof["number"]))


func open_again() -> void:
	resumed = true
	root.visible = true
	g.menu_active = true
	fade.color.a = 0.0
	bar_t.size.y = 70.0
	bar_b.size.y = 70.0
	bar_b.position.y = g._vp().y - 70.0
	title.modulate.a = 1.0
	tagline.modulate.a = 1.0
	card.modulate.a = 1.0
	refresh_profile()
	show_screen("main")


func _on_play() -> void:
	if resumed:
		start_game()
		return
	start_game()


func start_game() -> void:
	var tw := create_tween()
	tw.tween_property(fade, "color:a", 1.0, 0.35)
	tw.tween_callback(_begin)
	tw.tween_property(fade, "color:a", 0.0, 0.9)


func _begin() -> void:
	if g.net != null:
		g.net.set_scanning(false)
	resumed = true
	root.visible = false
	g.menu_active = false
	g.cam_ease = 1.6
	g.apply_gset()
	if int(g.gset["lan"]) == 1 and g.net != null and not g.net_client:
		g.net.pvp = int(g.gset["pvp"]) == 1
		g.net.start_host()


func _on_leave() -> void:
	if g.net != null:
		g.net.leave()
	b_leave.visible = false


func on_joined() -> void:
	status_lbl.text = _t("conn")
	await get_tree().create_timer(0.4).timeout
	start_game()


func on_lost(why: String) -> void:
	if status_lbl != null:
		status_lbl.text = why


# ---------------------------------------------------------------- character

func _refresh_char() -> void:
	var n: int = g.skin_paths().size()
	skin_lbl.text = "%d / %d" % [int(g.prof["skin"]) + 1, n]
	num_lbl.text = g.fmt_num(String(g.prof["number"]))


func _on_name(t: String) -> void:
	g.prof["name"] = t.strip_edges() if t.strip_edges() != "" else "Player"
	g.save_profile()
	refresh_profile()


func _on_name_done(_t_: String) -> void:
	name_edit.release_focus()


func _on_skin(d: int) -> void:
	g.cycle_skin(d)
	_refresh_char()


func _on_newnum() -> void:
	g.prof["number"] = g._gen_number()
	g.save_profile()
	_refresh_char()
	refresh_profile()


# ---------------------------------------------------------------- settings

func _val(id: String) -> int:
	match id:
		"shadows":
			return 1 if g.apps.shadows else 0
		"showfps":
			return 1 if g.apps.show_fps else 0
	return int(g.gset.get(id, 0))


func _refresh_settings() -> void:
	for id in segs.keys():
		var v := _val(String(id))
		var arr: Array = segs[id]
		for i in arr.size():
			var b := arr[i] as Button
			var on := i == v
			var bg := Color(0.14, 0.5, 1.0, 0.95) if on else Color(0.07, 0.09, 0.14, 0.8)
			b.add_theme_stylebox_override("normal", _sb(bg, Color(1, 1, 1, 0.5 if on else 0.16), 16, 2))
			b.add_theme_stylebox_override("hover", _sb(bg.lightened(0.1), Color(1, 1, 1, 0.4), 16, 2))
	(sliders["sens"] as HSlider).set_value_no_signal(float(g.gset["sens"]))
	(sliders["volume"] as HSlider).set_value_no_signal(float(g.apps.volume))


func _on_seg(id: String, i: int) -> void:
	match id:
		"shadows":
			g.apps.shadows = i == 1
			g.apps._apply_options()
			g.apps.dirty = true
		"showfps":
			g.apps.show_fps = i == 1
			g.apps.dirty = true
		_:
			g.gset[id] = i
	g.apply_gset()
	g.save_profile()
	_refresh_settings()


func _on_slider(v: float, id: String) -> void:
	if id == "volume":
		g.apps.volume = v
		g.apps._apply_options()
		g.apps.dirty = true
	else:
		g.gset[id] = v
		g.save_profile()


# ---------------------------------------------------------------- multiplayer

func _on_ip_submit(_t_: String) -> void:
	_on_ip_join()


func _on_ip_join() -> void:
	var ip := ip_edit.text.strip_edges()
	if ip == "":
		return
	ip_edit.release_focus()
	_join(ip)


func _join(ip: String) -> void:
	if g.net == null:
		return
	g.net.join(ip)
	status_lbl.text = _t("conn")


func _refresh_multi() -> void:
	if g.net == null:
		return
	ip_lbl.text = "%s: %s" % [_t("yourip"), g.net.ips_text()]
	host_lbl.text = _t("host") if g.net.is_host and g.net.active else _t("hostoff")
	var sig := ""
	for ip in g.net.found.keys():
		sig += "%s:%s:%s;" % [ip, g.net.found[ip]["name"], g.net.found[ip]["n"]]
	if sig == last_sig:
		return
	last_sig = sig
	for ch in list_box.get_children():
		ch.queue_free()
	if g.net.found.is_empty():
		var l := _lbl(_t("none"), 24, Color(1, 1, 1, 0.55))
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(500, 90)
		list_box.add_child(l)
		return
	for ip in g.net.found.keys():
		var f: Dictionary = g.net.found[ip]
		var b := _btn("%s   (%d/%d)     %s" % [String(f["name"]), int(f["n"]), int(f["max"]), _t("join")], Vector2(480, 84), false, 28)
		b.pressed.connect(_join.bind(String(ip)))
		list_box.add_child(b)


func _process(_d: float) -> void:
	if not root.visible or g.net == null:
		return
	if cur == "multi":
		_refresh_multi()
		if g.net.connecting or g.net.status != "":
			status_lbl.text = g.net.status
	if cur == "main":
		b_leave.visible = g.net_client
