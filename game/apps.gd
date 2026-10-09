extends Node
# apps.gd - phone apps, money, store (batch 2)

const SAVE_PATH := "user://phone.cfg"
const PHOTO_DIR := "user://photos/"
const VIDEO_DIR := "user://videos/"
const FONT_PATH := "res://game/font.ttf"
const CAR_DIR := "res://game/cars/"
const A_CAR_GLB := "res://game/car.glb"
const A_CAR_YAW := PI
const A_CAR_LEN := 5.4
const START_MONEY := 20000
const LANGS := ["en", "ar", "fr", "es", "tr"]
const LANG_NAMES := ["English", "Arabic", "French", "Spanish", "Turkish"]
const WALLS := [
	[Color(0.07, 0.1, 0.22), Color(0.3, 0.15, 0.55)],
	[Color(0.03, 0.2, 0.28), Color(0.1, 0.5, 0.65)],
	[Color(0.45, 0.12, 0.2), Color(0.95, 0.5, 0.25)],
	[Color(0.05, 0.05, 0.07), Color(0.25, 0.27, 0.32)],
	[Color(0.04, 0.2, 0.12), Color(0.2, 0.55, 0.3)],
]
const CARS := [
	{"id": "sport", "name": "SPORT GT", "price": 15000, "color": Color(0.9, 0.1, 0.1)},
	{"id": "muscle", "name": "MUSCLE V8", "price": 22000, "color": Color(0.08, 0.08, 0.1)},
	{"id": "suv", "name": "SUV 4X4", "price": 18000, "color": Color(0.92, 0.92, 0.95)},
	{"id": "classic", "name": "CLASSIC", "price": 9000, "color": Color(0.1, 0.3, 0.8)},
	{"id": "taxi", "name": "TAXI", "price": 6000, "color": Color(0.95, 0.8, 0.1)},
]
const AMMO := [
	{"w": 1, "name": "PISTOL AMMO", "price": 120, "n": 24},
	{"w": 2, "name": "SMG AMMO", "price": 350, "n": 90},
	{"w": 3, "name": "SHOTGUN SHELLS", "price": 300, "n": 12},
	{"w": 4, "name": "RIFLE AMMO", "price": 450, "n": 60},
]
const SOON_APPS := ["Chirp (social)", "Snapgram (social)", "Mini Racer (game)", "Sky Jump (game)", "Tower Chess (game)"]

const TXT := {
	"en": {"camera": "Camera", "photos": "Photos", "clock": "Clock", "store": "Store", "settings": "Settings", "photo": "PHOTO", "video": "VIDEO", "slow": "SLOW", "normal": "NORMAL", "fast": "FAST", "save": "SAVE", "delete": "DELETE", "wallpaper": "Wallpaper", "language": "Language", "buy": "BUY", "owned": "OWNED", "select": "SELECT", "selected": "SELECTED", "cars": "CARS", "ammo": "AMMO", "air": "AIR", "apps": "APPS", "alarm": "Alarm", "stopwatch": "Stopwatch", "timer": "Timer", "clk": "Clock", "start": "START", "stop": "STOP", "lap": "LAP", "reset": "RESET", "add": "+ ALARM", "ring": "ALARM!", "edit": "EDIT", "bright": "Brightness", "contrast": "Contrast", "satur": "Saturation", "bw": "B&W", "sepia": "Sepia", "warm": "Warm", "cool": "Cool", "vivid": "Vivid", "rotate": "ROTATE", "flip": "FLIP", "size": "SIZE", "undo": "UNDO", "saved": "Saved", "empty": "Nothing here yet", "nomoney": "Not enough money", "bought": "Purchased", "setwp": "WALLPAPER", "soon": "SOON", "shadows": "Shadows", "fps": "Show FPS", "volume": "Volume", "on": "ON", "off": "OFF", "gallery": "Gallery", "pickwp": "Pick a wallpaper", "flysoon": "Flying: next update", "dismiss": "DISMISS", "back": "Back", "photocam": "BACK CAM", "selfie": "FRONT CAM"},
	"ar": {"camera": "الكاميرا", "photos": "الصور", "clock": "الساعة", "store": "المتجر", "settings": "الإعدادات", "photo": "صورة", "video": "فيديو", "slow": "بطيء", "normal": "عادي", "fast": "سريع", "save": "حفظ", "delete": "حذف", "wallpaper": "الخلفية", "language": "اللغة", "buy": "شراء", "owned": "مملوك", "select": "اختيار", "selected": "مختار", "cars": "سيارات", "ammo": "ذخيرة", "air": "جوي", "apps": "تطبيقات", "alarm": "منبه", "stopwatch": "ايقاف", "timer": "مؤقت", "clk": "ساعة", "start": "ابدأ", "stop": "ايقاف", "lap": "دورة", "reset": "تصفير", "add": "+ منبه", "ring": "المنبه!", "edit": "تعديل", "bright": "السطوع", "contrast": "التباين", "satur": "التشبع", "bw": "أبيض وأسود", "sepia": "بني", "warm": "دافئ", "cool": "بارد", "vivid": "زاهي", "rotate": "تدوير", "flip": "قلب", "size": "الحجم", "undo": "تراجع", "saved": "تم الحفظ", "empty": "لا يوجد شيء بعد", "nomoney": "رصيد غير كاف", "bought": "تم الشراء", "setwp": "خلفية", "soon": "قريبا", "shadows": "الظلال", "fps": "عرض الإطارات", "volume": "الصوت", "on": "تشغيل", "off": "ايقاف", "gallery": "المعرض", "pickwp": "اختر خلفية", "flysoon": "الطيران: التحديث القادم", "dismiss": "ايقاف", "back": "رجوع", "photocam": "خلفية", "selfie": "أمامية"},
	"fr": {"camera": "Appareil photo", "photos": "Photos", "clock": "Horloge", "store": "Boutique", "settings": "Réglages", "photo": "PHOTO", "video": "VIDÉO", "slow": "LENT", "normal": "NORMAL", "fast": "RAPIDE", "save": "ENREGISTRER", "delete": "SUPPRIMER", "wallpaper": "Fond d'écran", "language": "Langue", "buy": "ACHETER", "owned": "POSSÉDÉ", "select": "CHOISIR", "selected": "CHOISI", "cars": "VOITURES", "ammo": "MUNITIONS", "air": "AIR", "apps": "APPS", "alarm": "Alarme", "stopwatch": "Chrono", "timer": "Minuteur", "clk": "Horloge", "start": "DÉMARRER", "stop": "STOP", "lap": "TOUR", "reset": "RAZ", "add": "+ ALARME", "ring": "ALARME !", "edit": "MODIFIER", "bright": "Luminosité", "contrast": "Contraste", "satur": "Saturation", "bw": "N&B", "sepia": "Sépia", "warm": "Chaud", "cool": "Froid", "vivid": "Vif", "rotate": "PIVOTER", "flip": "MIROIR", "size": "TAILLE", "undo": "ANNULER", "saved": "Enregistré", "empty": "Rien ici", "nomoney": "Fonds insuffisants", "bought": "Acheté", "setwp": "FOND", "soon": "BIENTÔT", "shadows": "Ombres", "fps": "Afficher FPS", "volume": "Volume", "on": "OUI", "off": "NON", "gallery": "Galerie", "pickwp": "Choisir un fond", "flysoon": "Vol : prochaine mise à jour", "dismiss": "ARRÊTER", "back": "Retour", "photocam": "ARRIÈRE", "selfie": "AVANT"},
	"es": {"camera": "Cámara", "photos": "Fotos", "clock": "Reloj", "store": "Tienda", "settings": "Ajustes", "photo": "FOTO", "video": "VÍDEO", "slow": "LENTO", "normal": "NORMAL", "fast": "RÁPIDO", "save": "GUARDAR", "delete": "BORRAR", "wallpaper": "Fondo", "language": "Idioma", "buy": "COMPRAR", "owned": "TUYO", "selected": "ELEGIDO", "select": "ELEGIR", "cars": "COCHES", "ammo": "MUNICIÓN", "air": "AIRE", "apps": "APPS", "alarm": "Alarma", "stopwatch": "Cronómetro", "timer": "Temporizador", "clk": "Reloj", "start": "INICIAR", "stop": "PARAR", "lap": "VUELTA", "reset": "REINICIAR", "add": "+ ALARMA", "ring": "¡ALARMA!", "edit": "EDITAR", "bright": "Brillo", "contrast": "Contraste", "satur": "Saturación", "bw": "B/N", "sepia": "Sepia", "warm": "Cálido", "cool": "Frío", "vivid": "Vívido", "rotate": "GIRAR", "flip": "VOLTEAR", "size": "TAMAÑO", "undo": "DESHACER", "saved": "Guardado", "empty": "Nada aún", "nomoney": "Dinero insuficiente", "bought": "Comprado", "setwp": "FONDO", "soon": "PRONTO", "shadows": "Sombras", "fps": "Mostrar FPS", "volume": "Volumen", "on": "SÍ", "off": "NO", "gallery": "Galería", "pickwp": "Elige un fondo", "flysoon": "Vuelo: próxima actualización", "dismiss": "DETENER", "back": "Atrás", "photocam": "TRASERA", "selfie": "FRONTAL"},
	"tr": {"camera": "Kamera", "photos": "Fotoğraflar", "clock": "Saat", "store": "Mağaza", "settings": "Ayarlar", "photo": "FOTO", "video": "VİDEO", "slow": "YAVAŞ", "normal": "NORMAL", "fast": "HIZLI", "save": "KAYDET", "delete": "SİL", "wallpaper": "Duvar kâğıdı", "language": "Dil", "buy": "SATIN AL", "owned": "SAHİP", "select": "SEÇ", "selected": "SEÇİLİ", "cars": "ARABALAR", "ammo": "MERMİ", "air": "HAVA", "apps": "UYGULAMA", "alarm": "Alarm", "stopwatch": "Kronometre", "timer": "Zamanlayıcı", "clk": "Saat", "start": "BAŞLAT", "stop": "DURDUR", "lap": "TUR", "reset": "SIFIRLA", "add": "+ ALARM", "ring": "ALARM!", "edit": "DÜZENLE", "bright": "Parlaklık", "contrast": "Kontrast", "satur": "Doygunluk", "bw": "S/B", "sepia": "Sepya", "warm": "Sıcak", "cool": "Soğuk", "vivid": "Canlı", "rotate": "DÖNDÜR", "flip": "ÇEVİR", "size": "BOYUT", "undo": "GERİ AL", "saved": "Kaydedildi", "empty": "Henüz yok", "nomoney": "Yetersiz bakiye", "bought": "Satın alındı", "setwp": "DUVAR", "soon": "YAKINDA", "shadows": "Gölgeler", "fps": "FPS göster", "volume": "Ses", "on": "AÇIK", "off": "KAPALI", "gallery": "Galeri", "pickwp": "Duvar kâğıdı seç", "flysoon": "Uçuş: sonraki güncelleme", "dismiss": "KAPAT", "back": "Geri", "photocam": "ARKA", "selfie": "ÖN"},
}

