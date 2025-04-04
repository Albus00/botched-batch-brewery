class_name Item
extends Resource

@export var name: String = ""
@export var description: String = ""
@export var sprite: Texture2D = AtlasTexture.new()

# static func getItemByName(itemName: String) -> Item:
#   if itemName == item["name"]:
#     var newItem = Item.new()
#     newItem.name = item["name"]
#     newItem.description = item["description"]
#     newItem.sprite = item["sprite"]
#     newItem.spriteRegion = item["spriteRegion"]
#     return newItem
#   return null

# static var item = {
#     "name": "Hops",
# 		"description": "A bittering agent used in brewing beer.",
#     "sprite": preload("res://Sprites/Freebies_Icons_Botany.png"),
# 		"spriteRegion": Rect2(67, 3, 27, 28)
# }