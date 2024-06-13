extends Control

@onready var op1Text = get_node("VBoxContainer/Op1 Margin/HBoxContainer/Op1")
@onready var op1Sel  = get_node("VBoxContainer/Op1 Margin/HBoxContainer/Op1Sel")
@onready var operationSel = get_node("VBoxContainer/Operation/HBoxContainer/OperationSel")
@onready var op2Text = get_node("VBoxContainer/Op2 Margin/HBoxContainer/Op2")
@onready var op2Sel  = get_node("VBoxContainer/Op2 Margin/HBoxContainer/Op2Sel")
@onready var ansText = get_node("VBoxContainer/Ans Margin/HBoxContainer/Ans")
@onready var ansSel  = get_node("VBoxContainer/Ans Margin/HBoxContainer/AnsSel")

var op1 = 0
var op2 = 0
var ans = 0

func _ready():
	if(OS.has_feature("mobile")):
		scale = Vector2(1.8, 1.8)
		size = Vector2(400, 471)
		position = Vector2(0, 400)
	op1 = ProjectSettings.get_setting("global/pass_number")
	op1Text.text = str(op1)
	calculate()

# Helper functions

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

func calculate():
	ansText.remove_theme_color_override("font_color")
	match operationSel.selected:
		0: # add
			ans = op1 + op2
			set_ans_text()
		1: # sub
			ans = op1 - op2
			set_ans_text()
		2: # mul
			ans = op1 * op2
			set_ans_text()
		3: # div
			if(op2 != 0):
				ans = int(op1 / op2)
				set_ans_text()
			else:
				ansText.add_theme_color_override("font_color", Color(1,0,0,1))
				ans = 0
				set_ans_text()
		4: # mod
			if(op2 != 0):
				ans = op1 % op2
				set_ans_text()
			else:
				ansText.add_theme_color_override("font_color", Color(1,0,0,1))
				ans = 0
				set_ans_text()

# edit text

func set_op1_text():
	match op1Sel.selected:
		0: # Dec
			op1Text.text = str(op1)
		1: # Bin
			op1Text.text = eval_bin(op1)
		2: # Hex
			op1Text.text = eval_hex(op1)

func _on_op_1_text_changed(new_text):
	match op1Sel.selected:
		0: # Dec
			if new_text.is_valid_int():
				op1Text.remove_theme_color_override("font_color")
				op1 = new_text.to_int()
			else:
				op1Text.add_theme_color_override("font_color", Color(1,0,0,1))
				op1 = 0
		1: # Bin
			new_text = new_text.replace(" ", "")
			if(new_text.length() > 2 && new_text[1] == "b"):
				new_text = new_text.substr(2)
			if is_valid_bin(new_text):
				op1Text.remove_theme_color_override("font_color")
				op1 = eval_twos_bin(new_text)
			else:
				op1Text.add_theme_color_override("font_color", Color(1,0,0,1))
				op1 = 0
		2: # Hex
			if(new_text.length() > 2 && new_text.to_lower()[1] == "x"):
				new_text = new_text.substr(2)
			if new_text.is_valid_hex_number():
				op1Text.remove_theme_color_override("font_color")
				op1 = new_text.hex_to_int()
			else:
				op1Text.add_theme_color_override("font_color", Color(1,0,0,1))
				op1 = 0
	calculate()

func _on_op_1_sel_item_selected(index):
	match index:
		0: # Dec
			op1Text.text = str(op1)
		1: # Bin
			op1Text.text = eval_bin(op1)
		2: # Hex
			op1Text.text = eval_hex(op1)
	_on_op_1_text_changed(op1Text.text)


func _on_operation_sel_item_selected(_index):
	calculate()


func _on_op_2_text_changed(new_text):
	match op2Sel.selected:
		0: # Dec
			if new_text.is_valid_int():
				op2Text.remove_theme_color_override("font_color")
				op2 = new_text.to_int()
			else:
				op2Text.add_theme_color_override("font_color", Color(1,0,0,1))
				op2 = 0
		1: # Bin
			new_text = new_text.replace(" ", "")
			if(new_text.length() > 2 && new_text[1] == "b"):
				new_text = new_text.substr(2)
			if is_valid_bin(new_text):
				op2Text.remove_theme_color_override("font_color")
				op2 = eval_twos_bin(new_text)
			else:
				op2Text.add_theme_color_override("font_color", Color(1,0,0,1))
				op2 = 0
		2: # Hex
			if(new_text.length() > 2 && new_text.to_lower()[1] == "x"):
				new_text = new_text.substr(2)
			if new_text.is_valid_hex_number():
				op2Text.remove_theme_color_override("font_color")
				op2 = new_text.hex_to_int()
			else:
				op2Text.add_theme_color_override("font_color", Color(1,0,0,1))
				op2 = 0
	calculate()

func _on_op_2_sel_item_selected(index):
	match index:
		0: # Dec
			op2Text.text = str(op2)
		1: # Bin
			op2Text.text = eval_bin(op2)
		2: # Hex
			op2Text.text = eval_hex(op2)
	_on_op_2_text_changed(op2Text.text)


func set_ans_text():
	match ansSel.selected:
		0: # Dec
			ansText.text = str(ans)
		1: # Bin
			ansText.text = eval_bin(ans)
		2: # Hex
			ansText.text = eval_hex(ans)

func _on_ans_sel_item_selected(_index):
	set_ans_text()

# Buttons

func _on_load_pressed():
	op1 = ans
	set_op1_text()
	_on_op_1_text_changed(op1Text.text)

func _on_return_pressed():
	ProjectSettings.set_setting("global/pass_number", ans)
	get_tree().change_scene_to_file("res://app.tscn")



