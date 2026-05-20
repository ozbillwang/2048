extends Control

const SIZE := 4
const TARGET := 2048
const START_TILES := 2
const TILE_GAP := 12.0
const SWIPE_THRESHOLD := 42.0
const SAVE_PATH := "user://score.cfg"
const SAMPLE_RATE := 44100
const UI_FONT := preload("res://assets/fonts/ArialUnicode.ttf")

const MOVE_TIME := 0.14
const POP_TIME := 0.12
const CLASSIC_BOARD_COLOR := Color("#bbada0")
const CLASSIC_EMPTY_TILE := Color("#cdc1b4")

const THEME_PRESETS := [
	{"name": "Vital Green", "background": Color("#f4fbf4"), "board": Color("#1f5f45"), "empty": Color("#d7ead8"), "dark": Color("#183628"), "muted": Color("#52715f"), "light": Color("#ffffff"), "panel": Color("#2f7d59"), "accent": Color("#35b66b"), "accent_dark": Color("#238d50"), "title": Color("#25a35a"), "tiles": [Color("#e8f6e9"), Color("#ccefd4"), Color("#9be0a7"), Color("#68cc82"), Color("#43b86a"), Color("#2b9655"), Color("#ffd166"), Color("#4fc3a1"), Color("#3282b8"), Color("#8c6de9"), Color("#204d3a")]},
	{"name": "Ocean Blue", "background": Color("#f3f9ff"), "board": Color("#163d5c"), "empty": Color("#d3e5f2"), "dark": Color("#183248"), "muted": Color("#55718a"), "light": Color("#ffffff"), "panel": Color("#255f8c"), "accent": Color("#2f8fd8"), "accent_dark": Color("#1f6fa8"), "title": Color("#2176ae"), "tiles": [Color("#e6f3ff"), Color("#cce7ff"), Color("#95cdf5"), Color("#5fb4e8"), Color("#2d99d4"), Color("#1778aa"), Color("#69d2e7"), Color("#8a7ff0"), Color("#f7c948"), Color("#f47c7c"), Color("#15344f")]},
	{"name": "Sunrise Orange", "background": Color("#fff8f1"), "board": Color("#68442b"), "empty": Color("#f0ddc8"), "dark": Color("#3f2c22"), "muted": Color("#7b6556"), "light": Color("#ffffff"), "panel": Color("#9a6538"), "accent": Color("#ff8a3d"), "accent_dark": Color("#d86622"), "title": Color("#f47c20"), "tiles": [Color("#fff0df"), Color("#ffe0bf"), Color("#ffc078"), Color("#ff9f45"), Color("#f47c20"), Color("#d95d1a"), Color("#ffd166"), Color("#e85d75"), Color("#8d6bff"), Color("#2ec4b6"), Color("#5b321f")]},
	{"name": "Sport Black", "background": Color("#f7f8f8"), "board": Color("#15191c"), "empty": Color("#d9dedf"), "dark": Color("#171b1f"), "muted": Color("#5b6268"), "light": Color("#ffffff"), "panel": Color("#2a3035"), "accent": Color("#d6ff3f"), "accent_dark": Color("#a5c92a"), "title": Color("#101417"), "tiles": [Color("#eef2f0"), Color("#dce3df"), Color("#b9c6c0"), Color("#92a19c"), Color("#687a75"), Color("#40504c"), Color("#d6ff3f"), Color("#00c2ff"), Color("#ff5757"), Color("#9b7bff"), Color("#111719")]},
	{"name": "Pulse Red", "background": Color("#fff6f7"), "board": Color("#5b1c2b"), "empty": Color("#ecd4da"), "dark": Color("#3d1b22"), "muted": Color("#7a5660"), "light": Color("#ffffff"), "panel": Color("#8a2b3e"), "accent": Color("#ef3e5c"), "accent_dark": Color("#bd2942"), "title": Color("#d92d4a"), "tiles": [Color("#ffe7eb"), Color("#ffcbd5"), Color("#ff9caf"), Color("#ff6f88"), Color("#ef3e5c"), Color("#c72c48"), Color("#ffd166"), Color("#2ec4b6"), Color("#4d96ff"), Color("#9b5de5"), Color("#4b1623")]},
	{"name": "Glacier Cyan", "background": Color("#f2fbfb"), "board": Color("#0d5961"), "empty": Color("#cfe8ea"), "dark": Color("#17393d"), "muted": Color("#58777a"), "light": Color("#ffffff"), "panel": Color("#207983"), "accent": Color("#19c6d3"), "accent_dark": Color("#0f95a0"), "title": Color("#00a9b7"), "tiles": [Color("#e1fbfc"), Color("#c3f2f4"), Color("#8de4e8"), Color("#55d1d8"), Color("#19c6d3"), Color("#0f95a0"), Color("#b8f7d4"), Color("#f7d154"), Color("#ff7a59"), Color("#8c6de9"), Color("#0c444b")]},
	{"name": "Classic", "background": Color("#faf8ef"), "board": Color("#bbada0"), "empty": Color("#cdc1b4"), "dark": Color("#776e65"), "muted": Color("#776e65"), "light": Color("#f9f6f2"), "panel": Color("#bbada0"), "accent": Color("#8f7a66"), "accent_dark": Color("#776554"), "title": Color("#edc22e"), "tiles": [Color("#eee4da"), Color("#ede0c8"), Color("#f2b179"), Color("#f59563"), Color("#f67c5f"), Color("#f65e3b"), Color("#edcf72"), Color("#edcc61"), Color("#edc850"), Color("#edc53f"), Color("#edc22e")]}
]

