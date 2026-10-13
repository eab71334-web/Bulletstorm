extends Node
# apps.gd - phone home screen + apps (batch 4)

const SAVE_PATH := "user://phone.cfg"
const PHOTO_DIR := "user://photos/"
const VIDEO_DIR := "user://videos/"
const FONT_PATH := "res://game/font.ttf"
const CAR_DIR := "res://game/cars/"
const ICON_DIR := "res://game/icons/"
const A_CAR_GLB := "res://game/car.glb"
const A_CAR_YAW := PI
const A_CAR_LEN := 5.4
const START_MONEY := 20000

# ======== الأكواد السرية (غيّرها لأي أرقام تبيها) ========
# اكتبها في تطبيق الهاتف (الأرقام) واضغط زر الاتصال الأخضر
const CHEAT_HELI := "*#4411#"      # يستدعي الهليكوبتر
const CHEAT_MONEY := "*#9000#"     # فلوس لا نهائية (تشغيل / إيقاف)
const INF_MONEY := 999999999

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
	{"id": "starter", "name": "STARTER", "price": 0, "color": Color(0.8, 0.08, 0.08), "spd": 0.6, "acc": 0.6, "hnd": 0.6},
	{"id": "sport", "name": "SPORT GT", "price": 15000, "color": Color(0.9, 0.1, 0.1), "spd": 0.9, "acc": 0.85, "hnd": 0.8},
	{"id": "muscle", "name": "MUSCLE V8", "price": 22000, "color": Color(0.1, 0.1, 0.14), "spd": 0.8, "acc": 0.9, "hnd": 0.55},
	{"id": "suv", "name": "SUV 4X4", "price": 18000, "color": Color(0.85, 0.86, 0.9), "spd": 0.6, "acc": 0.6, "hnd": 0.7},
	{"id": "classic", "name": "CLASSIC", "price": 9000, "color": Color(0.1, 0.3, 0.8), "spd": 0.55, "acc": 0.5, "hnd": 0.6},
	{"id": "taxi", "name": "TAXI", "price": 6000, "color": Color(0.95, 0.8, 0.1), "spd": 0.5, "acc": 0.6, "hnd": 0.65},
]
const AMMO := [
	{"w": 1, "name": "PISTOL AMMO", "price": 120, "n": 24},
	{"w": 2, "name": "SMG AMMO", "price": 350, "n": 90},
	{"w": 3, "name": "SHOTGUN SHELLS", "price": 300, "n": 12},
	{"w": 4, "name": "RIFLE AMMO", "price": 450, "n": 60},
]
const SOON_APPS := ["Chirp (social)", "Snapgram (social)", "Mini Racer (game)", "Sky Jump (game)", "Tower Chess (game)"]
const HOME_GRID := [
	{"app": 0, "key": "map", "c1": Color(0.62, 0.9, 0.55), "c2": Color(0.3, 0.75, 0.4)},
	{"app": 1, "key": "mycar", "c1": Color(0.35, 0.65, 1.0), "c2": Color(0.1, 0.35, 0.9)},
	{"app": 2, "key": "guns", "c1": Color(1.0, 0.78, 0.25), "c2": Color(1.0, 0.5, 0.05)},
	{"app": 3, "key": "taxi", "c1": Color(1.0, 0.82, 0.2), "c2": Color(0.95, 0.6, 0.05)},
	{"app": 6, "key": "clk", "c1": Color(0.16, 0.16, 0.18), "c2": Color(0.0, 0.0, 0.0)},
	{"app": 7, "key": "store", "c1": Color(0.3, 0.75, 1.0), "c2": Color(0.05, 0.4, 0.95)},
	{"app": 10, "key": "chirp", "c1": Color(0.45, 0.85, 1.0), "c2": Color(0.1, 0.55, 0.95)},
	{"app": 11, "key": "racer", "c1": Color(1.0, 0.4, 0.4), "c2": Color(0.75, 0.1, 0.2)},
]
const HOME_DOCK := [
	{"app": 9, "key": "phone", "c1": Color(0.45, 0.92, 0.42), "c2": Color(0.1, 0.72, 0.25)},
	{"app": 4, "key": "camera", "c1": Color(0.88, 0.89, 0.91), "c2": Color(0.6, 0.61, 0.65)},
	{"app": 5, "key": "photos", "c1": Color(1.0, 1.0, 1.0), "c2": Color(0.92, 0.92, 0.95)},
	{"app": 8, "key": "settings", "c1": Color(0.78, 0.79, 0.82), "c2": Color(0.5, 0.51, 0.56)},
]
const CONTACTS := [
	{"name": "police", "num": "100", "kind": "police", "icon": "police", "col": Color(0.2, 0.4, 0.95)},
	{"name": "ambulance", "num": "101", "kind": "ambulance", "icon": "ambulance", "col": Color(0.9, 0.2, 0.25)},
	{"name": "fire", "num": "102", "kind": "fire", "icon": "fire", "col": Color(0.95, 0.5, 0.15)},
	{"name": "taxi", "num": "103", "kind": "taxi", "icon": "taxi", "col": Color(0.9, 0.75, 0.15)},
	{"name": "mechanic", "num": "104", "kind": "mechanic", "icon": "mechanic", "col": Color(0.5, 0.55, 0.62)},
	{"name": "boss", "num": "555-0101", "kind": "none", "icon": "briefcase", "col": Color(0.55, 0.4, 0.9)},
	{"name": "sara", "num": "555-0102", "kind": "none", "icon": "person", "col": Color(0.9, 0.4, 0.6)},
]