var g
var app := -1
var page := ""
var hits: Array = []
var sbs: Array = []
var font: Font
var sys_font: SystemFont
var custom_font := false
var lang := "en"
var money := START_MONEY
var gain_t := 0.0
var gain_txt := ""
var wall_idx := 0
var wall_path := ""
var wall_tex: ImageTexture
var owned := {"starter": true}
var car_sel := "starter"
var alarms: Array = []
var alarm_edit := -1
var last_alarm_key := ""
var ringing := 0.0
var ring_msg := ""
var ring_player: AudioStreamPlayer
var sw_run := false
var sw_start := 0
var sw_acc := 0
var laps: Array = []
var tm_set := 300
var tm_left := 0.0
var tm_run := false
var clock_tab := 0
var store_tab := 0
var store_page := 0
var volume := 1.0
var shadows := true
var show_fps := false
var sun: DirectionalLight3D
var save_t := 0.0
var dirty := false

var sv: SubViewport
var pcam: Camera3D
var cam_mode := 0
var cam_speed := 1
var cam_front := false
var cam_zoom := 1.0
var recording := false
var rec_frames := 0
var rec_acc := 0.0
var rec_dir := ""
var flash_t := 0.0
var shutter_player: AudioStreamPlayer
var last_thumb: ImageTexture

var gal: Array = []
var gal_page := 0
var thumbs := {}
var view_i := -1
var view_tex: ImageTexture
var clip_n := 0
var clip_fps := 6.0
var clip_i := 0
var clip_t := 0.0
var clip_play := true
var clip_speed := 1.0
var pick_mode := false

var ed_orig: Image
var ed_base: Image
var ed_tex: ImageTexture
var ed_b := 0.0
var ed_c := 0.0
var ed_s := 0.0
var ed_scale := 1.0


func _ready() -> void:
	_setup_font()
	_make_styles()
	_load()
	ring_player = AudioStreamPlayer.new()
	ring_player.stream = _beep_stream()
	add_child(ring_player)
	shutter_player = AudioStreamPlayer.new()
	shutter_player.stream = g._synth_click(1)
	add_child(shutter_player)
	sv = SubViewport.new()
	sv.size = Vector2i(960, 540)
	sv.render_target_update_mode = SubViewport.UPDATE_DISABLED
	sv.msaa_3d = Viewport.MSAA_DISABLED
	add_child(sv)
	pcam = Camera3D.new()
	pcam.far = 500.0
	sv.add_child(pcam)
	pcam.current = true
	for n in g.get_children():
		if n is DirectionalLight3D:
			sun = n
	if car_sel != "starter":
		_apply_car(car_sel)
	_apply_wall()
	_apply_options()
	_scan_gallery()
	if not gal.is_empty() and gal[0]["t"] == "p":
		last_thumb = _thumb(gal[0])


# ---------------------------------------------------------------- basics

func T(k: String) -> String:
	var d: Dictionary = TXT.get(lang, TXT["en"])
	var en: Dictionary = TXT["en"]
	return String(d.get(k, en.get(k, k)))


func _setup_font() -> void:
	if ResourceLoader.exists(FONT_PATH):
		font = load(FONT_PATH) as Font
		custom_font = font != null
	if font == null:
		font = ThemeDB.fallback_font
	sys_font = SystemFont.new()
	sys_font.font_names = PackedStringArray(["Geeza Pro", "Noto Sans Arabic", "Arial", "Helvetica"])
	var fb: Array[Font] = [ThemeDB.fallback_font]
	sys_font.fallbacks = fb


func _font() -> Font:
	if custom_font:
		return font
	if lang == "ar":
		return sys_font
	return ThemeDB.fallback_font