var BACKGROUND := Color("#f4fbf4")
var BOARD_COLOR := CLASSIC_BOARD_COLOR
var EMPTY_TILE := CLASSIC_EMPTY_TILE
var TEXT_DARK := Color("#183628")
var TEXT_MUTED := Color("#52715f")
var TEXT_LIGHT := Color("#ffffff")
var PANEL_COLOR := Color("#2f7d59")
var ACCENT := Color("#35b66b")
var ACCENT_DARK := Color("#238d50")
var TITLE_COLOR := Color("#25a35a")
var TILE_COLORS := {}

var board: Array = []
var score := 0
var best_score := 0
var has_won := false
var game_over := false
var is_animating := false
var sound_enabled := true
var touch_start := Vector2.ZERO
var theme_index := 0
var language := "en"

var bg_rect: ColorRect
var margin_container: MarginContainer
var root_box: VBoxContainer
var title_label: Label
var score_label: Label
var best_label: Label
var score_caption_label: Label
var best_caption_label: Label
var theme_button: Button
var sound_button: Button
var language_button: Button
var status_label: Label
var new_game_button: Button
var new_game_dialog: ConfirmationDialog
var board_area: Control
var board_panel: Panel
var tile_layer: Control
var move_player: AudioStreamPlayer
var merge_player: AudioStreamPlayer
var empty_cells: Array[Panel] = []
var tile_nodes: Array[Label] = []


func _ready() -> void:
	randomize()
	best_score = _load_best_score()
	theme_index = _load_theme_index()
	sound_enabled = _load_sound_enabled()
	language = _load_language()
	_apply_theme_values()
	_build_ui()
	_build_audio()
	reset_game()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and board_panel:
		_layout_board()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_LEFT, KEY_A:
				_try_move(Vector2i.LEFT)
			KEY_RIGHT, KEY_D:
				_try_move(Vector2i.RIGHT)
			KEY_UP, KEY_W:
				_try_move(Vector2i.UP)
			KEY_DOWN, KEY_S:
				_try_move(Vector2i.DOWN)
			KEY_R:
				_request_new_game()
	elif event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.position
		else:
			_handle_swipe(event.position - touch_start)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			touch_start = event.position
		else:
			_handle_swipe(event.position - touch_start)