const TXT := {
	"en": {"camera": "Camera", "photos": "Photos", "clock": "Clock", "store": "Store", "settings": "Settings", "photo": "PHOTO", "video": "VIDEO", "slow": "SLOW", "normal": "NORMAL", "fast": "FAST", "save": "SAVE", "delete": "DELETE", "wallpaper": "Wallpaper", "language": "Language", "buy": "BUY", "owned": "OWNED", "select": "SELECT", "selected": "SELECTED", "cars": "CARS", "ammo": "AMMO", "air": "AIR", "apps": "APPS", "alarm": "Alarm", "stopwatch": "Stopwatch", "timer": "Timer", "clk": "Clock", "start": "START", "stop": "STOP", "lap": "LAP", "reset": "RESET", "add": "+ ALARM", "ring": "ALARM!", "edit": "EDIT", "bright": "Brightness", "contrast": "Contrast", "satur": "Saturation", "bw": "B&W", "sepia": "Sepia", "warm": "Warm", "cool": "Cool", "vivid": "Vivid", "rotate": "ROTATE", "flip": "FLIP", "size": "SIZE", "undo": "UNDO", "saved": "Saved", "empty": "Nothing here yet", "nomoney": "Not enough money", "bought": "Purchased", "setwp": "WALLPAPER", "soon": "SOON", "shadows": "Shadows", "fps": "Show FPS", "volume": "Volume", "on": "ON", "off": "OFF", "gallery": "Gallery", "pickwp": "Pick a wallpaper", "flysoon": "Flying: next update", "dismiss": "DISMISS", "back": "Back", "photocam": "BACK CAM", "selfie": "FRONT CAM", "map": "Maps", "mycar": "My Car", "guns": "Weapons", "taxi": "Taxi", "chirp": "Chirp", "racer": "Racer", "phone": "Phone", "keypad": "Keypad", "recents": "Recents", "contacts": "Contacts", "calling": "Calling...", "connected": "Connected", "end": "END", "police": "Police", "ambulance": "Ambulance", "fire": "Fire Dept", "mechanic": "Mechanic", "boss": "Boss", "sara": "Sara", "noanswer": "No answer", "wrong": "Wrong number", "dispatched": "Police dispatched", "healed": "Paramedics treated you", "fdispatched": "Fire dept notified", "onway": "On the way", "phonesize": "Phone size"},
	"ar": {"camera": "الكاميرا", "photos": "الصور", "clock": "الساعة", "store": "المتجر", "settings": "الإعدادات", "photo": "صورة", "video": "فيديو", "slow": "بطيء", "normal": "عادي", "fast": "سريع", "save": "حفظ", "delete": "حذف", "wallpaper": "الخلفية", "language": "اللغة", "buy": "شراء", "owned": "مملوك", "select": "اختيار", "selected": "مختار", "cars": "سيارات", "ammo": "ذخيرة", "air": "جوي", "apps": "تطبيقات", "alarm": "منبه", "stopwatch": "ايقاف", "timer": "مؤقت", "clk": "ساعة", "start": "ابدأ", "stop": "ايقاف", "lap": "دورة", "reset": "تصفير", "add": "+ منبه", "ring": "المنبه!", "edit": "تعديل", "bright": "السطوع", "contrast": "التباين", "satur": "التشبع", "bw": "أبيض وأسود", "sepia": "بني", "warm": "دافئ", "cool": "بارد", "vivid": "زاهي", "rotate": "تدوير", "flip": "قلب", "size": "الحجم", "undo": "تراجع", "saved": "تم الحفظ", "empty": "لا يوجد شيء بعد", "nomoney": "رصيد غير كاف", "bought": "تم الشراء", "setwp": "خلفية", "soon": "قريبا", "shadows": "الظلال", "fps": "عرض الإطارات", "volume": "الصوت", "on": "تشغيل", "off": "ايقاف", "gallery": "المعرض", "pickwp": "اختر خلفية", "flysoon": "الطيران: التحديث القادم", "dismiss": "ايقاف", "back": "رجوع", "photocam": "خلفية", "selfie": "أمامية", "map": "الخريطة", "mycar": "سيارتي", "guns": "الأسلحة", "taxi": "تاكسي", "chirp": "تغريد", "racer": "سباق", "phone": "الهاتف", "keypad": "الأرقام", "recents": "الأخيرة", "contacts": "الأسماء", "calling": "جاري الاتصال...", "connected": "تم الاتصال", "end": "إنهاء", "police": "الشرطة", "ambulance": "الإسعاف", "fire": "المطافئ", "mechanic": "ميكانيكي", "boss": "المدير", "sara": "سارة", "noanswer": "لا يوجد رد", "wrong": "رقم خاطئ", "dispatched": "تم إرسال الشرطة", "healed": "عالجك المسعفون", "fdispatched": "تم إبلاغ المطافئ", "onway": "في الطريق", "phonesize": "حجم الهاتف"},
	"fr": {"camera": "Appareil photo", "photos": "Photos", "clock": "Horloge", "store": "Boutique", "settings": "Réglages", "photo": "PHOTO", "video": "VIDÉO", "slow": "LENT", "normal": "NORMAL", "fast": "RAPIDE", "save": "ENREGISTRER", "delete": "SUPPRIMER", "wallpaper": "Fond d'écran", "language": "Langue", "buy": "ACHETER", "owned": "POSSÉDÉ", "select": "CHOISIR", "selected": "CHOISI", "cars": "VOITURES", "ammo": "MUNITIONS", "air": "AIR", "apps": "APPS", "alarm": "Alarme", "stopwatch": "Chrono", "timer": "Minuteur", "clk": "Horloge", "start": "DÉMARRER", "stop": "STOP", "lap": "TOUR", "reset": "RAZ", "add": "+ ALARME", "ring": "ALARME !", "edit": "MODIFIER", "bright": "Luminosité", "contrast": "Contraste", "satur": "Saturation", "bw": "N&B", "sepia": "Sépia", "warm": "Chaud", "cool": "Froid", "vivid": "Vif", "rotate": "PIVOTER", "flip": "MIROIR", "size": "TAILLE", "undo": "ANNULER", "saved": "Enregistré", "empty": "Rien ici", "nomoney": "Fonds insuffisants", "bought": "Acheté", "setwp": "FOND", "soon": "BIENTÔT", "shadows": "Ombres", "fps": "Afficher FPS", "volume": "Volume", "on": "OUI", "off": "NON", "gallery": "Galerie", "pickwp": "Choisir un fond", "flysoon": "Vol : prochaine mise à jour", "dismiss": "ARRÊTER", "back": "Retour", "photocam": "ARRIÈRE", "selfie": "AVANT", "map": "Plans", "mycar": "Ma voiture", "guns": "Armes", "taxi": "Taxi", "chirp": "Chirp", "racer": "Course", "phone": "Téléphone", "keypad": "Clavier", "recents": "Récents", "contacts": "Contacts", "calling": "Appel...", "connected": "Connecté", "end": "FIN", "police": "Police", "ambulance": "Ambulance", "fire": "Pompiers", "mechanic": "Mécanicien", "boss": "Patron", "sara": "Sara", "noanswer": "Pas de réponse", "wrong": "Mauvais numéro", "dispatched": "Police envoyée", "healed": "Soigné par les secours", "fdispatched": "Pompiers prévenus", "onway": "En route", "phonesize": "Taille"},
	"es": {"camera": "Cámara", "photos": "Fotos", "clock": "Reloj", "store": "Tienda", "settings": "Ajustes", "photo": "FOTO", "video": "VÍDEO", "slow": "LENTO", "normal": "NORMAL", "fast": "RÁPIDO", "save": "GUARDAR", "delete": "BORRAR", "wallpaper": "Fondo", "language": "Idioma", "buy": "COMPRAR", "owned": "TUYO", "select": "ELEGIR", "selected": "ELEGIDO", "cars": "COCHES", "ammo": "MUNICIÓN", "air": "AIRE", "apps": "APPS", "alarm": "Alarma", "stopwatch": "Cronómetro", "timer": "Temporizador", "clk": "Reloj", "start": "INICIAR", "stop": "PARAR", "lap": "VUELTA", "reset": "REINICIAR", "add": "+ ALARMA", "ring": "¡ALARMA!", "edit": "EDITAR", "bright": "Brillo", "contrast": "Contraste", "satur": "Saturación", "bw": "B/N", "sepia": "Sepia", "warm": "Cálido", "cool": "Frío", "vivid": "Vívido", "rotate": "GIRAR", "flip": "VOLTEAR", "size": "TAMAÑO", "undo": "DESHACER", "saved": "Guardado", "empty": "Nada aún", "nomoney": "Dinero insuficiente", "bought": "Comprado", "setwp": "FONDO", "soon": "PRONTO", "shadows": "Sombras", "fps": "Mostrar FPS", "volume": "Volumen", "on": "SÍ", "off": "NO", "gallery": "Galería", "pickwp": "Elige un fondo", "flysoon": "Vuelo: próxima actualización", "dismiss": "DETENER", "back": "Atrás", "photocam": "TRASERA", "selfie": "FRONTAL", "map": "Mapas", "mycar": "Mi coche", "guns": "Armas", "taxi": "Taxi", "chirp": "Chirp", "racer": "Carreras", "phone": "Teléfono", "keypad": "Teclado", "recents": "Recientes", "contacts": "Contactos", "calling": "Llamando...", "connected": "Conectado", "end": "FIN", "police": "Policía", "ambulance": "Ambulancia", "fire": "Bomberos", "mechanic": "Mecánico", "boss": "Jefe", "sara": "Sara", "noanswer": "Sin respuesta", "wrong": "Número erróneo", "dispatched": "Policía enviada", "healed": "Te atendieron", "fdispatched": "Bomberos avisados", "onway": "En camino", "phonesize": "Tamaño"},
	"tr": {"camera": "Kamera", "photos": "Fotoğraflar", "clock": "Saat", "store": "Mağaza", "settings": "Ayarlar", "photo": "FOTO", "video": "VİDEO", "slow": "YAVAŞ", "normal": "NORMAL", "fast": "HIZLI", "save": "KAYDET", "delete": "SİL", "wallpaper": "Duvar kâğıdı", "language": "Dil", "buy": "SATIN AL", "owned": "SAHİP", "select": "SEÇ", "selected": "SEÇİLİ", "cars": "ARABALAR", "ammo": "MERMİ", "air": "HAVA", "apps": "UYGULAMA", "alarm": "Alarm", "stopwatch": "Kronometre", "timer": "Zamanlayıcı", "clk": "Saat", "start": "BAŞLAT", "stop": "DURDUR", "lap": "TUR", "reset": "SIFIRLA", "add": "+ ALARM", "ring": "ALARM!", "edit": "DÜZENLE", "bright": "Parlaklık", "contrast": "Kontrast", "satur": "Doygunluk", "bw": "S/B", "sepia": "Sepya", "warm": "Sıcak", "cool": "Soğuk", "vivid": "Canlı", "rotate": "DÖNDÜR", "flip": "ÇEVİR", "size": "BOYUT", "undo": "GERİ AL", "saved": "Kaydedildi", "empty": "Henüz yok", "nomoney": "Yetersiz bakiye", "bought": "Satın alındı", "setwp": "DUVAR", "soon": "YAKINDA", "shadows": "Gölgeler", "fps": "FPS göster", "volume": "Ses", "on": "AÇIK", "off": "KAPALI", "gallery": "Galeri", "pickwp": "Duvar kâğıdı seç", "flysoon": "Uçuş: sonraki güncelleme", "dismiss": "KAPAT", "back": "Geri", "photocam": "ARKA", "selfie": "ÖN", "map": "Harita", "mycar": "Arabam", "guns": "Silahlar", "taxi": "Taksi", "chirp": "Chirp", "racer": "Yarış", "phone": "Telefon", "keypad": "Tuş takımı", "recents": "Son", "contacts": "Kişiler", "calling": "Aranıyor...", "connected": "Bağlandı", "end": "BİTİR", "police": "Polis", "ambulance": "Ambulans", "fire": "İtfaiye", "mechanic": "Tamirci", "boss": "Patron", "sara": "Sara", "noanswer": "Cevap yok", "wrong": "Yanlış numara", "dispatched": "Polis gönderildi", "healed": "Sağlık ekibi tedavi etti", "fdispatched": "İtfaiye haberdar", "onway": "Yolda", "phonesize": "Boyut"},
}

var g
var app := -1
var page := ""
var hits: Array = []
var sbs: Array = []
var sq_cache := {}
var font: Font
var sys_font: SystemFont
var custom_font := false
var icon_tex := {}
var lang := "en"
var money := START_MONEY
var inf_money := false
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

var phone_tab := 0
var dial := ""
var recents: Array = []
var call_state := ""
var call_name := ""
var call_num := ""
var call_kind := ""
var call_ic := ""
var call_col := Color.WHITE
var call_t := 0.0
var call_msg := ""
var call_player: AudioStreamPlayer
var heal_t := 0.0

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
	call_player = AudioStreamPlayer.new()
	call_player.stream = _ringback_stream()
	call_player.volume_db = -6.0
	add_child(call_player)
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
	_set_player_layers(g.model)
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
		_mk(Color(0.25, 0.5, 0.95, 0.9), Color(1, 1, 1, 0.8), 14, 2),
		_mk(Color(0.2, 0.7, 0.4, 0.92), Color(1, 1, 1, 0.8), 14, 2),
		_mk(Color(0.85, 0.2, 0.2, 0.92), Color(1, 1, 1, 0.8), 14, 2),
		_mk(Color(0.03, 0.04, 0.08, 0.72), Color(1, 1, 1, 0.18), 18, 2),
		_mk(Color(0.3, 0.3, 0.34, 0.8), Color(1, 1, 1, 0.2), 14, 2),
		_mk(Color(1, 1, 1, 0.14), Color(1, 1, 1, 0.28), 30, 2),
		_mk(Color(1, 1, 1, 0.2), Color(1, 1, 1, 0.15), 34, 1),
		_mk(Color(0.15, 0.15, 0.17, 0.96), Color(0, 0, 0, 0), 12, 0),
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
	if lang == "ar":
		_t(c, T(key), Vector2(404, 128), 32, Color.WHITE, 2)
	else:
		_t(c, T(key), Vector2(34, 128), 32, Color.WHITE, 0)