func _mk(bg: Color, border: Color, rad: int, bw: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(rad)
	s.border_color = border
	s.set_border_width_all(bw)
	return s


func _make_styles() -> void:
	sbs = [
		_mk(Color(1, 1, 1, 0.12), Color(1, 1, 1, 0.55), 14, 2),
		_mk(Color(0.25, 0.5, 0.95, 0.85), Color(1, 1, 1, 0.8), 14, 2),
		_mk(Color(0.2, 0.7, 0.4, 0.9), Color(1, 1, 1, 0.8), 14, 2),
		_mk(Color(0.85, 0.2, 0.2, 0.9), Color(1, 1, 1, 0.8), 14, 2),
		_mk(Color(0.03, 0.04, 0.08, 0.72), Color(1, 1, 1, 0.18), 18, 2),
		_mk(Color(0.3, 0.3, 0.34, 0.8), Color(1, 1, 1, 0.2), 14, 2),
	]


func _t(c: Control, s: String, p: Vector2, size: int, col: Color = Color.WHITE, al: int = 1) -> void:
	var f := _font()
	var y := p.y + size * 0.35
	if al == 1:
		c.draw_string(f, Vector2(p.x - 200.0, y), s, HORIZONTAL_ALIGNMENT_CENTER, 400, size, col)
	elif al == 0:
		c.draw_string(f, Vector2(p.x, y), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)
	else:
		c.draw_string(f, Vector2(p.x - 400.0, y), s, HORIZONTAL_ALIGNMENT_RIGHT, 400, size, col)


func _btn(c: Control, r: Rect2, label: String, act: String, val = null, kind: int = 0, size: int = 20) -> void:
	c.draw_style_box(sbs[kind], r)
	_t(c, label, r.position + r.size * 0.5, size)
	hits.append({"r": r, "a": act, "v": val})


func _plain(c: Control, r: Rect2, label: String, kind: int = 5, size: int = 20) -> void:
	c.draw_style_box(sbs[kind], r)
	_t(c, label, r.position + r.size * 0.5, size, Color(1, 1, 1, 0.75))


func _title(c: Control, key: String) -> void:
	_t(c, T(key), Vector2(220, 128), 30)
	c.draw_line(Vector2(40, 158), Vector2(400, 158), Color(1, 1, 1, 0.25), 2.0)


func _fmt(n: int) -> String:
	var s := str(absi(n))
	var out := ""
	var cnt := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		cnt += 1
		if cnt % 3 == 0 and i > 0:
			out = "," + out
	return ("-" if n < 0 else "") + "$" + out


func add_money(n: int) -> void:
	money = maxi(money + n, 0)
	if n > 0:
		gain_txt = "+" + _fmt(n)
		gain_t = 2.0
	dirty = true


func app_open() -> bool:
	return app != -1


func _beep_stream() -> AudioStreamWAV:
	var rate := 22050
	var n := rate
	var s := PackedFloat32Array()
	s.resize(n)
	for i in n:
		var t := float(i) / float(rate)
		var on := fmod(t, 0.5) < 0.18
		s[i] = (sin(TAU * 880.0 * t) * 0.35) if on else 0.0
	return g._wav(s, rate, true)


# ---------------------------------------------------------------- save / load

func _save() -> void:
	var cf := ConfigFile.new()
	cf.set_value("p", "money", money)
	cf.set_value("p", "lang", lang)
	cf.set_value("p", "wall_idx", wall_idx)
	cf.set_value("p", "wall_path", wall_path)
	cf.set_value("p", "owned", owned)
	cf.set_value("p", "car_sel", car_sel)
	cf.set_value("p", "alarms", alarms)
	cf.set_value("p", "volume", volume)
	cf.set_value("p", "shadows", shadows)
	cf.set_value("p", "fps", show_fps)
	cf.save(SAVE_PATH)
	dirty = false


func _load() -> void:
	var cf := ConfigFile.new()
	if cf.load(SAVE_PATH) != OK:
		return
	money = int(cf.get_value("p", "money", START_MONEY))
	lang = String(cf.get_value("p", "lang", "en"))
	wall_idx = int(cf.get_value("p", "wall_idx", 0))
	wall_path = String(cf.get_value("p", "wall_path", ""))
	owned = cf.get_value("p", "owned", {"starter": true})
	car_sel = String(cf.get_value("p", "car_sel", "starter"))
	alarms = cf.get_value("p", "alarms", [])
	volume = float(cf.get_value("p", "volume", 1.0))
	shadows = bool(cf.get_value("p", "shadows", true))
	show_fps = bool(cf.get_value("p", "fps", false))


func _apply_options() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(volume, 0.001)))
	if sun != null:
		sun.shadow_enabled = shadows


func _apply_wall() -> void:
	wall_tex = null
	if wall_idx < 0 and wall_path != "" and FileAccess.file_exists(wall_path):
		var im := Image.load_from_file(wall_path)
		if im != null and not im.is_empty():
			wall_tex = ImageTexture.create_from_image(im)


func _apply_car(id: String) -> void:
	var vis: Node3D = g.car_visual
	for ch in vis.get_children():
		ch.queue_free()
	g.car_wheels.clear()
	vis.scale = Vector3.ONE
	var path := A_CAR_GLB
	var col := Color(0.8, 0.08, 0.08)
	if id != "starter":
		path = CAR_DIR + id + ".glb"
		for c in CARS:
			if c["id"] == id:
				col = c["color"]
	var holder = g._fit_glb(path, A_CAR_YAW, A_CAR_LEN, false, true)
	if holder != null:
		vis.add_child(holder)
	else:
		g._build_car_procedural(vis, col, false, g.car_wheels)


# ---------------------------------------------------------------- per-frame logic

func _process(delta: float) -> void:
	if app != -1 and not g.phone_open:
		close_app()
	if gain_t > 0.0:
		gain_t -= delta
	save_t += delta
	if dirty and save_t > 12.0:
		save_t = 0.0
		_save()
	_check_alarms()
	if tm_run:
		tm_left -= delta
		if tm_left <= 0.0:
			tm_left = 0.0
			tm_run = false
			_ring("TIMER")
	if ringing > 0.0:
		ringing -= delta
		if ringing <= 0.0:
			_stop_ring()
	if app == 4:
		_update_cam_rig()
		if flash_t > 0.0:
			flash_t = maxf(flash_t - delta * 3.0, 0.0)
		if recording:
			rec_acc += delta
			var step := 1.0 / _cap_fps()
			while rec_acc >= step:
				rec_acc -= step
				_save_frame()
	if page == "view" and view_i >= 0 and view_i < gal.size() and gal[view_i]["t"] == "c" and clip_play:
		clip_t += delta * clip_speed
		var step2 := 1.0 / clip_fps
		while clip_t >= step2:
			clip_t -= step2
			clip_i = (clip_i + 1) % maxi(clip_n, 1)
			_load_clip_frame()


func _check_alarms() -> void:
	var t := Time.get_time_dict_from_system()
	var key := "%d:%d" % [t["hour"], t["minute"]]
	if key == last_alarm_key:
		return
	for a in alarms:
		if bool(a["on"]) and int(a["h"]) == int(t["hour"]) and int(a["m"]) == int(t["minute"]):
			last_alarm_key = key
			_ring("%s %02d:%02d" % [T("ring"), a["h"], a["m"]])
			return


func _ring(msg: String) -> void:
	ringing = 15.0
	ring_msg = msg
	ring_player.play()
	g._toast(msg, 4.0)


func _stop_ring() -> void:
	ringing = 0.0
	ring_player.stop()


func open_app(i: int) -> void:
	app = i
	page = ""
	pick_mode = false
	if i == 4:
		sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_update_cam_rig()
	elif i == 5:
		_scan_gallery()
		gal_page = 0
	elif i == 6:
		clock_tab = 0
	elif i == 7:
		store_tab = 0
		store_page = 0


func close_app() -> void:
	if recording:
		_stop_rec()
	sv.render_target_update_mode = SubViewport.UPDATE_DISABLED
	app = -1
	page = ""
	pick_mode = false
	if dirty:
		_save()