func _build_ui() -> void:
	bg_rect = ColorRect.new()
	bg_rect.color = BACKGROUND
	bg_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg_rect)

	margin_container = MarginContainer.new()
	margin_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", 24)
	margin_container.add_theme_constant_override("margin_right", 24)
	margin_container.add_theme_constant_override("margin_top", 28)
	margin_container.add_theme_constant_override("margin_bottom", 24)
	add_child(margin_container)

	root_box = VBoxContainer.new()
	root_box.alignment = BoxContainer.ALIGNMENT_CENTER
	root_box.add_theme_constant_override("separation", 18)
	margin_container.add_child(root_box)

	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 12)
	root_box.add_child(header)

	title_label = Label.new()
	title_label.text = "Merge\n2048"
	title_label.add_theme_color_override("font_color", TEXT_LIGHT)
	title_label.add_theme_font_size_override("font_size", 38)
	title_label.add_theme_font_override("font", UI_FONT)
	title_label.add_theme_stylebox_override("normal", _style(TITLE_COLOR, 8))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.custom_minimum_size = Vector2(130, 94)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_label)

	score_label = _make_score_box("score", "0")
	header.add_child(score_label.get_parent().get_parent())
	score_caption_label = score_label.get_parent().get_child(0) as Label

	best_label = _make_score_box("best", "0")
	header.add_child(best_label.get_parent().get_parent())
	best_caption_label = best_label.get_parent().get_child(0) as Label

	status_label = Label.new()
	status_label.text = "Swipe to move. Join matching tiles."
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", TEXT_MUTED)
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_font_override("font", UI_FONT)
	root_box.add_child(status_label)

	board_area = Control.new()
	board_area.custom_minimum_size = Vector2(360, 360)
	board_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_box.add_child(board_area)

	board_panel = Panel.new()
	board_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_panel.add_theme_stylebox_override("panel", _style(BOARD_COLOR, 8))
	board_area.add_child(board_panel)

	for i in range(SIZE * SIZE):
		var cell := Panel.new()
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_theme_stylebox_override("panel", _style(EMPTY_TILE, 6))
		board_panel.add_child(cell)
		empty_cells.append(cell)

	tile_layer = Control.new()
	tile_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_panel.add_child(tile_layer)

	for i in range(SIZE * SIZE):
		var tile := Label.new()
		tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tile.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		tile.add_theme_font_size_override("font_size", 34)
		tile.add_theme_font_override("font", UI_FONT)
		tile.hide()
		tile_layer.add_child(tile)
		tile_nodes.append(tile)

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 12)
	action_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_box.add_child(action_row)

	new_game_button = Button.new()
	new_game_button.text = "New Game"
	new_game_button.custom_minimum_size = Vector2(0, 48)
	new_game_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_game_button.add_theme_font_size_override("font_size", 18)
	new_game_button.add_theme_color_override("font_color", TEXT_LIGHT)
	new_game_button.add_theme_stylebox_override("normal", _style(ACCENT, 6))
	new_game_button.add_theme_stylebox_override("hover", _style(Color("#ff826f"), 6))
	new_game_button.add_theme_stylebox_override("pressed", _style(ACCENT_DARK, 6))
	new_game_button.pressed.connect(_request_new_game)
	action_row.add_child(new_game_button)

	theme_button = Button.new()
	theme_button.text = "Style"
	theme_button.custom_minimum_size = Vector2(132, 48)
	theme_button.add_theme_font_size_override("font_size", 16)
	theme_button.add_theme_color_override("font_color", TEXT_LIGHT)
	theme_button.pressed.connect(_cycle_theme)
	action_row.add_child(theme_button)

	sound_button = Button.new()
	sound_button.custom_minimum_size = Vector2(86, 48)
	sound_button.add_theme_font_size_override("font_size", 16)
	sound_button.pressed.connect(_toggle_sound)
	action_row.add_child(sound_button)

	language_button = Button.new()
	language_button.custom_minimum_size = Vector2(58, 48)
	language_button.add_theme_font_size_override("font_size", 16)
	language_button.pressed.connect(_toggle_language)
	action_row.add_child(language_button)
	_apply_theme_to_ui()
	_apply_language_to_ui()
	_build_new_game_dialog()


func _make_score_box(caption: String, value: String) -> Label:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(92, 58)
	panel.add_theme_stylebox_override("panel", _style(PANEL_COLOR, 6))

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 0)
	panel.add_child(box)

	var caption_label := Label.new()
	caption_label.text = caption
	caption_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption_label.add_theme_color_override("font_color", Color("#b8e4dd"))
	caption_label.add_theme_font_size_override("font_size", 12)
	caption_label.add_theme_font_override("font", UI_FONT)
	box.add_child(caption_label)

	var value_label := Label.new()
	value_label.text = value
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_color_override("font_color", TEXT_LIGHT)
	value_label.add_theme_font_size_override("font_size", 21)
	value_label.add_theme_font_override("font", UI_FONT)
	box.add_child(value_label)
	return value_label


func _cycle_theme() -> void:
	theme_index = (theme_index + 1) % THEME_PRESETS.size()
	_apply_theme_values()
	_save_settings()
	_apply_theme_to_ui()
	_apply_language_to_ui()
	_update_ui(false)