func _grad(c: Control, r: Rect2, top: Color, bot: Color) -> void:
	c.draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]), PackedColorArray([top, top, bot, bot]))


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
	if inf_money:
		money = INF_MONEY
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


func _ringback_stream() -> AudioStreamWAV:
	var rate := 22050
	var n := rate * 3
	var s := PackedFloat32Array()
	s.resize(n)
	for i in n:
		var t := float(i) / float(rate)
		var on := t < 1.0
		s[i] = ((sin(TAU * 440.0 * t) + sin(TAU * 480.0 * t)) * 0.18) if on else 0.0
	return g._wav(s, rate, true)


func _set_player_layers(n: Node) -> void:
	if n is VisualInstance3D:
		(n as VisualInstance3D).layers = 1 << 19
	for ch in n.get_children():
		_set_player_layers(ch)


# ---------------------------------------------------------------- secret codes

func _cheat(code: String) -> bool:
	if code == CHEAT_HELI:
		g._set_phone(false)
		g.spawn_heli()
		return true
	if code == CHEAT_MONEY:
		inf_money = not inf_money
		money = INF_MONEY if inf_money else START_MONEY
		dirty = true
		g._toast("UNLIMITED MONEY: ON" if inf_money else "UNLIMITED MONEY: OFF", 2.5)
		return true
	return false


# ---------------------------------------------------------------- save / load

func _save() -> void:
	var cf := ConfigFile.new()
	cf.set_value("p", "money", money)
	cf.set_value("p", "inf", inf_money)
	cf.set_value("p", "lang", lang)
	cf.set_value("p", "wall_idx", wall_idx)
	cf.set_value("p", "wall_path", wall_path)
	cf.set_value("p", "owned", owned)
	cf.set_value("p", "car_sel", car_sel)
	cf.set_value("p", "alarms", alarms)
	cf.set_value("p", "volume", volume)
	cf.set_value("p", "shadows", shadows)
	cf.set_value("p", "fps", show_fps)
	cf.set_value("p", "recents", recents)
	cf.save(SAVE_PATH)
	dirty = false


func _load() -> void:
	var cf := ConfigFile.new()
	if cf.load(SAVE_PATH) != OK:
		return
	money = int(cf.get_value("p", "money", START_MONEY))
	inf_money = bool(cf.get_value("p", "inf", false))
	lang = String(cf.get_value("p", "lang", "en"))
	wall_idx = int(cf.get_value("p", "wall_idx", 0))
	wall_path = String(cf.get_value("p", "wall_path", ""))
	owned = cf.get_value("p", "owned", {"starter": true})
	car_sel = String(cf.get_value("p", "car_sel", "starter"))
	alarms = cf.get_value("p", "alarms", [])
	volume = float(cf.get_value("p", "volume", 1.0))
	shadows = bool(cf.get_value("p", "shadows", true))
	show_fps = bool(cf.get_value("p", "fps", false))
	recents = cf.get_value("p", "recents", [])


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
		for cc in CARS:
			if cc["id"] == id:
				col = cc["color"]
	var holder = g._fit_glb(path, A_CAR_YAW, A_CAR_LEN, false, true)
	if holder != null:
		vis.add_child(holder)
	else:
		g._build_car_procedural(vis, col, false, g.car_wheels)


# ---------------------------------------------------------------- per-frame logic

func _process(delta: float) -> void:
	if inf_money:
		money = INF_MONEY
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
	if call_state == "ringing":
		call_t += delta
		if call_t >= 2.4:
			_connect_call()
	elif call_state == "connected":
		call_t += delta
		if call_t >= 5.0:
			_end_call()
	if heal_t > 0.0:
		heal_t -= delta
		if heal_t <= 0.0:
			g.hp = 100.0
			g._toast(T("healed"), 3.0)
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
	elif i == 9:
		phone_tab = 0


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
	if call_state != "":
		_end_call()
		return
	if page == "edit":
		page = "view"
	elif page != "":
		page = ""
	elif pick_mode:
		pick_mode = false
		app = 8
	else:
		close_app()


# ---------------------------------------------------------------- touch / actions

func touch(lp: Vector2) -> void:
	if lp.y > 836.0 and absf(lp.x - 220.0) < 90.0:
		if app == -1:
			g._set_phone(false)
		else:
			_back()
		return
	for i in range(hits.size() - 1, -1, -1):
		var h: Dictionary = hits[i]
		if (h["r"] as Rect2).has_point(lp):
			var val = h["v"]
			if h.has("s"):
				var sp: Vector2 = h["s"]
				val = clampf((lp.x - sp.x) / sp.y, 0.0, 1.0)
			_act(String(h["a"]), val)
			return


func _open_home(i: int) -> void:
	if i >= 10:
		g._toast(T("soon"), 1.5)
	elif i <= 3:
		g._phone_app(i)
	else:
		open_app(i)


func _act(a: String, v) -> void:
	match a:
		"open":
			_open_home(int(v))
		"zoom":
			g.phone_scale = clampf(float(g.phone_scale) + float(v), 0.5, 1.05)
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
		"ph_tab":
			phone_tab = int(v)
		"dial":
			if dial.length() < 12:
				dial += String(v)
		"dial_del":
			dial = dial.substr(0, maxi(dial.length() - 1, 0))
		"dial_call":
			if dial != "":
				var code := dial
				dial = ""
				if _cheat(code):
					return
				_call_number(code)
		"call_contact":
			var ct: Dictionary = CONTACTS[int(v)]
			_start_call(String(ct["name"]), String(ct["num"]), String(ct["kind"]), ct["col"], String(ct["icon"]))
		"redial":
			var r: Dictionary = recents[int(v)]
			_start_call(String(r["n"]), String(r["num"]), String(r["k"]), r["c"], String(r.get("ic", r["k"])))
		"end_call":
			_end_call()
		"page_set":
			page = String(v)
		"back_page":
			_back()
		"vol_set":
			volume = snappedf(clampf(float(v), 0.0, 1.0), 0.05)
			_apply_options()
			dirty = true
		"size_set":
			g.phone_scale = clampf(0.5 + float(v) * 0.55, 0.5, 1.05)


func _pay(price: int) -> bool:
	if inf_money:
		dirty = true
		g._toast(T("bought"), 1.8)
		return true
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
	for cc in CARS:
		if cc["id"] == id:
			return int(cc["price"])
	return 0


# ---------------------------------------------------------------- contact icons (rounded squares)

func _sq(col: Color, rad: int, border: bool) -> StyleBoxFlat:
	var key := "%s_%d_%s" % [col.to_html(true), rad, str(border)]
	if sq_cache.has(key):
		return sq_cache[key]
	var s := _mk(col, Color(1, 1, 1, 0.5) if border else Color(0, 0, 0, 0), rad, 2 if border else 0)
	sq_cache[key] = s
	return s


func _ci_glyph(c: Control, ic: String, p: Vector2, u: float, col: Color) -> void:
	var w := Color(1, 1, 1, 0.97)
	match ic:
		"police":
			c.draw_colored_polygon(PackedVector2Array([p + Vector2(-0.8, -0.9) * u, p + Vector2(0.8, -0.9) * u, p + Vector2(0.8, 0.15) * u, p + Vector2(0, 1.0) * u, p + Vector2(-0.8, 0.15) * u]), w)
			c.draw_circle(p + Vector2(0, -0.1) * u, u * 0.3, col.darkened(0.15))
		"ambulance":
			c.draw_rect(Rect2(p + Vector2(-0.3, -0.95) * u, Vector2(0.6, 1.9) * u), w)
			c.draw_rect(Rect2(p + Vector2(-0.95, -0.3) * u, Vector2(1.9, 0.6) * u), w)
		"fire":
			c.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -1.0) * u, p + Vector2(0.55, -0.2) * u, p + Vector2(0.8, 0.4) * u, p + Vector2(0.4, 0.95) * u, p + Vector2(-0.4, 0.95) * u, p + Vector2(-0.8, 0.4) * u, p + Vector2(-0.45, -0.1) * u, p + Vector2(-0.2, -0.4) * u]), w)
			c.draw_circle(p + Vector2(0, 0.55) * u, u * 0.3, col.darkened(0.1))
		"taxi":
			_glyph(c, "taxi", p, u * 0.95)
		"mechanic":
			c.draw_line(p + Vector2(-0.75, 0.75) * u, p + Vector2(0.4, -0.4) * u, w, u * 0.38)
			c.draw_circle(p + Vector2(0.5, -0.5) * u, u * 0.52, w)
			c.draw_circle(p + Vector2(0.68, -0.68) * u, u * 0.22, col.darkened(0.2))
		"briefcase":
			c.draw_rect(Rect2(p + Vector2(-0.9, -0.4) * u, Vector2(1.8, 1.3) * u), w)
			c.draw_arc(p + Vector2(0, -0.4 * u), u * 0.4, PI, TAU, 12, w, u * 0.18, true)
			c.draw_line(p + Vector2(-0.9, 0.15) * u, p + Vector2(0.9, 0.15) * u, col.darkened(0.2), u * 0.1)
		"unknown":
			_t(c, "?", p, int(u * 2.2))
		_:
			c.draw_circle(p + Vector2(0, -0.45) * u, u * 0.45, w)
			c.draw_arc(p + Vector2(0, 0.85 * u), u * 0.7, PI, TAU, 16, w, u * 0.55, true)


func _contact_icon(c: Control, p: Vector2, r: float, col: Color, ic: String) -> void:
	var rect := Rect2(p - Vector2(r, r), Vector2(r, r) * 2.0)
	var rad := int(r * 0.42)
	if ic == "wrong":
		ic = "unknown"
	c.draw_style_box(_sq(Color(0, 0, 0, 0.3), rad, false), Rect2(rect.position + Vector2(0, 3), rect.size))
	c.draw_style_box(_sq(col.darkened(0.3), rad, true), rect)
	c.draw_style_box(_sq(col, maxi(rad - 2, 2), false), Rect2(rect.position + Vector2(3, 3), rect.size - Vector2(6, 9)))
	_ci_glyph(c, ic, p + Vector2(0, -1.0), r * 0.5, col)