func _back() -> void:
	if ringing > 0.0:
		_stop_ring()
		return
	if page == "edit":
		page = "view"
	elif page != "":
		page = ""
		if pick_mode and app == 5:
			pick_mode = false
	elif pick_mode:
		pick_mode = false
		app = 8
	else:
		close_app()


# ---------------------------------------------------------------- touch / actions

func touch(lp: Vector2) -> void:
	if lp.distance_to(Vector2(220, 845)) < 42.0:
		_back()
		return
	for i in range(hits.size() - 1, -1, -1):
		var h: Dictionary = hits[i]
		if (h["r"] as Rect2).has_point(lp):
			_act(String(h["a"]), h["v"])
			return


func _act(a: String, v) -> void:
	match a:
		"cam_mode":
			if recording:
				_stop_rec()
			cam_mode = int(v)
		"cam_speed":
			cam_speed = int(v)
		"cam_flip":
			cam_front = not cam_front
		"cam_zoom":
			cam_zoom = clampf(cam_zoom + float(v), 1.0, 4.0)
		"shutter":
			_shutter()
		"to_gallery":
			open_app(5)
		"gal_prev":
			gal_page = maxi(gal_page - 1, 0)
		"gal_next":
			gal_page += 1
		"view":
			_open_view(int(v))
		"v_prev":
			_open_view((view_i - 1 + gal.size()) % gal.size())
		"v_next":
			_open_view((view_i + 1) % gal.size())
		"v_edit":
			_open_edit()
		"v_wall":
			_wall_from(String(gal[view_i]["path"]))
		"v_del":
			_delete_item(view_i)
		"clip_play":
			clip_play = not clip_play
		"clip_speed":
			clip_speed = float(v)
		"ed_adj":
			_ed_adjust(String(v))
		"ed_filter":
			_ed_filter(String(v))
		"ed_rot":
			ed_base.rotate_90(CLOCKWISE)
			_ed_preview()
		"ed_flip":
			ed_base.flip_x()
			_ed_preview()
		"ed_size":
			ed_scale = 0.75 if ed_scale >= 1.0 else (0.5 if ed_scale >= 0.75 else 1.0)
		"ed_undo":
			ed_base = ed_orig.duplicate() as Image
			ed_b = 0.0
			ed_c = 0.0
			ed_s = 0.0
			ed_scale = 1.0
			_ed_preview()
		"ed_save":
			_ed_save()
		"clock_tab":
			clock_tab = int(v)
			alarm_edit = -1
		"alarm_add":
			alarms.append({"h": 7, "m": 0, "on": true})
			alarm_edit = alarms.size() - 1
			dirty = true
		"alarm_open":
			alarm_edit = int(v)
		"alarm_done":
			alarm_edit = -1
		"alarm_toggle":
			alarms[int(v)]["on"] = not bool(alarms[int(v)]["on"])
			dirty = true
		"alarm_del":
			alarms.remove_at(int(v))
			alarm_edit = -1
			dirty = true
		"alarm_h":
			alarms[alarm_edit]["h"] = posmod(int(alarms[alarm_edit]["h"]) + int(v), 24)
			dirty = true
		"alarm_m":
			alarms[alarm_edit]["m"] = posmod(int(alarms[alarm_edit]["m"]) + int(v), 60)
			dirty = true
		"sw_toggle":
			if sw_run:
				sw_acc += Time.get_ticks_msec() - sw_start
				sw_run = false
			else:
				sw_start = Time.get_ticks_msec()
				sw_run = true
		"sw_lap":
			if sw_run:
				laps.push_front(_sw_ms())
				if laps.size() > 6:
					laps.pop_back()
		"sw_reset":
			sw_run = false
			sw_acc = 0
			laps.clear()
		"tm_add":
			if not tm_run:
				tm_set = clampi(tm_set + int(v), 10, 5999)
				tm_left = 0.0
		"tm_toggle":
			if tm_run:
				tm_run = false
			else:
				if tm_left <= 0.0:
					tm_left = float(tm_set)
				tm_run = true
		"tm_reset":
			tm_run = false
			tm_left = 0.0
		"store_tab":
			store_tab = int(v)
			store_page = 0
		"store_prev":
			store_page = maxi(store_page - 1, 0)
		"store_next":
			store_page += 1
		"buy_car":
			_buy(String(v), _car_price(String(v)))
		"sel_car":
			car_sel = String(v)
			_apply_car(car_sel)
			dirty = true
		"buy_ammo":
			var it: Dictionary = AMMO[int(v)]
			if _pay(int(it["price"])):
				g.ammo_res[int(it["w"])] += int(it["n"])
		"buy_heli":
			_buy("heli", 90000)
		"set_lang":
			lang = String(v)
			dirty = true
		"set_wall":
			wall_idx = int(v)
			wall_path = ""
			_apply_wall()
			dirty = true
		"wall_photo":
			pick_mode = true
			app = 5
			page = ""
			_scan_gallery()
			gal_page = 0
		"toggle_shadows":
			shadows = not shadows
			_apply_options()
			dirty = true
		"toggle_fps":
			show_fps = not show_fps
			dirty = true
		"vol":
			volume = clampf(volume + float(v), 0.0, 1.0)
			_apply_options()
			dirty = true
		"dismiss":
			_stop_ring()


func _pay(price: int) -> bool:
	if money < price:
		g._toast(T("nomoney"), 2.0)
		return false
	money -= price
	dirty = true
	g._toast(T("bought"), 1.8)
	return true


func _buy(id: String, price: int) -> void:
	if _pay(price):
		owned[id] = true
		dirty = true


func _car_price(id: String) -> int:
	for c in CARS:
		if c["id"] == id:
			return int(c["price"])
	return 0


# ---------------------------------------------------------------- camera app

func _cap_fps() -> float:
	return [12.0, 6.0, 3.0][cam_speed]


func _update_cam_rig() -> void:
	var base: Vector3 = g.car.position if g.in_car else g.player.position
	var head := base + Vector3(0, 1.65, 0)
	if cam_front:
		var yaw: float = g.car.rotation.y if g.in_car else g.model.rotation.y
		var fwd := Vector3(-sin(yaw), 0, -cos(yaw))
		pcam.global_position = head + fwd * 2.4 + Vector3(0, 0.1, 0)
		pcam.look_at(head + Vector3(0, -0.1, 0))
	else:
		var gt: Transform3D = g.cam.global_transform
		pcam.global_transform = gt
		pcam.global_position = gt.origin - gt.basis.z * 1.2
	pcam.fov = 75.0 / cam_zoom


func _shutter() -> void:
	if cam_mode == 0:
		var img := sv.get_texture().get_image()
		if img == null or img.is_empty():
			return
		img.convert(Image.FORMAT_RGB8)
		DirAccess.make_dir_recursive_absolute(PHOTO_DIR)
		var path := PHOTO_DIR + "p_%d.jpg" % int(Time.get_unix_time_from_system() * 1000.0)
		img.save_jpg(path, 0.9)
		var th := img.duplicate() as Image
		th.resize(124, 70)
		last_thumb = ImageTexture.create_from_image(th)
		flash_t = 1.0
		shutter_player.play()
		g._toast(T("saved"), 1.5)
	else:
		if recording:
			_stop_rec()
		else:
			DirAccess.make_dir_recursive_absolute(VIDEO_DIR)
			rec_dir = VIDEO_DIR + "c_%d" % int(Time.get_unix_time_from_system() * 1000.0)
			DirAccess.make_dir_recursive_absolute(rec_dir)
			rec_frames = 0
			rec_acc = 0.0
			recording = true
			shutter_player.play()