func _toggle_sound() -> void:
	sound_enabled = not sound_enabled
	_save_settings()
	_apply_theme_to_ui()
	_apply_language_to_ui()


func _toggle_language() -> void:
	language = "zh" if language == "en" else "en"
	_save_settings()
	_apply_language_to_ui()


func _apply_theme_values() -> void:
	theme_index = clampi(theme_index, 0, THEME_PRESETS.size() - 1)
	var theme: Dictionary = THEME_PRESETS[theme_index]
	BACKGROUND = theme.background
	BOARD_COLOR = CLASSIC_BOARD_COLOR
	EMPTY_TILE = CLASSIC_EMPTY_TILE
	TEXT_DARK = theme.dark
	TEXT_MUTED = theme.muted
	TEXT_LIGHT = theme.light
	PANEL_COLOR = theme.panel
	ACCENT = theme.accent
	ACCENT_DARK = theme.accent_dark
	TITLE_COLOR = theme.title
	var values := [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048]
	TILE_COLORS.clear()
	for i in range(values.size()):
		TILE_COLORS[values[i]] = theme.tiles[i]


func _apply_theme_to_ui() -> void:
	if not bg_rect:
		return
	bg_rect.color = BACKGROUND
	title_label.add_theme_color_override("font_color", TEXT_LIGHT)
	title_label.add_theme_stylebox_override("normal", _style(TITLE_COLOR, 8))
	status_label.add_theme_color_override("font_color", TEXT_MUTED)
	board_panel.add_theme_stylebox_override("panel", _style(BOARD_COLOR, 8))

	for cell in empty_cells:
		cell.add_theme_stylebox_override("panel", _style(EMPTY_TILE, 6))

	_style_score_box(score_label)
	_style_score_box(best_label)
	_style_button(new_game_button, _tr("new_game"))
	_style_button(theme_button, THEME_PRESETS[theme_index].name)
	_style_button(sound_button, _tr("sound_on") if sound_enabled else _tr("sound_off"))
	_style_button(language_button, "中" if language == "en" else "EN")
	_update_new_game_dialog_text()


func _apply_language_to_ui() -> void:
	if not title_label:
		return
	title_label.text = _tr("title")
	score_caption_label.text = _tr("score")
	best_caption_label.text = _tr("best")
	_style_button(new_game_button, _tr("new_game"))
	_style_button(sound_button, _tr("sound_on") if sound_enabled else _tr("sound_off"))
	_style_button(language_button, "中" if language == "en" else "EN")
	_update_new_game_dialog_text()

	if game_over:
		status_label.text = _tr("game_over") % score
	elif has_won:
		status_label.text = _tr("win")
	else:
		status_label.text = _tr("hint")


func _tr(key: String) -> String:
	var zh := language == "zh"
	match key:
		"title":
			return "合成\n2048" if zh else "Merge\n2048"
		"score":
			return "分数" if zh else "SCORE"
		"best":
			return "最佳" if zh else "BEST"
		"new_game":
			return "新游戏" if zh else "New Game"
		"confirm_new_game_title":
			return "开始新游戏？" if zh else "Start new game?"
		"confirm_new_game_body":
			return "当前游戏会结束，确定要重新开始吗？" if zh else "Your current game will end. Start over?"
		"confirm":
			return "确定" if zh else "Yes"
		"cancel":
			return "继续" if zh else "Keep Playing"
		"sound_on":
			return "音效开" if zh else "Sound On"
		"sound_off":
			return "音效关" if zh else "Sound Off"
		"hint":
			return "滑动方块，合并相同数字。" if zh else "Swipe to move. Join matching tiles."
		"win":
			return "达到 2048！继续挑战。" if zh else "2048 reached. Keep going."
		"game_over":
			return "无路可走。最终分数：%s。" if zh else "No moves left. Final score: %s."
	return key


func _build_new_game_dialog() -> void:
	new_game_dialog = ConfirmationDialog.new()
	new_game_dialog.confirmed.connect(reset_game)
	add_child(new_game_dialog)
	_update_new_game_dialog_text()