# ---------------------------------------------------------------- phone app (calls, contacts)

func _call_number(num: String) -> void:
	for ct in CONTACTS:
		if String(ct["num"]) == num:
			_start_call(String(ct["name"]), num, String(ct["kind"]), ct["col"], String(ct["icon"]))
			return
	_start_call(num, num, "wrong", Color(0.5, 0.5, 0.58), "unknown")


func _start_call(key: String, num: String, kind: String, col: Color, ic: String) -> void:
	call_state = "ringing"
	call_name = key
	call_num = num
	call_kind = kind
	call_ic = ic
	call_col = col
	call_t = 0.0
	call_msg = ""
	call_player.play()
	var t := Time.get_time_dict_from_system()
	recents.push_front({"n": key, "num": num, "k": kind, "ic": ic, "t": "%02d:%02d" % [t["hour"], t["minute"]], "c": col})
	if recents.size() > 9:
		recents.pop_back()
	dirty = true


func _connect_call() -> void:
	call_state = "connected"
	call_t = 0.0
	call_player.stop()
	match call_kind:
		"police":
			g.set("police_called", 90.0)
			g._spawn_cop()
			call_msg = T("dispatched")
		"ambulance":
			if money >= 300:
				money -= 300
				heal_t = 6.0
				call_msg = T("onway")
				dirty = true
			else:
				call_msg = T("nomoney")
		"fire":
			call_msg = T("fdispatched")
		"taxi":
			call_msg = T("onway")
			g._phone_app(3)
		"mechanic":
			call_msg = T("onway")
			g._phone_app(1)
		"wrong":
			call_msg = T("wrong")
		_:
			call_msg = T("noanswer")


func _end_call() -> void:
	call_state = ""
	call_player.stop()


func _draw_phone_app(c: Control) -> void:
	if call_state != "":
		_draw_call(c)
		return
	c.draw_rect(Rect2(20, 20, 400, 860), Color(0, 0, 0, 0.55))
	if phone_tab == 0:
		_draw_keypad(c)
	elif phone_tab == 1:
		_draw_recents(c)
	else:
		_draw_contacts(c)
	_tab_bar(c)


func _draw_keypad(c: Control) -> void:
	_t(c, dial if dial != "" else " ", Vector2(220, 175), 40)
	var digs := ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"]
	var lets := ["", "ABC", "DEF", "GHI", "JKL", "MNO", "PQRS", "TUV", "WXYZ", "", "+", ""]
	for i in 12:
		var p := Vector2(110.0 + float(i % 3) * 110.0, 262.0 + float(i / 3) * 86.0)
		c.draw_circle(p, 37.0, Color(0.2, 0.2, 0.22, 0.95))
		var has_l: bool = String(lets[i]) != ""
		_t(c, String(digs[i]), p + Vector2(0, -6 if has_l else 0), 32)
		if has_l:
			_t(c, String(lets[i]), p + Vector2(0, 20), 10, Color(1, 1, 1, 0.7))
		hits.append({"r": Rect2(p - Vector2(40, 40), Vector2(80, 80)), "a": "dial", "v": digs[i]})
	var cp := Vector2(220, 626)
	c.draw_circle(cp, 38.0, Color(0.2, 0.78, 0.35))
	_glyph(c, "phone", cp, 18.0)
	hits.append({"r": Rect2(cp - Vector2(44, 44), Vector2(88, 88)), "a": "dial_call", "v": null})
	if dial != "":
		var bp := Vector2(330, 626)
		c.draw_colored_polygon(PackedVector2Array([bp + Vector2(-16, 0), bp + Vector2(-7, -11), bp + Vector2(15, -11), bp + Vector2(15, 11), bp + Vector2(-7, 11)]), Color(1, 1, 1, 0.75))
		c.draw_line(bp + Vector2(-2, -5), bp + Vector2(8, 5), Color(0.1, 0.1, 0.12), 2.0)
		c.draw_line(bp + Vector2(8, -5), bp + Vector2(-2, 5), Color(0.1, 0.1, 0.12), 2.0)
		hits.append({"r": Rect2(bp - Vector2(34, 34), Vector2(68, 68)), "a": "dial_del", "v": null})


func _draw_recents(c: Control) -> void:
	_title(c, "recents")
	if recents.is_empty():
		_t(c, T("empty"), Vector2(220, 400), 22, Color(1, 1, 1, 0.7))
		return
	var n := mini(recents.size(), 9)
	c.draw_style_box(sbs[8], Rect2(30, 170, 380, float(n) * 58.0))
	for i in n:
		var rc: Dictionary = recents[i]
		var r := Rect2(30, 170 + i * 58, 380, 58)
		_contact_icon(c, r.position + Vector2(36, 29), 19.0, rc["c"], String(rc.get("ic", rc["k"])))
		_t(c, T(String(rc["n"])), r.position + Vector2(68, 20), 18, Color.WHITE, 0)
		_t(c, String(rc["num"]), r.position + Vector2(68, 41), 13, Color(1, 1, 1, 0.55), 0)
		_t(c, String(rc["t"]), r.position + Vector2(366, 29), 15, Color(1, 1, 1, 0.55), 2)
		if i < n - 1:
			c.draw_line(r.position + Vector2(68, 58), r.position + Vector2(380, 58), Color(1, 1, 1, 0.1), 1.0)
		hits.append({"r": r, "a": "redial", "v": i})


func _draw_contacts(c: Control) -> void:
	_title(c, "contacts")
	c.draw_style_box(sbs[8], Rect2(30, 170, 380, float(CONTACTS.size()) * 66.0))
	for i in CONTACTS.size():
		var ct: Dictionary = CONTACTS[i]
		var r := Rect2(30, 170 + i * 66, 380, 66)
		_contact_icon(c, r.position + Vector2(40, 33), 24.0, ct["col"], String(ct["icon"]))
		_t(c, T(String(ct["name"])), r.position + Vector2(78, 24), 19, Color.WHITE, 0)
		_t(c, String(ct["num"]), r.position + Vector2(78, 46), 14, Color(1, 1, 1, 0.55), 0)
		var bp := r.position + Vector2(342, 33)
		c.draw_circle(bp, 18.0, Color(0.2, 0.78, 0.35))
		_glyph(c, "phone", bp, 9.0)
		if i < CONTACTS.size() - 1:
			c.draw_line(r.position + Vector2(78, 66), r.position + Vector2(380, 66), Color(1, 1, 1, 0.1), 1.0)
		hits.append({"r": r, "a": "call_contact", "v": i})


func _draw_call(c: Control) -> void:
	_grad(c, Rect2(20, 20, 400, 860), call_col.darkened(0.55), Color(0.02, 0.02, 0.03))
	var p := Vector2(220, 270)
	if call_state == "ringing":
		for k in 2:
			var rr := 70.0 + fmod(call_t * 40.0 + float(k) * 22.0, 44.0)
			c.draw_arc(p, rr, 0.0, TAU, 40, Color(1, 1, 1, 0.3 - (rr - 70.0) / 44.0 * 0.3), 3.0, true)
	_contact_icon(c, p, 58.0, call_col, call_ic)
	_t(c, T(call_name), Vector2(220, 380), 34)
	_t(c, call_num, Vector2(220, 420), 20, Color(1, 1, 1, 0.65))
	if call_state == "ringing":
		var dots := ".".repeat(1 + int(call_t * 2.0) % 3)
		_t(c, T("calling").trim_suffix("...") + dots, Vector2(220, 465), 22, Color(1, 1, 1, 0.85))
	else:
		_t(c, "00:%02d" % int(call_t), Vector2(220, 465), 22, Color(0.5, 1, 0.6))
		_t(c, call_msg, Vector2(220, 515), 20, Color(1, 0.9, 0.5))
	var ep := Vector2(220, 730)
	c.draw_circle(ep, 40.0, Color(0.95, 0.22, 0.2))
	_t(c, T("end"), ep, 16)
	hits.append({"r": Rect2(ep - Vector2(48, 48), Vector2(96, 96)), "a": "end_call", "v": null})


# ---------------------------------------------------------------- camera app

func _cap_fps() -> float:
	return [12.0, 6.0, 3.0][cam_speed]