func _save_frame() -> void:
	if rec_frames >= 300:
		_stop_rec()
		return
	var img := sv.get_texture().get_image()
	if img == null or img.is_empty():
		return
	img.convert(Image.FORMAT_RGB8)
	img.resize(384, 216, Image.INTERPOLATE_BILINEAR)
	img.save_jpg(rec_dir + "/%04d.jpg" % rec_frames, 0.8)
	rec_frames += 1


func _stop_rec() -> void:
	recording = false
	if rec_frames <= 0:
		return
	var cf := ConfigFile.new()
	cf.set_value("c", "frames", rec_frames)
	cf.set_value("c", "fps", 6.0)
	cf.save(rec_dir + "/clip.cfg")
	g._toast(T("saved"), 1.5)


func _draw_camera(c: Control) -> void:
	_title(c, "camera")
	var vr := Rect2(34, 168, 372, 209)
	c.draw_rect(vr, Color.BLACK)
	c.draw_texture_rect(sv.get_texture(), vr, false)
	for k in [1, 2]:
		var fx: float = float(k) / 3.0
		c.draw_line(vr.position + Vector2(vr.size.x * fx, 0), vr.position + Vector2(vr.size.x * fx, vr.size.y), Color(1, 1, 1, 0.22), 1.0)
		c.draw_line(vr.position + Vector2(0, vr.size.y * fx), vr.position + Vector2(vr.size.x, vr.size.y * fx), Color(1, 1, 1, 0.22), 1.0)
	if recording:
		c.draw_circle(vr.position + Vector2(24, 24), 8.0, Color(1, 0.15, 0.15))
		var secs := float(rec_frames) / _cap_fps()
		_t(c, "%02d:%02d" % [int(secs) / 60, int(secs) % 60], vr.position + Vector2(48, 24), 18, Color.WHITE, 0)
	if flash_t > 0.0:
		c.draw_rect(vr, Color(1, 1, 1, flash_t))
	_t(c, "%.1fx" % cam_zoom, vr.position + Vector2(vr.size.x - 34, 22), 18, Color(1, 1, 1, 0.9))
	_btn(c, Rect2(70, 395, 140, 40), T("photo"), "cam_mode", 0, 1 if cam_mode == 0 else 0)
	_btn(c, Rect2(230, 395, 140, 40), T("video"), "cam_mode", 1, 1 if cam_mode == 1 else 0)
	if cam_mode == 1:
		var keys := ["slow", "normal", "fast"]
		for i in 3:
			_btn(c, Rect2(40 + i * 128, 448, 120, 38), T(String(keys[i])), "cam_speed", i, 2 if cam_speed == i else 0, 18)
	_btn(c, Rect2(34, 515, 130, 44), T("selfie") if cam_front else T("photocam"), "cam_flip", null, 0, 17)
	_btn(c, Rect2(232, 515, 54, 44), "-", "cam_zoom", -0.5, 0, 26)
	_btn(c, Rect2(296, 515, 54, 44), "+", "cam_zoom", 0.5, 0, 26)
	var sc := Vector2(220, 680)
	c.draw_circle(sc, 58.0, Color(1, 1, 1, 0.14))
	c.draw_arc(sc, 58.0, 0.0, TAU, 40, Color(1, 1, 1, 0.95), 4.0, true)
	var inner := Color(1, 1, 1, 0.95)
	var rad := 44.0
	if cam_mode == 1:
		inner = Color(0.95, 0.15, 0.15)
		if recording:
			rad = 26.0
	c.draw_circle(sc, rad, inner)
	hits.append({"r": Rect2(sc - Vector2(62, 62), Vector2(124, 124)), "a": "shutter", "v": null})
	var tr := Rect2(40, 640, 88, 88)
	c.draw_rect(tr, Color(0, 0, 0, 0.4))
	if last_thumb != null:
		c.draw_texture_rect(last_thumb, tr, false)
	c.draw_rect(tr, Color(1, 1, 1, 0.8), false, 2.0)
	hits.append({"r": tr, "a": "to_gallery", "v": null})


# ---------------------------------------------------------------- photos app

func _scan_gallery() -> void:
	gal.clear()
	DirAccess.make_dir_recursive_absolute(PHOTO_DIR)
	DirAccess.make_dir_recursive_absolute(VIDEO_DIR)
	for f in DirAccess.get_files_at(PHOTO_DIR):
		var fn := String(f)
		if fn.ends_with(".jpg"):
			gal.append({"t": "p", "path": PHOTO_DIR + fn, "n": int(fn.get_basename().trim_prefix("p_"))})
	for d in DirAccess.get_directories_at(VIDEO_DIR):
		var dn := String(d)
		gal.append({"t": "c", "path": VIDEO_DIR + dn, "n": int(dn.trim_prefix("c_"))})
	gal.sort_custom(func(a, b): return int(a["n"]) > int(b["n"]))


func _thumb(item: Dictionary) -> ImageTexture:
	var key := String(item["path"])
	if thumbs.has(key):
		return thumbs[key]
	var p := key if item["t"] == "p" else key + "/0000.jpg"
	var im := Image.load_from_file(p)
	if im == null or im.is_empty():
		return null
	im.resize(124, 70)
	var tex := ImageTexture.create_from_image(im)
	thumbs[key] = tex
	return tex


func _open_view(i: int) -> void:
	if i < 0 or i >= gal.size():
		return
	if pick_mode:
		_wall_from(String(gal[i]["path"]))
		return
	view_i = i
	page = "view"
	var item: Dictionary = gal[i]
	view_tex = null
	clip_i = 0
	clip_t = 0.0
	clip_play = true
	clip_speed = 1.0
	if item["t"] == "p":
		var im := Image.load_from_file(String(item["path"]))
		if im != null and not im.is_empty():
			view_tex = ImageTexture.create_from_image(im)
	else:
		var cf := ConfigFile.new()
		clip_n = 0
		if cf.load(String(item["path"]) + "/clip.cfg") == OK:
			clip_n = int(cf.get_value("c", "frames", 0))
			clip_fps = float(cf.get_value("c", "fps", 6.0))
		_load_clip_frame()


func _load_clip_frame() -> void:
	var path := String(gal[view_i]["path"]) + "/%04d.jpg" % clip_i
	var im := Image.load_from_file(path)
	if im != null and not im.is_empty():
		view_tex = ImageTexture.create_from_image(im)


func _delete_item(i: int) -> void:
	if i < 0 or i >= gal.size():
		return
	var item: Dictionary = gal[i]
	var path := String(item["path"])
	if item["t"] == "p":
		DirAccess.remove_absolute(path)
	else:
		var d := DirAccess.open(path)
		if d != null:
			for f in d.get_files():
				d.remove(f)
		DirAccess.remove_absolute(path)
	thumbs.erase(path)
	last_thumb = null
	_scan_gallery()
	view_i = -1
	page = ""
	gal_page = clampi(gal_page, 0, maxi((gal.size() - 1) / 18, 0))
	if not gal.is_empty() and gal[0]["t"] == "p":
		last_thumb = _thumb(gal[0])


func _wall_from(path: String) -> void:
	wall_idx = -1
	wall_path = path
	_apply_wall()
	dirty = true
	pick_mode = false
	page = ""
	app = 8
	g._toast(T("saved"), 1.5)


