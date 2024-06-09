extends Control

@onready var decText = get_node("VBoxContainer/Decimal Margin/HBoxContainer/Decimal")
@onready var binText = get_node("VBoxContainer/Binary Margin/HBoxContainer/Binary")
@onready var hexText = get_node("VBoxContainer/Hex Margin/HBoxContainer/Hex")
@onready var twoButt = get_node("VBoxContainer/Twos Margin/CenterContainer/Two Button")

var twosComp = false

func _ready():
	if(OS.has_feature("android")):
		scale = Vector2(1.8, 1.8)
		size = Vector2(400, 471)
		position = Vector2(0, 400)
	if(ProjectSettings.get_setting("global/pass_number") != 0):
		decText.text = str(ProjectSettings.get_setting("global/pass_number"))
		_on_decimal_text_changed(str(ProjectSettings.get_setting("global/pass_number")))

# Helper functions

func reset_overrides():
	decText.remove_theme_color_override("font_color")
	binText.remove_theme_color_override("font_color")
	hexText.remove_theme_color_override("font_color")

func is_valid_bin(string):
	if(string.is_empty()):
		return false
	for c in string:
		if(c != '0' && c != '1'):
			return false
	return true

func eval_bin(dec):
	var neg = false
	var string = ""
	var i = 1
	if(dec == 0):
		return "0"
	elif(dec < 0):
		neg = true
		dec = abs(dec)-1
	while (dec > 0):
		if(dec % (1<<i)):
			string = "1"+string
			dec -= dec%(1<<i)
		else:
			string = "0"+string
		i+=1
		if(((i-1) % 4 == 0) && (dec > 0)):
			string = " "+string
	if neg:
		var string2 = "1"
		for c in string:
			if(c == "0"):
				string2+="1"
			elif(c == "1"):
				string2+="0"
			else:
				string2+=" "
		string = string2
	return string

func eval_twos_bin(bin):
	var rtn = 0
	var i = pow(2, bin.length()-1)
	var neg = true
	for c in bin:
		if(c == "1"):
			if(neg):
				rtn -= i
			else:
				rtn += i
		i /= 2
		neg = false
	return rtn

func to_hex_char(input):
	if(input>9):
		match input:
			10:
				return "A"
			11:
				return "B"
			12:
				return "C"
			13:
				return "D"
			14:
				return "E"
			15:
				return "F"
			_:
				return "X"
	else:
		return str(input)

func invert_hex(input):
	match input:
		"0":
			return "F"
		"1":
			return "E"
		"2":
			return "D"
		"3":
			return "C"
		"4":
			return "B"
		"5":
			return "A"
		"6":
			return "9"
		"7":
			return "8"
		"8":
			return "7"
		"9":
			return "6"
		"A":
			return "5"
		"B":
			return "4"
		"C":
			return "3"
		"D":
			return "2"
		"E":
			return "1"
		"F":
			return "0"
		_:
			return "X"

func eval_hex(dec):
	var neg = false
	var string = ""
	var i = 1
	if(dec == 0):
		return "0"
	elif(dec < 0):
		neg = true
		dec = abs(dec)-1
	while (dec > 0):
		var reference = pow(16,i)
		reference = dec % int(reference)
		if(reference > 0):
			string = to_hex_char(int(reference/pow(16,i-1)))+string
			dec -= reference
		else:
			string = "0"+string
		i+=1
		if(((i-1) % 4 == 0) && (dec > 0)):
			string = " "+string
	if neg:
		if(string.length() == 0):
			return "1"
		if(string[0] >= "8"):
			string = "0"+string
		var string2 = ""
		for c in string:
			string2 += invert_hex(c)
		string = string2
	#string = "0x"+string
	return string

# text inputs

func _on_decimal_text_changed(new_text):
	if new_text.is_valid_int():
		reset_overrides()
		binText.text = eval_bin(new_text.to_int())
		hexText.text = eval_hex(new_text.to_int())
		if (new_text.to_int() < 0):
			twoButt.button_pressed = true
	else:
		decText.add_theme_color_override("font_color", Color(1,0,0,1))
		binText.text = ""
		hexText.text = ""


func _on_binary_text_changed(new_text):
	new_text = new_text.replace(" ", "")
	if(new_text.length() > 2 && new_text[1] == "b"):
		new_text = new_text.substr(2)
	if is_valid_bin(new_text):
		reset_overrides()
		if(twosComp):
			decText.text = str(eval_twos_bin(binText.text.replace(" ", "")))
		else:
			decText.text = str(new_text.bin_to_int())
		hexText.text = eval_hex(new_text.bin_to_int())
	else:
		binText.add_theme_color_override("font_color", Color(1,0,0,1))
		decText.text = ""
		hexText.text = ""


func _on_hex_text_changed(new_text):
	if(new_text.length() > 2 && new_text.to_lower()[1] == "x"):
		new_text = new_text.substr(2)
	if new_text.is_valid_hex_number():
		reset_overrides()
		binText.text = eval_bin(new_text.hex_to_int())
		if(twosComp):
			decText.text = str(eval_twos_bin(binText.text.replace(" ", "")))
		else:
			decText.text = str(new_text.hex_to_int())
	else:
		hexText.add_theme_color_override("font_color", Color(1,0,0,1))
		decText.text = ""
		binText.text = ""

# Buttons

func _on_clear_pressed():
	decText.text = ""
	binText.text = ""
	hexText.text = ""

func _on_two_button_toggled(toggled_on):
	twosComp = toggled_on
	if(toggled_on):
		decText.text = str(eval_twos_bin(binText.text.replace(" ", "")))
	else:
		decText.text = str(binText.text.replace(" ", "").bin_to_int())
		hexText.text = eval_hex(binText.text.replace(" ", "").bin_to_int())

# Operations

func _on_sub_pressed():
	if(decText.text == ""):
		decText.text = "0"
	decText.text = str((decText.text.to_int())-1)
	_on_decimal_text_changed(decText.text)

func _on_lshift_pressed():
	if(decText.text == ""):
		decText.text = "0"
	decText.text = str((decText.text.to_int())*2)
	_on_decimal_text_changed(decText.text)

func _on_rshift_pressed():
	if(decText.text == ""):
		decText.text = "0"
	decText.text = str((decText.text.to_int())/2)
	_on_decimal_text_changed(decText.text)

func _on_add_pressed():
	if(decText.text == ""):
		decText.text = "0"
	decText.text = str((decText.text.to_int())+1)
	_on_decimal_text_changed(decText.text)

func _on_math_pressed():
	if(decText.text != "" && decText.text.is_valid_int()):
		ProjectSettings.set_setting("global/pass_number", decText.text.to_int())
	else:
		ProjectSettings.set_setting("global/pass_number", 0)
	get_tree().change_scene_to_file("res://Math.tscn")