func _update_cam_rig() -> void:
	var in_car: bool = g.in_car
	var base: Vector3 = g.car.position if in_car else g.player.position
	var yaw: float = g.cam_yaw
	var pitch: float = -(float(g.cam_pitch) - 0.18) * 1.5
	var fwd := Vector3(-sin(yaw), 0.0, -cos(yaw))
	if cam_front:
		pcam.cull_mask = 0xFFFFF
		var head := base + Vector3(0, 1.65, 0)
		pcam.global_position = head + fwd * 2.3 + Vector3(0, 0.05, 0)
		pcam.look_at(head, Vector3.UP)
		if not in_car and float(g.speed) < 0.5:
			g.model.rotation.y = lerp_angle(g.model.rotation.y, yaw, 0.2)
	else:
		pcam.cull_mask = 0x7FFFF
		var eye := base + Vector3(0, 1.62 if not in_car else 1.35, 0) + fwd * (0.3 if not in_car else 1.2)
		pcam.global_transform = Transform3D(Basis.from_euler(Vector3(pitch, yaw, 0.0)), eye)
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
	c.draw_rect(Rect2(20, 20, 400, 860), Color.BLACK)
	var vr := Rect2(20, 90, 400, 533)
	c.draw_rect(vr, Color(0.03, 0.03, 0.04))
	c.draw_texture_rect_region(sv.get_texture(), vr, Rect2(277.5, 0.0, 405.0, 540.0))
	for k in [1, 2]:
		var fr: float = float(k) / 3.0
		c.draw_line(vr.position + Vector2(vr.size.x * fr, 0), vr.position + Vector2(vr.size.x * fr, vr.size.y), Color(1, 1, 1, 0.2), 1.0)
		c.draw_line(vr.position + Vector2(0, vr.size.y * fr), vr.position + Vector2(vr.size.x, vr.size.y * fr), Color(1, 1, 1, 0.2), 1.0)
	if recording:
		var secs := float(rec_frames) / _cap_fps()
		c.draw_style_box(_sq(Color(0.9, 0.15, 0.15), 14, false), Rect2(170, vr.position.y + 10, 80, 28))
		_t(c, "%02d:%02d" % [int(secs) / 60, int(secs) % 60], Vector2(210, vr.position.y + 24), 15)
	if flash_t > 0.0:
		c.draw_rect(vr, Color(1, 1, 1, flash_t))
	var zy := vr.end.y - 36.0
	c.draw_style_box(_sq(Color(0, 0, 0, 0.45), 17, false), Rect2(150, zy - 17, 140, 34))
	_t(c, "-", Vector2(172, zy), 24)
	_t(c, "%.1fx" % cam_zoom, Vector2(220, zy), 16, Color(1, 0.84, 0.1))
	_t(c, "+", Vector2(268, zy), 24)
	hits.append({"r": Rect2(150, zy - 17, 44, 34), "a": "cam_zoom", "v": -0.5})
	hits.append({"r": Rect2(246, zy - 17, 44, 34), "a": "cam_zoom", "v": 0.5})
	var yel := Color(1, 0.84, 0.1)
	var dim := Color(1, 1, 1, 0.7)
	_t(c, T("video"), Vector2(160, 652), 16, yel if cam_mode == 1 else dim)
	_t(c, T("photo"), Vector2(280, 652), 16, yel if cam_mode == 0 else dim)
	hits.append({"r": Rect2(110, 636, 100, 34), "a": "cam_mode", "v": 1})
	hits.append({"r": Rect2(230, 636, 100, 34), "a": "cam_mode", "v": 0})
	if cam_mode == 1:
		var keys := ["slow", "normal", "fast"]
		for i in 3:
			var cr := Rect2(58 + i * 112, 674, 100, 28)
			c.draw_style_box(_sq(Color(1, 0.84, 0.1, 0.9) if cam_speed == i else Color(1, 1, 1, 0.15), 14, false), cr)
			_t(c, T(String(keys[i])), cr.position + cr.size * 0.5, 13, Color(0.1, 0.1, 0.1) if cam_speed == i else Color.WHITE)
			hits.append({"r": cr, "a": "cam_speed", "v": i})
	var sc := Vector2(220, 752)
	c.draw_arc(sc, 40.0, 0.0, TAU, 40, Color.WHITE, 4.0, true)
	if cam_mode == 1:
		if recording:
			c.draw_style_box(_sq(Color(0.95, 0.15, 0.15), 6, false), Rect2(sc - Vector2(15, 15), Vector2(30, 30)))
		else:
			c.draw_circle(sc, 32.0, Color(0.95, 0.15, 0.15))
	else:
		c.draw_circle(sc, 32.0, Color.WHITE)
	hits.append({"r": Rect2(sc - Vector2(46, 46), Vector2(92, 92)), "a": "shutter", "v": null})
	var tr := Rect2(36, 726, 52, 52)
	c.draw_style_box(_sq(Color(0.15, 0.15, 0.17), 10, false), tr)
	if last_thumb != null:
		c.draw_texture_rect_region(last_thumb, tr, Rect2(27, 0, 70, 70))
	c.draw_rect(tr, Color(1, 1, 1, 0.6), false, 1.5)
	hits.append({"r": tr, "a": "to_gallery", "v": null})
	var fp := Vector2(378, 752)
	c.draw_circle(fp, 26.0, Color(0.25, 0.25, 0.28, 0.9))
	c.draw_arc(fp, 10.0, deg_to_rad(200), deg_to_rad(340), 12, Color.WHITE, 2.5, true)
	c.draw_arc(fp, 10.0, deg_to_rad(20), deg_to_rad(160), 12, Color.WHITE, 2.5, true)
	c.draw_circle(fp + Vector2(cos(deg_to_rad(340)), sin(deg_to_rad(340))) * 10.0, 3.0, Color.WHITE)
	c.draw_circle(fp + Vector2(cos(deg_to_rad(160)), sin(deg_to_rad(160))) * 10.0, 3.0, Color.WHITE)
	hits.append({"r": Rect2(fp - Vector2(30, 30), Vector2(60, 60)), "a": "cam_flip", "v": null})


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
	gal_page = clampi(gal_page, 0, maxi((gal.size() - 1) / 24, 0))
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
	if page == "edit":
		c.draw_rect(Rect2(20, 20, 400, 860), Color.BLACK)
		_back_btn(c, T("back"))
		_draw_edit(c)
		return
	if page == "view":
		_draw_view(c)
		return
	_title(c, "pickwp" if pick_mode else "photos")
	if pick_mode:
		_back_btn(c, T("settings"))
	if gal.is_empty():
		_t(c, T("empty"), Vector2(220, 420), 24, Color(1, 1, 1, 0.7))
		return
	var per := 24
	var pages := maxi((gal.size() - 1) / per + 1, 1)
	gal_page = clampi(gal_page, 0, pages - 1)
	for k in per:
		var idx := gal_page * per + k
		if idx >= gal.size():
			break
		var r := Rect2(21 + (k % 4) * 100, 170 + (k / 4) * 100, 98, 98)
		c.draw_rect(r, Color(0.1, 0.1, 0.12))
		var tex := _thumb(gal[idx])
		if tex != null:
			c.draw_texture_rect_region(tex, r, Rect2(27, 0, 70, 70))
		if gal[idx]["t"] == "c":
			var b := r.position + Vector2(14, 84)
			c.draw_colored_polygon(PackedVector2Array([b + Vector2(-5, -6), b + Vector2(-5, 6), b + Vector2(6, 0)]), Color.WHITE)
		hits.append({"r": r, "a": "view", "v": idx})
	if pages > 1:
		c.draw_rect(Rect2(20, 782, 400, 72), Color(0.09, 0.09, 0.1, 0.97))
		_btn(c, Rect2(50, 792, 90, 40), "<", "gal_prev", null, 0, 24)
		_t(c, "%d / %d" % [gal_page + 1, pages], Vector2(220, 812), 18)
		_btn(c, Rect2(300, 792, 90, 40), ">", "gal_next", null, 0, 24)


func _draw_view(c: Control) -> void:
	c.draw_rect(Rect2(20, 20, 400, 860), Color.BLACK)
	_back_btn(c, T("photos"))
	var r := Rect2(20, 300, 400, 225)
	c.draw_rect(r, Color(0.05, 0.05, 0.06))
	if view_tex != null:
		c.draw_texture_rect(view_tex, r, false)
	var is_clip: bool = view_i >= 0 and view_i < gal.size() and gal[view_i]["t"] == "c"
	for sd in [0, 1]:
		var cp := Vector2(46.0 + float(sd) * 348.0, 412)
		c.draw_circle(cp, 20.0, Color(0, 0, 0, 0.5))
		_t(c, "<" if sd == 0 else ">", cp, 22)
		hits.append({"r": Rect2(cp - Vector2(26, 40), Vector2(52, 80)), "a": "v_prev" if sd == 0 else "v_next", "v": null})
	c.draw_rect(Rect2(20, 782, 400, 72), Color(0.09, 0.09, 0.1, 0.97))
	var blue := Color(0.25, 0.6, 1.0)
	if is_clip:
		c.draw_circle(Vector2(220, 590), 30.0, Color(1, 1, 1, 0.15))
		_t(c, "||" if clip_play else ">", Vector2(220, 590), 24)
		hits.append({"r": Rect2(184, 554, 72, 72), "a": "clip_play", "v": null})
		var sp := [0.5, 1.0, 2.0]
		for i in 3:
			var cr := Rect2(58 + i * 112, 650, 100, 30)
			c.draw_style_box(_sq(Color(0.25, 0.6, 1.0, 0.9) if is_equal_approx(clip_speed, sp[i]) else Color(1, 1, 1, 0.15), 15, false), cr)
			_t(c, "%sx" % str(sp[i]), cr.position + cr.size * 0.5, 15)
			hits.append({"r": cr, "a": "clip_speed", "v": sp[i]})
		_t(c, T("delete"), Vector2(220, 816), 17, Color(1, 0.3, 0.3))
		hits.append({"r": Rect2(140, 790, 160, 44), "a": "v_del", "v": null})
	else:
		_t(c, T("edit"), Vector2(100, 816), 17, blue)
		_t(c, T("setwp"), Vector2(220, 816), 17, blue)
		_t(c, T("delete"), Vector2(340, 816), 17, Color(1, 0.3, 0.3))
		hits.append({"r": Rect2(40, 790, 120, 44), "a": "v_edit", "v": null})
		hits.append({"r": Rect2(160, 790, 120, 44), "a": "v_wall", "v": null})
		hits.append({"r": Rect2(280, 790, 120, 44), "a": "v_del", "v": null})


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
		for cc in CARS:
			out.append({"k": "car", "id": cc["id"], "name": cc["name"], "price": cc["price"], "color": cc["color"], "spd": cc["spd"], "acc": cc["acc"], "hnd": cc["hnd"]})
	elif store_tab == 1:
		for i in AMMO.size():
			out.append({"k": "ammo", "idx": i, "name": AMMO[i]["name"], "price": AMMO[i]["price"], "n": AMMO[i]["n"], "color": Color(0.95, 0.7, 0.2)})
	elif store_tab == 2:
		out.append({"k": "heli", "id": "heli", "name": "HELICOPTER", "price": 90000, "color": Color(0.3, 0.5, 0.95)})
	else:
		for s in SOON_APPS:
			out.append({"k": "soon", "name": s, "price": 0, "color": Color(0.5, 0.5, 0.6)})
	return out


func _stat(c: Control, p: Vector2, label: String, val: float) -> void:
	_t(c, label, p, 10, Color(1, 1, 1, 0.6), 0)
	c.draw_rect(Rect2(p.x + 30, p.y - 3, 84, 6), Color(1, 1, 1, 0.15))
	c.draw_rect(Rect2(p.x + 30, p.y - 3, 84.0 * clampf(val, 0.0, 1.0), 6), Color(0.35, 0.8, 1.0))