func _draw_photos(c: Control) -> void:
	_title(c, "pickwp" if pick_mode else "photos")
	if page == "edit":
		_draw_edit(c)
		return
	if page == "view":
		_draw_view(c)
		return
	if gal.is_empty():
		_t(c, T("empty"), Vector2(220, 420), 24, Color(1, 1, 1, 0.7))
		return
	var per := 18
	var pages := maxi((gal.size() - 1) / per + 1, 1)
	gal_page = clampi(gal_page, 0, pages - 1)
	for k in per:
		var idx := gal_page * per + k
		if idx >= gal.size():
			break
		var r := Rect2(36 + (k % 3) * 124, 176 + (k / 3) * 78, 120, 68)
		c.draw_rect(r, Color(0, 0, 0, 0.45))
		var tex := _thumb(gal[idx])
		if tex != null:
			c.draw_texture_rect(tex, r, false)
		if gal[idx]["t"] == "c":
			c.draw_circle(r.position + r.size * 0.5, 16.0, Color(0, 0, 0, 0.6))
			c.draw_colored_polygon(PackedVector2Array([r.position + r.size * 0.5 + Vector2(-5, -9), r.position + r.size * 0.5 + Vector2(-5, 9), r.position + r.size * 0.5 + Vector2(10, 0)]), Color.WHITE)
		c.draw_rect(r, Color(1, 1, 1, 0.5), false, 1.5)
		hits.append({"r": r, "a": "view", "v": idx})
	if pages > 1:
		_btn(c, Rect2(60, 740, 100, 44), "<", "gal_prev", null, 0, 24)
		_t(c, "%d / %d" % [gal_page + 1, pages], Vector2(220, 762), 20)
		_btn(c, Rect2(280, 740, 100, 44), ">", "gal_next", null, 0, 24)


func _draw_view(c: Control) -> void:
	var r := Rect2(34, 170, 372, 209)
	c.draw_rect(r, Color.BLACK)
	if view_tex != null:
		c.draw_texture_rect(view_tex, r, false)
	var is_clip: bool = view_i >= 0 and view_i < gal.size() and gal[view_i]["t"] == "c"
	if is_clip:
		_btn(c, Rect2(40, 400, 90, 40), "||" if clip_play else ">", "clip_play", null, 0, 22)
		var sp := [0.5, 1.0, 2.0]
		for i in 3:
			_btn(c, Rect2(140 + i * 86, 400, 80, 40), "%sx" % str(sp[i]), "clip_speed", sp[i], 1 if is_equal_approx(clip_speed, sp[i]) else 0, 18)
	else:
		_btn(c, Rect2(40, 400, 110, 44), T("edit"), "v_edit", null, 1, 18)
		_btn(c, Rect2(160, 400, 120, 44), T("setwp"), "v_wall", null, 0, 16)
	_btn(c, Rect2(290, 400 if not is_clip else 460, 100, 44), T("delete"), "v_del", null, 3, 16)
	_btn(c, Rect2(60, 540, 100, 50), "<", "v_prev", null, 0, 26)
	_btn(c, Rect2(280, 540, 100, 50), ">", "v_next", null, 0, 26)


func _open_edit() -> void:
	if view_i < 0 or gal[view_i]["t"] != "p":
		return
	var im := Image.load_from_file(String(gal[view_i]["path"]))
	if im == null or im.is_empty():
		return
	im.convert(Image.FORMAT_RGBA8)
	ed_orig = im
	ed_base = im.duplicate() as Image
	ed_b = 0.0
	ed_c = 0.0
	ed_s = 0.0
	ed_scale = 1.0
	page = "edit"
	_ed_preview()


func _ed_preview() -> void:
	var im := ed_base.duplicate() as Image
	im.adjust_bcs(1.0 + ed_b, 1.0 + ed_c, 1.0 + ed_s)
	ed_tex = ImageTexture.create_from_image(im)


func _ed_adjust(k: String) -> void:
	match k:
		"b+": ed_b = clampf(ed_b + 0.1, -0.6, 0.6)
		"b-": ed_b = clampf(ed_b - 0.1, -0.6, 0.6)
		"c+": ed_c = clampf(ed_c + 0.1, -0.6, 0.8)
		"c-": ed_c = clampf(ed_c - 0.1, -0.6, 0.8)
		"s+": ed_s = clampf(ed_s + 0.2, -1.0, 1.0)
		"s-": ed_s = clampf(ed_s - 0.2, -1.0, 1.0)
	_ed_preview()


func _tint(col: Color) -> void:
	var ov := Image.create(ed_base.get_width(), ed_base.get_height(), false, Image.FORMAT_RGBA8)
	ov.fill(col)
	ed_base.blend_rect(ov, Rect2i(0, 0, ov.get_width(), ov.get_height()), Vector2i.ZERO)


func _ed_filter(k: String) -> void:
	match k:
		"bw":
			ed_base.adjust_bcs(1.0, 1.05, 0.0)
		"sepia":
			ed_base.adjust_bcs(1.0, 1.0, 0.0)
			_tint(Color(0.75, 0.5, 0.25, 0.38))
		"warm":
			_tint(Color(1.0, 0.55, 0.15, 0.18))
		"cool":
			_tint(Color(0.2, 0.5, 1.0, 0.18))
		"vivid":
			ed_base.adjust_bcs(1.05, 1.15, 1.6)
	_ed_preview()


func _ed_save() -> void:
	var im := ed_base.duplicate() as Image
	im.adjust_bcs(1.0 + ed_b, 1.0 + ed_c, 1.0 + ed_s)
	if ed_scale < 1.0:
		im.resize(int(im.get_width() * ed_scale), int(im.get_height() * ed_scale), Image.INTERPOLATE_BILINEAR)
	im.convert(Image.FORMAT_RGB8)
	var path := PHOTO_DIR + "p_%d.jpg" % int(Time.get_unix_time_from_system() * 1000.0)
	im.save_jpg(path, 0.92)
	g._toast(T("saved"), 1.5)
	_scan_gallery()
	view_i = 0
	page = "view"
	_open_view(0)
	last_thumb = _thumb(gal[0])


func _adj_row(c: Control, y: float, label: String, val: float, key: String) -> void:
	_t(c, label, Vector2(40, y + 20), 16, Color(1, 1, 1, 0.85), 0)
	_btn(c, Rect2(190, y, 46, 40), "-", "ed_adj", key + "-", 0, 24)
	var bar := Rect2(244, y + 15, 100, 10)
	c.draw_rect(bar, Color(1, 1, 1, 0.2))
	c.draw_rect(Rect2(bar.position.x + bar.size.x * 0.5 - 1.0 + val * bar.size.x * 0.5, bar.position.y - 4, 3, 18), Color.WHITE)
	_btn(c, Rect2(352, y, 46, 40), "+", "ed_adj", key + "+", 0, 24)


func _draw_edit(c: Control) -> void:
	var r := Rect2(34, 170, 372, 209)
	c.draw_rect(r, Color.BLACK)
	if ed_tex != null:
		c.draw_texture_rect(ed_tex, r, false)
	_adj_row(c, 395, T("bright"), ed_b / 0.6, "b")
	_adj_row(c, 442, T("contrast"), ed_c / 0.8, "c")
	_adj_row(c, 489, T("satur"), ed_s, "s")
	var fk := ["bw", "sepia", "warm", "cool", "vivid"]
	for i in 5:
		_btn(c, Rect2(34 + i * 75, 545, 70, 40), T(String(fk[i])), "ed_filter", fk[i], 0, 14)
	_btn(c, Rect2(34, 600, 88, 42), T("rotate"), "ed_rot", null, 0, 14)
	_btn(c, Rect2(128, 600, 88, 42), T("flip"), "ed_flip", null, 0, 14)
	_btn(c, Rect2(222, 600, 88, 42), "%s %d%%" % [T("size"), int(ed_scale * 100.0)], "ed_size", null, 0, 13)
	_btn(c, Rect2(316, 600, 90, 42), T("undo"), "ed_undo", null, 0, 14)
	_btn(c, Rect2(110, 670, 220, 52), T("save"), "ed_save", null, 2, 22)