func _update_new_game_dialog_text() -> void:
	if not new_game_dialog:
		return
	new_game_dialog.title = _tr("confirm_new_game_title")
	new_game_dialog.dialog_text = _tr("confirm_new_game_body")
	new_game_dialog.ok_button_text = _tr("confirm")
	new_game_dialog.cancel_button_text = _tr("cancel")


func _request_new_game() -> void:
	if _is_fresh_game():
		reset_game()
		return
	new_game_dialog.popup_centered()


func _is_fresh_game() -> bool:
	var occupied := 0
	for y in range(SIZE):
		for x in range(SIZE):
			if board[y][x] != 0:
				occupied += 1
	return score == 0 and occupied <= START_TILES


func _style_score_box(value_label: Label) -> void:
	var panel := value_label.get_parent().get_parent() as PanelContainer
	panel.add_theme_stylebox_override("panel", _style(PANEL_COLOR, 6))
	var caption_label := value_label.get_parent().get_child(0) as Label
	caption_label.add_theme_color_override("font_color", EMPTY_TILE)
	value_label.add_theme_color_override("font_color", TEXT_LIGHT)


func _style_button(button: Button, label: String) -> void:
	button.text = label
	button.add_theme_color_override("font_color", TEXT_LIGHT)
	button.add_theme_font_override("font", UI_FONT)
	button.add_theme_stylebox_override("normal", _style(ACCENT, 6))
	button.add_theme_stylebox_override("hover", _style(ACCENT.lightened(0.12), 6))
	button.add_theme_stylebox_override("pressed", _style(ACCENT_DARK, 6))


func _style(color: Color, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	return box


func _build_audio() -> void:
	move_player = AudioStreamPlayer.new()
	move_player.stream = _make_tone_stream(260.0, 720.0, 0.14, 0.72)
	move_player.volume_db = 4.0
	add_child(move_player)

	merge_player = AudioStreamPlayer.new()
	merge_player.stream = _make_tone_stream(520.0, 1180.0, 0.18, 0.82)
	merge_player.volume_db = 5.0
	add_child(merge_player)


func _make_tone_stream(start_freq: float, end_freq: float, duration: float, volume: float) -> AudioStreamWAV:
	var frames := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)

	var phase := 0.0
	for i in range(frames):
		var t := float(i) / float(maxi(frames - 1, 1))
		var freq := lerpf(start_freq, end_freq, t)
		phase += TAU * freq / float(SAMPLE_RATE)
		var envelope := sin(PI * t)
		var sample := int(clamp(sin(phase) * envelope * volume, -1.0, 1.0) * 32767.0)
		bytes[i * 2] = sample & 0xff
		bytes[i * 2 + 1] = (sample >> 8) & 0xff

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = bytes
	return stream


func _play_move_sound() -> void:
	if not sound_enabled or not move_player:
		return
	move_player.stop()
	move_player.play()


func _play_merge_sound() -> void:
	if not sound_enabled or not merge_player:
		return
	merge_player.stop()
	merge_player.play()


func _layout_board() -> void:
	var available := board_area.size
	var side: float = min(available.x, available.y)
	side = clamp(side, 280.0, 520.0)
	board_panel.size = Vector2(side, side)
	board_panel.position = (available - board_panel.size) * 0.5
	tile_layer.position = Vector2.ZERO
	tile_layer.size = board_panel.size

	var tile_size := _tile_size()
	for y in range(SIZE):
		for x in range(SIZE):
			var rect := Rect2(_tile_position(Vector2i(x, y)), Vector2(tile_size, tile_size))
			empty_cells[_index(x, y)].position = rect.position
			empty_cells[_index(x, y)].size = rect.size
			var tile := tile_nodes[_index(x, y)]
			tile.position = rect.position
			tile.size = rect.size
			_update_tile_font(tile, board[y][x] if board.size() == SIZE else 0)


func reset_game() -> void:
	is_animating = false
	score = 0
	has_won = false
	game_over = false
	board.clear()
	for y in range(SIZE):
		board.append([0, 0, 0, 0])
	for i in range(START_TILES):
		_spawn_tile()
	_update_ui(false)