func _draw_store(c: Control) -> void:
	_title(c, "store")
	var rtl := lang == "ar"
	var mp := Rect2(30.0 if rtl else 298.0, 106, 112, 36)
	c.draw_style_box(sbs[4], mp)
	_t(c, _fmt(money), mp.position + mp.size * 0.5, 16 if money < 100000000 else 12, Color(1, 0.85, 0.3))
	var keys := ["cars", "ammo", "air", "apps"]
	c.draw_style_box(_sq(Color(0.45, 0.45, 0.5, 0.35), 9, false), Rect2(30, 160, 380, 36))
	for i in 4:
		var sr := Rect2(32.0 + float(i) * 94.5, 162, 94, 32)
		if store_tab == i:
			c.draw_style_box(_sq(Color(0.6, 0.6, 0.66, 0.95), 7, false), sr)
		_t(c, T(String(keys[i])), sr.position + sr.size * 0.5, 14)
		hits.append({"r": sr, "a": "store_tab", "v": i})
	var items := _store_items()
	var per := 4
	var pages := maxi((items.size() - 1) / per + 1, 1)
	store_page = clampi(store_page, 0, pages - 1)
	for k in per:
		var idx := store_page * per + k
		if idx >= items.size():
			break
		var it: Dictionary = items[idx]
		var r2 := Rect2(30, 208 + k * 118, 380, 112)
		var col: Color = it["color"]
		var kind := String(it["k"])
		var ic := Rect2(r2.position + Vector2(6, 16), Vector2(80, 80))
		_rr_grad(c, ic, 18.0, col.lightened(0.25), col.darkened(0.35))
		g._icon(c, "guns" if kind == "ammo" else "car", ic.position + ic.size * 0.5, 20.0)
		_t(c, String(it["name"]), r2.position + Vector2(100, 28), 18, Color.WHITE, 0)
		c.draw_line(Vector2(30, r2.end.y + 3), Vector2(410, r2.end.y + 3), Color(1, 1, 1, 0.1), 1.0)
		var br := Rect2(r2.end.x - 104, r2.position.y + 40, 96, 34)
		if kind == "soon":
			_capsule(c, br, T("soon"), "", null, 2, false)
			continue
		if kind == "car":
			_stat(c, r2.position + Vector2(100, 52), "SPD", float(it["spd"]))
			_stat(c, r2.position + Vector2(100, 66), "ACC", float(it["acc"]))
			_stat(c, r2.position + Vector2(100, 80), "HND", float(it["hnd"]))
		if kind == "ammo":
			_t(c, "+%d" % int(it["n"]), r2.position + Vector2(100, 60), 22, Color(1, 0.85, 0.3), 0)
		if kind == "heli":
			_t(c, T("flysoon"), r2.position + Vector2(100, 60), 12, Color(1, 1, 1, 0.55), 0)
		var price := int(it["price"])
		var can := money >= price
		var plabel := "FREE" if price == 0 else _fmt(price)
		if kind == "ammo":
			_capsule(c, br, plabel, "buy_ammo", int(it["idx"]), 0, can)
		elif kind == "heli":
			if bool(owned.get("heli", false)):
				_capsule(c, br, T("owned"), "", null, 2, false)
			else:
				_capsule(c, br, plabel, "buy_heli", null, 0, can)
		else:
			var id := String(it["id"])
			if bool(owned.get(id, false)):
				if car_sel == id:
					_capsule(c, br, T("selected"), "", null, 2, false)
				else:
					_capsule(c, br, T("select"), "sel_car", id, 1, true)
			else:
				_capsule(c, br, plabel, "buy_car", id, 0, can)
	if pages > 1:
		_btn(c, Rect2(60, 712, 100, 38), "<", "store_prev", null, 0, 22)
		_t(c, "%d / %d" % [store_page + 1, pages], Vector2(220, 731), 18)
		_btn(c, Rect2(280, 712, 100, 38), ">", "store_next", null, 0, 22)


# ---------------------------------------------------------------- settings app

func _draw_settings(c: Control) -> void:
	if page == "lang":
		_back_btn(c, T("settings"))
		_title(c, "language")
		c.draw_style_box(sbs[8], Rect2(30, 176, 380, 250))
		for i in LANGS.size():
			var y := 176.0 + float(i) * 50.0
			_t(c, String(LANG_NAMES[i]), Vector2(50, y + 25), 18, Color.WHITE, 0)
			if lang == LANGS[i]:
				c.draw_polyline(PackedVector2Array([Vector2(380, y + 26), Vector2(386, y + 33), Vector2(398, y + 17)]), Color(0.25, 0.6, 1.0), 3.0, true)
			if i < LANGS.size() - 1:
				c.draw_line(Vector2(50, y + 50), Vector2(410, y + 50), Color(1, 1, 1, 0.1), 1.0)
			hits.append({"r": Rect2(30, y, 380, 50), "a": "set_lang", "v": LANGS[i]})
		return
	if page == "wall":
		_back_btn(c, T("settings"))
		_title(c, "wallpaper")
		for i in WALLS.size():
			var r2 := Rect2(36.0 + float(i) * 74.0, 176, 66, 120)
			var w: Array = WALLS[i]
			_rr_grad(c, r2, 12.0, w[0], w[1])
			var pts := _rr_pts(r2, 12.0)
			pts.append(pts[0])
			c.draw_polyline(pts, Color(1, 1, 1, 0.95 if wall_idx == i else 0.25), 3.0 if wall_idx == i else 1.5, true)
			hits.append({"r": r2, "a": "set_wall", "v": i})
		c.draw_style_box(sbs[8], Rect2(30, 320, 380, 50))
		_t(c, T("photos"), Vector2(50, 345), 18, Color.WHITE, 0)
		_chev(c, 396, 345)
		hits.append({"r": Rect2(30, 320, 380, 50), "a": "wall_photo", "v": null})
		return
	_title(c, "settings")
	var li := maxi(LANGS.find(lang), 0)
	c.draw_style_box(sbs[8], Rect2(30, 176, 380, 100))
	_set_row(c, 176, Color(0.04, 0.52, 1.0), "globe", T("language"), String(LANG_NAMES[li]), "page_set", "lang")
	c.draw_line(Vector2(80, 226), Vector2(410, 226), Color(1, 1, 1, 0.1), 1.0)
	_set_row(c, 226, Color(0.35, 0.34, 0.84), "wall", T("wallpaper"), "", "page_set", "wall")
	c.draw_style_box(sbs[8], Rect2(30, 296, 380, 100))
	_set_icon(c, Vector2(56, 321), Color(0.55, 0.55, 0.6), "shadow")
	_t(c, T("shadows"), Vector2(80, 321), 18, Color.WHITE, 0)
	_switch(c, 372, 321, shadows)
	hits.append({"r": Rect2(30, 296, 380, 50), "a": "toggle_shadows", "v": null})
	c.draw_line(Vector2(80, 346), Vector2(410, 346), Color(1, 1, 1, 0.1), 1.0)
	_set_icon(c, Vector2(56, 371), Color(0.2, 0.7, 0.4), "fps")
	_t(c, T("fps"), Vector2(80, 371), 18, Color.WHITE, 0)
	_switch(c, 372, 371, show_fps)
	hits.append({"r": Rect2(30, 346, 380, 50), "a": "toggle_fps", "v": null})
	c.draw_style_box(sbs[8], Rect2(30, 416, 380, 130))
	_slider_row(c, 416, Color(0.95, 0.3, 0.35), "vol", T("volume"), "%d%%" % int(volume * 100.0), volume, "vol_set")
	c.draw_line(Vector2(80, 481), Vector2(410, 481), Color(1, 1, 1, 0.1), 1.0)
	var sr := (float(g.phone_scale) - 0.5) / 0.55
	_slider_row(c, 481, Color(0.55, 0.55, 0.6), "size", T("phonesize"), "%d%%" % int(float(g.phone_scale) * 100.0), sr, "size_set")


# ---------------------------------------------------------------- glyphs and round icons