# ---------------------------------------------------------------- clock app

func _sw_ms() -> int:
	return sw_acc + ((Time.get_ticks_msec() - sw_start) if sw_run else 0)


func _fmt_ms(ms: int) -> String:
	return "%02d:%02d.%02d" % [ms / 60000, (ms / 1000) % 60, (ms % 1000) / 10]


func _draw_clock(c: Control) -> void:
	_title(c, "clock")
	var keys := ["clk", "alarm", "stopwatch", "timer"]
	for i in 4:
		_btn(c, Rect2(40 + i * 90, 170, 86, 38), T(String(keys[i])), "clock_tab", i, 1 if clock_tab == i else 0, 14)
	var now := Time.get_time_dict_from_system()
	if clock_tab == 0:
		var ctr := Vector2(220, 380)
		c.draw_circle(ctr, 128.0, Color(0.03, 0.04, 0.08, 0.7))
		c.draw_arc(ctr, 128.0, 0.0, TAU, 64, Color(1, 1, 1, 0.9), 4.0, true)
		for k in 12:
			var a := float(k) * TAU / 12.0
			var d := Vector2(sin(a), -cos(a))
			c.draw_line(ctr + d * 108.0, ctr + d * 122.0, Color.WHITE, 3.0 if k % 3 else 5.0)
		var h := float(int(now["hour"]) % 12) + float(now["minute"]) / 60.0
		var m := float(now["minute"]) + float(now["second"]) / 60.0
		var s := float(now["second"])
		var ha := h / 12.0 * TAU
		var ma := m / 60.0 * TAU
		var sa := s / 60.0 * TAU
		c.draw_line(ctr, ctr + Vector2(sin(ha), -cos(ha)) * 62.0, Color.WHITE, 7.0, true)
		c.draw_line(ctr, ctr + Vector2(sin(ma), -cos(ma)) * 92.0, Color.WHITE, 5.0, true)
		c.draw_line(ctr, ctr + Vector2(sin(sa), -cos(sa)) * 104.0, Color(1, 0.35, 0.25), 2.5, true)
		c.draw_circle(ctr, 7.0, Color(1, 0.35, 0.25))
		_t(c, "%02d:%02d:%02d" % [now["hour"], now["minute"], now["second"]], Vector2(220, 560), 52)
		var dt := Time.get_date_dict_from_system()
		_t(c, "%04d-%02d-%02d" % [dt["year"], dt["month"], dt["day"]], Vector2(220, 615), 24, Color(1, 1, 1, 0.75))
	elif clock_tab == 1:
		_draw_alarms(c)
	elif clock_tab == 2:
		_t(c, _fmt_ms(_sw_ms()), Vector2(220, 300), 54)
		_btn(c, Rect2(40, 380, 160, 56), T("stop") if sw_run else T("start"), "sw_toggle", null, 3 if sw_run else 2, 22)
		_btn(c, Rect2(240, 380, 160, 56), T("lap"), "sw_lap", null, 0, 22)
		_btn(c, Rect2(140, 450, 160, 44), T("reset"), "sw_reset", null, 0, 18)
		for i in laps.size():
			_t(c, "%d   %s" % [laps.size() - i, _fmt_ms(int(laps[i]))], Vector2(220, 540 + i * 34), 22, Color(1, 1, 1, 0.85))
	else:
		var secs := int(ceil(tm_left)) if (tm_run or tm_left > 0.0) else tm_set
		_t(c, "%02d:%02d" % [secs / 60, secs % 60], Vector2(220, 290), 68, Color(1, 0.4, 0.3) if tm_run else Color.WHITE)
		_btn(c, Rect2(40, 360, 82, 44), "-1m", "tm_add", -60, 0, 18)
		_btn(c, Rect2(128, 360, 82, 44), "-10s", "tm_add", -10, 0, 18)
		_btn(c, Rect2(230, 360, 82, 44), "+10s", "tm_add", 10, 0, 18)
		_btn(c, Rect2(318, 360, 82, 44), "+1m", "tm_add", 60, 0, 18)
		_btn(c, Rect2(40, 440, 200, 56), T("stop") if tm_run else T("start"), "tm_toggle", null, 3 if tm_run else 2, 22)
		_btn(c, Rect2(260, 440, 140, 56), T("reset"), "tm_reset", null, 0, 20)
	if ringing > 0.0:
		var br := Rect2(40, 700, 360, 80)
		c.draw_style_box(sbs[3], br)
		_t(c, ring_msg, br.position + Vector2(130, 40), 20)
		_btn(c, Rect2(290, 715, 100, 50), T("dismiss"), "dismiss", null, 0, 15)


func _draw_alarms(c: Control) -> void:
	if alarm_edit >= 0 and alarm_edit < alarms.size():
		var a: Dictionary = alarms[alarm_edit]
		_t(c, "%02d:%02d" % [a["h"], a["m"]], Vector2(220, 300), 74)
		_btn(c, Rect2(50, 380, 130, 54), "H +", "alarm_h", 1, 0, 22)
		_btn(c, Rect2(50, 446, 130, 54), "H -", "alarm_h", -1, 0, 22)
		_btn(c, Rect2(210, 380, 80, 54), "M +5", "alarm_m", 5, 0, 18)
		_btn(c, Rect2(210, 446, 80, 54), "M -5", "alarm_m", -5, 0, 18)
		_btn(c, Rect2(300, 380, 80, 54), "M +1", "alarm_m", 1, 0, 18)
		_btn(c, Rect2(300, 446, 80, 54), "M -1", "alarm_m", -1, 0, 18)
		_btn(c, Rect2(60, 540, 150, 54), T("save"), "alarm_done", null, 2, 22)
		_btn(c, Rect2(230, 540, 150, 54), T("delete"), "alarm_del", alarm_edit, 3, 20)
		return
	if alarms.is_empty():
		_t(c, T("empty"), Vector2(220, 400), 22, Color(1, 1, 1, 0.7))
	for i in mini(alarms.size(), 5):
		var r := Rect2(36, 225 + i * 96, 368, 86)
		c.draw_style_box(sbs[4], r)
		var a2: Dictionary = alarms[i]
		_t(c, "%02d:%02d" % [a2["h"], a2["m"]], r.position + Vector2(24, 43), 40, Color.WHITE if bool(a2["on"]) else Color(1, 1, 1, 0.4), 0)
		hits.append({"r": Rect2(r.position, Vector2(210, 86)), "a": "alarm_open", "v": i})
		_btn(c, Rect2(r.position.x + 230, r.position.y + 22, 120, 42), T("on") if bool(a2["on"]) else T("off"), "alarm_toggle", i, 2 if bool(a2["on"]) else 0, 18)
	if alarms.size() < 5:
		_btn(c, Rect2(110, 725, 220, 52), T("add"), "alarm_add", null, 1, 22)


# ---------------------------------------------------------------- store app