func _try_move(direction: Vector2i) -> void:
	if game_over or is_animating:
		return

	var before := _duplicate_board(board)
	var next_board := _empty_board()
	var moves: Array[Dictionary] = []
	var gained := 0

	if direction == Vector2i.LEFT or direction == Vector2i.RIGHT:
		for y in range(SIZE):
			var line: Array = board[y].duplicate()
			var cells: Array[Vector2i] = []
			for x in range(SIZE):
				cells.append(Vector2i(x, y))
			if direction == Vector2i.RIGHT:
				line.reverse()
				cells.reverse()
			var result := _merge_line(line, cells)
			for x in range(SIZE):
				next_board[y][cells[x].x] = result.tiles[x]
			moves.append_array(result.moves)
			gained += result.score
	else:
		for x in range(SIZE):
			var line: Array = []
			var cells: Array[Vector2i] = []
			for y in range(SIZE):
				line.append(board[y][x])
				cells.append(Vector2i(x, y))
			if direction == Vector2i.DOWN:
				line.reverse()
				cells.reverse()
			var result := _merge_line(line, cells)
			for y in range(SIZE):
				next_board[cells[y].y][x] = result.tiles[y]
			moves.append_array(result.moves)
			gained += result.score

	if _boards_equal(before, next_board):
		return

	board = next_board
	score += gained
	best_score = max(best_score, score)
	_save_best_score()
	var spawned_cell := _spawn_tile()
	_animate_move(before, moves, spawned_cell, gained > 0)


func _merge_line(line: Array, cells: Array[Vector2i]) -> Dictionary:
	var values: Array[Dictionary] = []
	for i in range(line.size()):
		if int(line[i]) != 0:
			values.append({"value": int(line[i]), "from": cells[i]})

	var merged: Array[int] = []
	var moves: Array[Dictionary] = []
	var gained := 0
	var i := 0
	var target_index := 0
	while i < values.size():
		var target := cells[target_index]
		if i + 1 < values.size() and values[i].value == values[i + 1].value:
			var next_value: int = values[i].value * 2
			merged.append(next_value)
			gained += next_value
			moves.append({"from": values[i].from, "to": target, "value": values[i].value, "merged": true})
			moves.append({"from": values[i + 1].from, "to": target, "value": values[i + 1].value, "merged": true})
			i += 2
		else:
			merged.append(values[i].value)
			moves.append({"from": values[i].from, "to": target, "value": values[i].value, "merged": false})
			i += 1
		target_index += 1

	while merged.size() < SIZE:
		merged.append(0)

	return {"tiles": merged, "score": gained, "moves": moves}


func _spawn_tile() -> Vector2i:
	var empty: Array[Vector2i] = []
	for y in range(SIZE):
		for x in range(SIZE):
			if board[y][x] == 0:
				empty.append(Vector2i(x, y))
	if empty.is_empty():
		return Vector2i(-1, -1)

	var cell := empty[randi() % empty.size()]
	board[cell.y][cell.x] = 4 if randf() < 0.1 else 2
	return cell


func _update_ui(animated: bool) -> void:
	score_label.text = str(score)
	best_label.text = str(best_score)

	var reached_target := false
	for y in range(SIZE):
		for x in range(SIZE):
			if board[y][x] >= TARGET:
				reached_target = true
			_draw_tile(x, y, board[y][x], animated)

	if reached_target and not has_won:
		has_won = true
		status_label.text = _tr("win")
	elif not _has_moves():
		game_over = true
		status_label.text = _tr("game_over") % score
	elif not has_won:
		status_label.text = _tr("hint")

	_layout_board()


func _draw_tile(x: int, y: int, value: int, animated: bool) -> void:
	var tile := tile_nodes[_index(x, y)]
	if value == 0:
		tile.hide()
		return

	tile.text = str(value)
	tile.add_theme_color_override("font_color", TEXT_DARK if value <= 4 else TEXT_LIGHT)
	tile.add_theme_stylebox_override("normal", _style(TILE_COLORS.get(value, Color("#3c3a32")), 6))
	tile.show()
	_update_tile_font(tile, value)

	if animated:
		tile.scale = Vector2(0.92, 0.92)
		var tween := create_tween()
		tween.tween_property(tile, "scale", Vector2.ONE, 0.09).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		tile.scale = Vector2.ONE