func _glyph(c: Control, kind: String, p: Vector2, u: float) -> void:
	var w := Color(1, 1, 1, 0.97)
	match kind:
		"pin":
			c.draw_circle(p + Vector2(0, -u * 0.35), u * 0.62, w)
			c.draw_colored_polygon(PackedVector2Array([p + Vector2(-u * 0.5, -u * 0.1), p + Vector2(u * 0.5, -u * 0.1), p + Vector2(0, u * 0.95)]), w)
			c.draw_circle(p + Vector2(0, -u * 0.35), u * 0.25, Color(0.1, 0.5, 0.3))
		"car":
			g._icon(c, "car", p, u * 0.95)
		"gun":
			g._icon(c, "guns", p, u * 0.9)
		"taxi":
			g._icon(c, "car", p + Vector2(0, u * 0.15), u * 0.95)
			c.draw_rect(Rect2(p + Vector2(-0.3, -1.0) * u, Vector2(0.6, 0.28) * u), w)
		"clock":
			c.draw_arc(p, u * 0.95, 0.0, TAU, 32, w, u * 0.16, true)
			c.draw_line(p, p + Vector2(0, -u * 0.6), w, u * 0.14)
			c.draw_line(p, p + Vector2(u * 0.45, u * 0.2), w, u * 0.14)
		"bag":
			c.draw_rect(Rect2(p + Vector2(-0.8, -0.3) * u, Vector2(1.6, 1.3) * u), w)
			c.draw_arc(p + Vector2(0, -0.3 * u), u * 0.45, PI, TAU, 16, w, u * 0.16, true)
		"phone":
			c.draw_arc(p + Vector2(0, u * 0.35), u * 0.78, deg_to_rad(205), deg_to_rad(335), 20, w, u * 0.42, true)
			c.draw_circle(p + Vector2(-u * 0.72, u * 0.22), u * 0.3, w)
			c.draw_circle(p + Vector2(u * 0.72, u * 0.22), u * 0.3, w)
		"camera":
			c.draw_rect(Rect2(p + Vector2(-1.0, -0.55) * u, Vector2(2.0, 1.4) * u), w)
			c.draw_rect(Rect2(p + Vector2(-0.4, -0.85) * u, Vector2(0.8, 0.35) * u), w)
			c.draw_circle(p + Vector2(0, 0.15 * u), u * 0.5, Color(0.25, 0.28, 0.35))
			c.draw_circle(p + Vector2(0, 0.15 * u), u * 0.28, Color(0.75, 0.85, 1.0))
		"photo":
			c.draw_rect(Rect2(p + Vector2(-1.0, -0.8) * u, Vector2(2.0, 1.6) * u), w)
			c.draw_colored_polygon(PackedVector2Array([p + Vector2(-0.9, 0.7) * u, p + Vector2(-0.2, -0.2) * u, p + Vector2(0.25, 0.4) * u, p + Vector2(0.55, 0.0) * u, p + Vector2(0.9, 0.7) * u]), Color(0.85, 0.3, 0.5))
			c.draw_circle(p + Vector2(0.45, -0.4) * u, u * 0.2, Color(1, 0.8, 0.3))
		"gear":
			c.draw_arc(p, u * 0.55, 0.0, TAU, 24, w, u * 0.3, true)
			for k in 8:
				var a := float(k) * TAU / 8.0
				c.draw_line(p + Vector2(cos(a), sin(a)) * u * 0.7, p + Vector2(cos(a), sin(a)) * u * 1.0, w, u * 0.3)
		"chat":
			c.draw_circle(p + Vector2(0, -u * 0.1), u * 0.85, w)
			c.draw_colored_polygon(PackedVector2Array([p + Vector2(-0.5, 0.4) * u, p + Vector2(-0.8, 1.0) * u, p + Vector2(0.0, 0.7) * u]), w)
			for k in 3:
				c.draw_circle(p + Vector2((float(k) - 1.0) * 0.4, -0.1) * u, u * 0.1, Color(0.2, 0.5, 0.9))
		"game":
			c.draw_rect(Rect2(p + Vector2(-1.1, -0.5) * u, Vector2(2.2, 1.1) * u), w)
			c.draw_circle(p + Vector2(-0.6, 0.05) * u, u * 0.22, Color(0.7, 0.2, 0.3))
			c.draw_circle(p + Vector2(0.55, -0.1) * u, u * 0.14, Color(0.7, 0.2, 0.3))
			c.draw_circle(p + Vector2(0.8, 0.2) * u, u * 0.14, Color(0.7, 0.2, 0.3))


func _icon_tex(key: String) -> Texture2D:
	if icon_tex.has(key):
		return icon_tex[key]
	var p := "%s%s.png" % [ICON_DIR, key]
	var t: Texture2D = null
	if ResourceLoader.exists(p):
		t = load(p) as Texture2D
	icon_tex[key] = t
	return t


# ---------------------------------------------------------------- drawing entry points

func draw_home(c: Control) -> void:
	hits.clear()
	var t := Time.get_time_dict_from_system()
	_t(c, "%02d:%02d" % [t["hour"], t["minute"]], Vector2(220, 175), 72)
	var dt := Time.get_date_dict_from_system()
	_t(c, "%04d-%02d-%02d" % [dt["year"], dt["month"], dt["day"]], Vector2(220, 235), 20, Color(1, 1, 1, 0.75))
	for sgn in [0, 1]:
		var cc := Vector2(78.0 + float(sgn) * 284.0, 175.0)
		c.draw_circle(cc, 20.0, Color(1, 1, 1, 0.12))
		c.draw_arc(cc, 20.0, 0.0, TAU, 20, Color(1, 1, 1, 0.55), 2.0, true)
		_t(c, "+" if sgn == 1 else "-", cc, 26, Color(1, 1, 1, 0.85))
		hits.append({"r": Rect2(cc - Vector2(24, 24), Vector2(48, 48)), "a": "zoom", "v": 0.08 if sgn == 1 else -0.08})
	for i in HOME_GRID.size():
		var it: Dictionary = HOME_GRID[i]
		var p := Vector2(84.0 + float(i % 4) * 91.0, 330.0 + float(i / 4) * 118.0)
		_app_icon(c, p, 64.0, it, T(String(it["key"])), int(it["app"]) >= 10, true)
	c.draw_style_box(sbs[7], Rect2(28, 748, 384, 98))
	for i in HOME_DOCK.size():
		var it2: Dictionary = HOME_DOCK[i]
		_app_icon(c, Vector2(84.0 + float(i) * 91.0, 797.0), 64.0, it2, "", false, false)


func draw_bg(c: Control) -> void:
	# الخلفية تملأ الشاشة كلها (الأركان المدورة تغطيها إطار الهاتف)
	var r := Rect2(20, 20, 400, 860)
	if wall_tex != null:
		var ts := wall_tex.get_size()
		var want := r.size.x / r.size.y
		var sw := ts.y * want
		c.draw_texture_rect_region(wall_tex, r, Rect2((ts.x - sw) * 0.5, 0.0, sw, ts.y))
		c.draw_rect(r, Color(0, 0, 0, 0.22))
	else:
		var w: Array = WALLS[clampi(wall_idx, 0, WALLS.size() - 1)]
		_grad(c, r, w[0], w[1])
	if app != -1:
		c.draw_rect(r, Color(0, 0, 0, 0.8))


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
		9:
			_draw_phone_app(c)


func draw_hud(ui: Control) -> void:
	var mt := _fmt(money)
	_t(ui, mt, Vector2(30, 205), 30, Color(1, 0.85, 0.3), 0)
	if gain_t > 0.0:
		_t(ui, gain_txt, Vector2(30, 240), 24, Color(0.5, 1, 0.5, clampf(gain_t, 0.0, 1.0)), 0)
	if show_fps:
		_t(ui, "%d FPS" % Engine.get_frames_per_second(), Vector2(30, 280), 22, Color(1, 1, 1, 0.8), 0)
	if ringing > 0.0:
		_t(ui, ring_msg, Vector2(g._vp().x * 0.5, 130), 40, Color(1, 0.4, 0.3))


# ---------------------------------------------------------------- iOS style helpers