func _store_items() -> Array:
	var out: Array = []
	if store_tab == 0:
		out.append({"k": "car", "id": "starter", "name": "STARTER", "price": 0, "color": Color(0.8, 0.08, 0.08)})
		for cc in CARS:
			out.append({"k": "car", "id": cc["id"], "name": cc["name"], "price": cc["price"], "color": cc["color"]})
	elif store_tab == 1:
		for i in AMMO.size():
			out.append({"k": "ammo", "idx": i, "name": AMMO[i]["name"], "price": AMMO[i]["price"], "n": AMMO[i]["n"], "color": Color(0.9, 0.7, 0.2)})
	elif store_tab == 2:
		out.append({"k": "heli", "id": "heli", "name": "HELICOPTER", "price": 90000, "color": Color(0.3, 0.5, 0.9)})
	else:
		for s in SOON_APPS:
			out.append({"k": "soon", "name": s, "price": 0, "color": Color(0.5, 0.5, 0.58)})
	return out


func _draw_store(c: Control) -> void:
	_title(c, "store")
	_t(c, _fmt(money), Vector2(400, 128), 18, Color(1, 0.85, 0.3), 2)
	var keys := ["cars", "ammo", "air", "apps"]
	for i in 4:
		_btn(c, Rect2(40 + i * 90, 170, 86, 38), T(String(keys[i])), "store_tab", i, 1 if store_tab == i else 0, 14)
	var items := _store_items()
	var per := 4
	var pages := maxi((items.size() - 1) / per + 1, 1)
	store_page = clampi(store_page, 0, pages - 1)
	for k in per:
		var idx := store_page * per + k
		if idx >= items.size():
			break
		var it: Dictionary = items[idx]
		var r := Rect2(36, 220 + k * 130, 368, 120)
		c.draw_style_box(sbs[4], r)
		var sw := Rect2(r.position.x + 10, r.position.y + 10, 100, 100)
		c.draw_rect(sw, Color(it["color"]).darkened(0.1))
		var icon := "car"
		if it["k"] == "ammo":
			icon = "guns"
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		g._icon(c, icon, sw.position + sw.size * 0.5, 26.0)
		_t(c, String(it["name"]), r.position + Vector2(124, 28), 20, Color.WHITE, 0)
		var br := Rect2(r.position.x + 124, r.position.y + 76, 232, 34)
		var kind := String(it["k"])
		if kind == "soon":
			_plain(c, br, T("soon"), 5, 16)
			continue
		if kind == "ammo":
			_t(c, "%s  +%d" % [_fmt(int(it["price"])), int(it["n"])], r.position + Vector2(124, 56), 17, Color(1, 0.85, 0.3), 0)
			_btn(c, br, T("buy"), "buy_ammo", int(it["idx"]), 2 if money >= int(it["price"]) else 0, 17)
			continue
		var id := String(it["id"])
		_t(c, "—" if int(it["price"]) == 0 else _fmt(int(it["price"])), r.position + Vector2(124, 56), 17, Color(1, 0.85, 0.3), 0)
		if kind == "heli":
			_t(c, T("flysoon"), r.position + Vector2(124, 64), 12, Color(1, 1, 1, 0.5), 0)
			if bool(owned.get("heli", false)):
				_plain(c, br, T("owned"), 5, 16)
			else:
				_btn(c, br, T("buy"), "buy_heli", null, 2 if money >= 90000 else 0, 17)
			continue
		if bool(owned.get(id, false)):
			if car_sel == id:
				_plain(c, br, T("selected"), 5, 16)
			else:
				_btn(c, br, T("select"), "sel_car", id, 1, 17)
		else:
			_btn(c, br, T("buy"), "buy_car", id, 2 if money >= int(it["price"]) else 0, 17)
	if pages > 1:
		_btn(c, Rect2(60, 745, 100, 40), "<", "store_prev", null, 0, 22)
		_t(c, "%d / %d" % [store_page + 1, pages], Vector2(220, 765), 18)
		_btn(c, Rect2(280, 745, 100, 40), ">", "store_next", null, 0, 22)


# ---------------------------------------------------------------- settings app

func _draw_settings(c: Control) -> void:
	_title(c, "settings")
	_t(c, T("language"), Vector2(40, 186), 18, Color(1, 1, 1, 0.8), 0)
	for i in LANGS.size():
		var r := Rect2(40 + (i % 3) * 122, 205 + (i / 3) * 52, 114, 44)
		_btn(c, r, String(LANG_NAMES[i]), "set_lang", LANGS[i], 1 if lang == LANGS[i] else 0, 16)
	_t(c, T("wallpaper"), Vector2(40, 330), 18, Color(1, 1, 1, 0.8), 0)
	for i in WALLS.size():
		var r2 := Rect2(40 + i * 62, 352, 54, 70)
		var w: Array = WALLS[i]
		var top: Color = w[0]
		var bot: Color = w[1]
		c.draw_polygon(PackedVector2Array([r2.position, Vector2(r2.end.x, r2.position.y), r2.end, Vector2(r2.position.x, r2.end.y)]), PackedColorArray([top, top, bot, bot]))
		c.draw_rect(r2, Color(1, 1, 1, 0.95 if wall_idx == i else 0.3), false, 3.0 if wall_idx == i else 1.5)
		hits.append({"r": r2, "a": "set_wall", "v": i})
	_btn(c, Rect2(40, 435, 360, 44), T("photos") + "  ›", "wall_photo", null, 0, 18)
	_btn(c, Rect2(40, 505, 360, 44), "%s: %s" % [T("shadows"), T("on") if shadows else T("off")], "toggle_shadows", null, 2 if shadows else 0, 18)
	_btn(c, Rect2(40, 560, 360, 44), "%s: %s" % [T("fps"), T("on") if show_fps else T("off")], "toggle_fps", null, 2 if show_fps else 0, 18)
	_t(c, T("volume"), Vector2(40, 640), 18, Color(1, 1, 1, 0.8), 0)
	_btn(c, Rect2(160, 620, 56, 44), "-", "vol", -0.1, 0, 26)
	_t(c, "%d%%" % int(volume * 100.0), Vector2(262, 642), 22)
	_btn(c, Rect2(312, 620, 56, 44), "+", "vol", 0.1, 0, 26)


# ---------------------------------------------------------------- drawing entry points

func draw_bg(c: Control) -> void:
	var r := Rect2(42, 42, 356, 816)
	if wall_tex != null:
		var ts := wall_tex.get_size()
		var want := r.size.x / r.size.y
		var sw := ts.y * want
		c.draw_texture_rect_region(wall_tex, r, Rect2((ts.x - sw) * 0.5, 0.0, sw, ts.y))
		c.draw_rect(r, Color(0, 0, 0, 0.22))
	else:
		var w: Array = WALLS[clampi(wall_idx, 0, WALLS.size() - 1)]
		var top: Color = w[0]
		var bot: Color = w[1]
		c.draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]), PackedColorArray([top, top, bot, bot]))
	if app != -1:
		c.draw_rect(r, Color(0, 0, 0, 0.5))


func draw(c: Control) -> void:
	hits.clear()
	match app:
		4:
			_draw_camera(c)
		5:
			_draw_photos(c)
		6:
			_draw_clock(c)
		7:
			_draw_store(c)
		8:
			_draw_settings(c)


func draw_hud(ui: Control) -> void:
	_t(ui, _fmt(money), Vector2(30, 205), 30, Color(1, 0.85, 0.3), 0)
	if gain_t > 0.0:
		_t(ui, gain_txt, Vector2(30, 240), 24, Color(0.5, 1, 0.5, clampf(gain_t, 0.0, 1.0)), 0)
	if show_fps:
		_t(ui, "%d FPS" % Engine.get_frames_per_second(), Vector2(30, 280), 22, Color(1, 1, 1, 0.8), 0)
	if ringing > 0.0:
		_t(ui, ring_msg, Vector2(g._vp().x * 0.5, 130), 40, Color(1, 0.4, 0.3))