func _animate_move(before: Array, moves: Array[Dictionary], spawned_cell: Vector2i, had_merge: bool) -> void:
	is_animating = true
	_play_move_sound()
	score_label.text = str(score)
	best_label.text = str(best_score)
	_layout_board()

	for tile in tile_nodes:
		tile.hide()

	var tween := create_tween()
	tween.set_parallel(true)
	var temps: Array[Label] = []

	for move in moves:
		var temp := _make_tile_label(move.value)
		temp.position = _tile_position(move.from)
		temp.size = Vector2(_tile_size(), _tile_size())
		tile_layer.add_child(temp)
		temps.append(temp)
		tween.tween_property(temp, "position", _tile_position(move.to), MOVE_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	await tween.finished

	for temp in temps:
		temp.queue_free()

	_update_ui(false)
	if had_merge:
		_play_merge_sound()
	if spawned_cell.x >= 0:
		_pop_tile(spawned_cell)
	_pop_merged_tiles(moves)
	is_animating = false


func _make_tile_label(value: int) -> Label:
	var tile := Label.new()
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tile.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tile.text = str(value)
	tile.add_theme_font_override("font", UI_FONT)
	tile.add_theme_color_override("font_color", TEXT_DARK if value <= 4 else TEXT_LIGHT)
	tile.add_theme_stylebox_override("normal", _style(TILE_COLORS.get(value, Color("#3c3a32")), 6))
	_update_tile_font(tile, value)
	return tile


func _pop_tile(cell: Vector2i) -> void:
	var tile := tile_nodes[_index(cell.x, cell.y)]
	if not tile.visible:
		return
	tile.scale = Vector2(0.7, 0.7)
	var tween := create_tween()
	tween.tween_property(tile, "scale", Vector2.ONE, POP_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _pop_merged_tiles(moves: Array[Dictionary]) -> void:
	var popped := {}
	for move in moves:
		if not move.merged:
			continue
		var cell: Vector2i = move.to
		var key := "%s,%s" % [cell.x, cell.y]
		if popped.has(key):
			continue
		popped[key] = true
		_pop_tile(cell)


func _update_tile_font(tile: Label, value: int) -> void:
	var size := 34
	if value >= 1024:
		size = 27
	elif value >= 128:
		size = 31
	tile.add_theme_font_size_override("font_size", size)


func _handle_swipe(delta: Vector2) -> void:
	if delta.length() < SWIPE_THRESHOLD:
		return
	if abs(delta.x) > abs(delta.y):
		_try_move(Vector2i.RIGHT if delta.x > 0 else Vector2i.LEFT)
	else:
		_try_move(Vector2i.DOWN if delta.y > 0 else Vector2i.UP)


func _has_moves() -> bool:
	for y in range(SIZE):
		for x in range(SIZE):
			if board[y][x] == 0:
				return true
			if x + 1 < SIZE and board[y][x] == board[y][x + 1]:
				return true
			if y + 1 < SIZE and board[y][x] == board[y + 1][x]:
				return true
	return false


func _tile_size() -> float:
	return (board_panel.size.x - TILE_GAP * float(SIZE + 1)) / float(SIZE)


func _tile_position(cell: Vector2i) -> Vector2:
	var tile_size := _tile_size()
	return Vector2(
		TILE_GAP + float(cell.x) * (tile_size + TILE_GAP),
		TILE_GAP + float(cell.y) * (tile_size + TILE_GAP)
	)


func _index(x: int, y: int) -> int:
	return y * SIZE + x


func _duplicate_board(source: Array) -> Array:
	var copy := []
	for row in source:
		copy.append(row.duplicate())
	return copy


func _empty_board() -> Array:
	var empty := []
	for y in range(SIZE):
		empty.append([0, 0, 0, 0])
	return empty


func _boards_equal(a: Array, b: Array) -> bool:
	for y in range(SIZE):
		for x in range(SIZE):
			if a[y][x] != b[y][x]:
				return false
	return true


func _load_best_score() -> int:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return 0
	return int(config.get_value("game", "best_score", 0))


func _load_theme_index() -> int:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return 0
	return int(config.get_value("game", "theme_index", 0))


func _load_sound_enabled() -> bool:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return true
	return bool(config.get_value("game", "sound_enabled", true))


func _load_language() -> String:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return "en"
	var saved := str(config.get_value("game", "language", "en"))
	return "zh" if saved == "zh" else "en"


func _save_best_score() -> void:
	_save_settings()


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.load(SAVE_PATH)
	config.set_value("game", "best_score", best_score)
	config.set_value("game", "theme_index", theme_index)
	config.set_value("game", "sound_enabled", sound_enabled)
	config.set_value("game", "language", language)
	config.save(SAVE_PATH)
