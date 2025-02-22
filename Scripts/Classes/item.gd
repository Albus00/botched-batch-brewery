class_name Item

var name: String = ""
var description: String = ""
var quantity: int = 0


func print_health():
	print(health)


func print_this_script_three_times():
	print(get_script())
	print(ResourceLoader.load("res://character.gd"))
	print(Character)