func _rr_pts(r: Rect2, rad: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var cs := [Vector2(r.end.x - rad, r.position.y + rad), Vector2(r.end.x - rad, r.end.y - rad), Vector2(r.position.x + rad, r.end.y - rad), Vector2(r.position.x + rad, r.position.y + rad)]
	var a0 := [-90.0, 0.0, 90.0, 180.0]
	for k in 4:
		for s in 7:
			var a := deg_to_rad(float(a0[k]) + float(s) * 15.0)
			pts.append(Vector2(cs[k]) + Vector2(cos(a), sin(a)) * rad)
	return pts


func _rr_grad(c: Control, r: Rect2, rad: float, top: Color, bot: Color) -> void:
	var pts := _rr_pts(r, rad)
	var cols := PackedColorArray()
	for p in pts:
		cols.append(top.lerp(bot, clampf((p.y - r.position.y) / r.size.y, 0.0, 1.0)))
	c.draw_polygon(pts, cols)


func _chev(c: Control, x: float, y: float) -> void:
	c.draw_polyline(PackedVector2Array([Vector2(x - 4, y - 8), Vector2(x + 4, y), Vector2(x - 4, y + 8)]), Color(1, 1, 1, 0.35), 2.5, true)


func _back_btn(c: Control, label: String) -> void:
	var blue := Color(0.25, 0.6, 1.0)
	c.draw_polyline(PackedVector2Array([Vector2(46, 90), Vector2(37, 99), Vector2(46, 108)]), blue, 3.0, true)
	_t(c, label, Vector2(56, 99), 18, blue, 0)
	hits.append({"r": Rect2(24, 84, 160, 34), "a": "back_page", "v": null})


func _switch(c: Control, x: float, y: float, on: bool) -> void:
	var r := Rect2(x - 25.0, y - 15.0, 50, 30)
	c.draw_style_box(_sq(Color(0.2, 0.78, 0.35) if on else Color(0.38, 0.38, 0.42), 15, false), r)
	c.draw_circle(Vector2(x + (10.0 if on else -10.0), y), 12.0, Color.WHITE)


func _capsule(c: Control, r: Rect2, label: String, act: String, val, style: int, enabled: bool) -> void:
	var bg := Color(0.3, 0.3, 0.34, 0.95)
	var tc := Color(0.25, 0.6, 1.0)
	if style == 1:
		bg = Color(0.04, 0.52, 1.0)
		tc = Color.WHITE
	elif style == 2:
		bg = Color(0.3, 0.3, 0.34, 0.6)
		tc = Color(1, 1, 1, 0.5)
	if not enabled:
		tc = Color(1, 1, 1, 0.4)
	c.draw_style_box(_sq(bg, 17, false), r)
	_t(c, label, r.position + r.size * 0.5, 14, tc)
	if style != 2:
		hits.append({"r": r, "a": act, "v": val})


func _set_icon(c: Control, p: Vector2, col: Color, kind: String) -> void:
	_rr_grad(c, Rect2(p - Vector2(15, 15), Vector2(30, 30)), 7.0, col.lightened(0.15), col.darkened(0.1))
	var w := Color.WHITE
	match kind:
		"globe":
			c.draw_arc(p, 8.0, 0.0, TAU, 20, w, 1.6, true)
			c.draw_line(p + Vector2(-8, 0), p + Vector2(8, 0), w, 1.4)
			c.draw_line(p + Vector2(0, -8), p + Vector2(0, 8), w, 1.4)
		"wall":
			c.draw_circle(p + Vector2(-3, -4), 3.0, w)
			c.draw_colored_polygon(PackedVector2Array([p + Vector2(-9, 8), p + Vector2(-2, -1), p + Vector2(3, 5), p + Vector2(6, 2), p + Vector2(9, 8)]), w)
		"shadow":
			c.draw_circle(p, 8.0, w)
			c.draw_circle(p + Vector2(4, -2), 7.0, col.darkened(0.1))
		"fps":
			_t(c, "60", p, 12, w)
		"vol":
			c.draw_rect(Rect2(p + Vector2(-8, -3), Vector2(5, 6)), w)
			c.draw_colored_polygon(PackedVector2Array([p + Vector2(-3, -3), p + Vector2(3, -8), p + Vector2(3, 8), p + Vector2(-3, 3)]), w)
			c.draw_arc(p + Vector2(3, 0), 6.0, deg_to_rad(-50), deg_to_rad(50), 8, w, 1.5, true)
		"size":
			c.draw_rect(Rect2(p + Vector2(-7, -11), Vector2(14, 22)), w, false, 2.0)
			c.draw_circle(p + Vector2(0, 7), 1.5, w)


func _set_row(c: Control, y: float, col: Color, kind: String, label: String, value: String, act: String, val) -> void:
	_set_icon(c, Vector2(56, y + 25), col, kind)
	_t(c, label, Vector2(80, y + 25), 18, Color.WHITE, 0)
	if value != "":
		_t(c, value, Vector2(372, y + 25), 16, Color(1, 1, 1, 0.5), 2)
	_chev(c, 396, y + 25)
	hits.append({"r": Rect2(30, y, 380, 50), "a": act, "v": val})


func _slider_row(c: Control, y: float, col: Color, kind: String, label: String, vtxt: String, ratio: float, act: String) -> void:
	_set_icon(c, Vector2(56, y + 24), col, kind)
	_t(c, label, Vector2(80, y + 24), 18, Color.WHITE, 0)
	_t(c, vtxt, Vector2(396, y + 24), 16, Color(1, 1, 1, 0.5), 2)
	var rr := clampf(ratio, 0.0, 1.0)
	c.draw_style_box(_sq(Color(1, 1, 1, 0.18), 3, false), Rect2(50, y + 48, 340, 6))
	c.draw_style_box(_sq(Color(0.25, 0.6, 1.0), 3, false), Rect2(50, y + 48, maxf(340.0 * rr, 6.0), 6))
	c.draw_circle(Vector2(50.0 + 340.0 * rr, y + 51.0), 11.0, Color.WHITE)
	hits.append({"r": Rect2(40, y + 34, 360, 34), "a": act, "v": 0.0, "s": Vector2(50, 340)})


func _app_icon(c: Control, p: Vector2, sz: float, it: Dictionary, label: String, dim: bool, show_label: bool) -> void:
	var half := sz * 0.5
	var r := Rect2(p - Vector2(half, half), Vector2(sz, sz))
	var rad := sz * 0.225
	var key := String(it["key"])
	c.draw_style_box(_sq(Color(0, 0, 0, 0.35), int(rad), false), Rect2(r.position + Vector2(0, 4), r.size))
	var tex := _icon_tex(key)
	if tex != null:
		c.draw_texture_rect(tex, r, false)
	else:
		_rr_grad(c, r, rad, it["c1"], it["c2"])
		_ios_glyph(c, key, p, half)
		var pts := _rr_pts(r, rad)
		pts.append(pts[0])
		c.draw_polyline(pts, Color(1, 1, 1, 0.22), 1.5, true)
	if dim:
		c.draw_style_box(_sq(Color(0, 0, 0, 0.45), int(rad), false), r)
	var h := sz + 16.0
	if show_label:
		_t(c, label, p + Vector2(0, half + 17.0), 16, Color(1, 1, 1, 0.55 if dim else 0.95))
		h += 22.0
	hits.append({"r": Rect2(p - Vector2(half + 8.0, half + 8.0), Vector2(sz + 16.0, h)), "a": "open", "v": int(it["app"])})


func _ios_glyph(c: Control, key: String, p: Vector2, u: float) -> void:
	match key:
		"phone":
			_glyph(c, "phone", p, u * 0.55)
		"camera":
			var d := Color(0.16, 0.17, 0.2)
			c.draw_style_box(_sq(d, int(u * 0.14), false), Rect2(p + Vector2(-0.62, -0.34) * u, Vector2(1.24, 0.82) * u))
			c.draw_rect(Rect2(p + Vector2(-0.25, -0.5) * u, Vector2(0.5, 0.2) * u), d)
			c.draw_circle(p + Vector2(0, 0.07) * u, u * 0.3, Color(0.82, 0.83, 0.87))
			c.draw_circle(p + Vector2(0, 0.07) * u, u * 0.2, Color(0.1, 0.12, 0.2))
			c.draw_circle(p + Vector2(0.42, -0.15) * u, u * 0.05, Color(1, 0.8, 0.2))
		"photos":
			var cols := [Color(1, 0.62, 0.1), Color(1, 0.85, 0.1), Color(0.5, 0.85, 0.2), Color(0.1, 0.78, 0.5), Color(0.1, 0.6, 1), Color(0.4, 0.4, 1), Color(0.75, 0.3, 0.9), Color(1, 0.3, 0.45)]
			for k in 8:
				var a := float(k) * TAU / 8.0 - PI * 0.5
				var col: Color = cols[k]
				col.a = 0.85
				c.draw_circle(p + Vector2(cos(a), sin(a)) * u * 0.38, u * 0.36, col)
		"settings":
			var d2 := Color(0.25, 0.26, 0.3)
			var gu := u * 0.62
			for k in 8:
				var a2 := float(k) * TAU / 8.0
				c.draw_line(p + Vector2(cos(a2), sin(a2)) * gu * 0.7, p + Vector2(cos(a2), sin(a2)) * gu * 1.0, d2, gu * 0.3)
			c.draw_arc(p, gu * 0.55, 0.0, TAU, 24, d2, gu * 0.3, true)
		"map":
			c.draw_line(p + Vector2(-0.8, 0.6) * u, p + Vector2(0.8, -0.5) * u, Color(1, 1, 1, 0.95), u * 0.28)
			c.draw_line(p + Vector2(-0.5, -0.8) * u, p + Vector2(0.4, 0.8) * u, Color(1, 0.85, 0.3, 0.95), u * 0.2)
			c.draw_colored_polygon(PackedVector2Array([p + Vector2(-0.3, -0.05) * u, p + Vector2(0.3, -0.05) * u, p + Vector2(0, 0.6) * u]), Color(0.95, 0.2, 0.2))
			c.draw_circle(p + Vector2(0, -0.2) * u, u * 0.34, Color(0.95, 0.2, 0.2))
			c.draw_circle(p + Vector2(0, -0.2) * u, u * 0.13, Color.WHITE)
		"mycar":
			g._icon(c, "car", p, u * 0.5)
		"guns":
			g._icon(c, "guns", p, u * 0.5)
		"taxi":
			_glyph(c, "taxi", p, u * 0.55)
		"clk":
			var t := Time.get_time_dict_from_system()
			var dk := Color(0.1, 0.1, 0.12)
			c.draw_circle(p, u * 0.8, Color.WHITE)
			for k in 12:
				var a3 := float(k) * TAU / 12.0
				var dv := Vector2(sin(a3), -cos(a3))
				c.draw_line(p + dv * u * 0.66, p + dv * u * 0.74, dk, 1.5)
			var ha := (float(int(t["hour"]) % 12) + float(t["minute"]) / 60.0) / 12.0 * TAU
			var ma := float(t["minute"]) / 60.0 * TAU
			var sa := float(t["second"]) / 60.0 * TAU
			c.draw_line(p, p + Vector2(sin(ha), -cos(ha)) * u * 0.42, dk, 2.5)
			c.draw_line(p, p + Vector2(sin(ma), -cos(ma)) * u * 0.62, dk, 2.0)
			c.draw_line(p, p + Vector2(sin(sa), -cos(sa)) * u * 0.66, Color(1, 0.55, 0.1), 1.2)
		"store":
			var w := Color.WHITE
			c.draw_line(p + Vector2(0, -0.55) * u, p + Vector2(-0.5, 0.55) * u, w, u * 0.18)
			c.draw_line(p + Vector2(0, -0.55) * u, p + Vector2(0.5, 0.55) * u, w, u * 0.18)
			c.draw_line(p + Vector2(-0.3, 0.2) * u, p + Vector2(0.3, 0.2) * u, w, u * 0.16)
		"chirp":
			_glyph(c, "chat", p, u * 0.55)
		"racer":
			_glyph(c, "game", p, u * 0.55)


func _tab_bar(c: Control) -> void:
	c.draw_rect(Rect2(20, 780, 400, 74), Color(0.09, 0.09, 0.1, 0.97))
	c.draw_line(Vector2(20, 780), Vector2(420, 780), Color(1, 1, 1, 0.12), 1.0)
	var order := [1, 2, 0]
	var keys := ["recents", "contacts", "keypad"]
	for j in 3:
		var tab: int = order[j]
		var cx := 20.0 + 66.7 + float(j) * 133.3
		var col := Color(0.25, 0.6, 1.0) if phone_tab == tab else Color(0.6, 0.6, 0.64)
		var p := Vector2(cx, 802)
		if tab == 1:
			c.draw_arc(p, 10.0, 0.0, TAU, 20, col, 2.0, true)
			c.draw_line(p, p + Vector2(0, -6), col, 2.0)
			c.draw_line(p, p + Vector2(5, 2), col, 2.0)
		elif tab == 2:
			c.draw_circle(p + Vector2(0, -5), 5.0, col)
			c.draw_arc(p + Vector2(0, 14), 10.0, PI, TAU, 12, col, 3.0, true)
		else:
			for ry in 3:
				for rx in 3:
					c.draw_circle(p + Vector2(float(rx - 1) * 7.0, float(ry - 1) * 7.0), 2.0, col)
		_t(c, T(String(keys[j])), Vector2(cx, 826), 12, col)
		hits.append({"r": Rect2(cx - 66.0, 782, 133, 54), "a": "ph_tab", "v": tab})
