extends Node

var fish = preload("res://Scenes/Fish/fish.tscn")
@onready var terrain = $"../Terrain"
var terrain_mesh_size

var image:Image
var terrain_size

var waterAreas:Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	image = Image.new()
	image.load("res://image.png")
	
	terrain_mesh_size = terrain.mesh.size

#	init_fish(image,terrain_mesh_size)
	
func _process(delta):
	pass

func init_fish(grayscaleMap:Image,terrain_mesh_size:Vector2):
	var waterAreas = findWaterAreas(image)
	print(waterAreas.size())
	var x = randi() % waterAreas.size() 
	var y = randi() % waterAreas[x].size()
	var pos_in_water = waterAreas[x][y]
	var color = grayscaleMap.get_pixelv(pos_in_water)
	var pos_convert = coordinates_pixel2space(pos_in_water,grayscaleMap.get_size(),terrain_mesh_size)
	
	var fish_instance =  preload("res://Scenes/Fish/fish.tscn").instantiate()
#	var root_node = get_tree().get_root()
#	root_node.add_child(fish_instance)
	add_child(fish_instance)
	fish_instance.position = pos_convert + Vector3(0,0.3,0)
	
	
func coordinates_pixel2space(pixel_coord: Vector2,img_size:Vector2,terrain_size:Vector2)->Vector3:
	var pixel_space_x =   pixel_coord.x  *(terrain_size.x / img_size.x )
	var pixel_space_y =   pixel_coord.y  *(terrain_size.y / img_size.y )
	return Vector3(pixel_space_x,0,pixel_space_y)


func findWaterAreas(grayscaleMap:Image):
	var width = grayscaleMap.get_width()
	var height = grayscaleMap.get_height()
	var visited = []
	var waterAreas = []

	# Initialize visited array
	for x in range(width):
		visited.append([])
		for y in range(height):
			visited[x].append(false)
			
	var area = []
	
	# Iterate through the grayscale map
	for x in range(width):
		for y in range(height):
			# If the pixel is unvisited and considered water
			if !visited[x][y] && grayscaleMap.get_pixel(x, y).r < 0.5:
				var waterArea = 0
				var queue = []
				queue.append(Vector2(x, y))

				# Perform a breadth-first search to find connected water pixels
				while queue.size() > 0:
					# 弹出数组第一个数
					var currentPos = queue.pop_front()
					var currentX = currentPos.x
					var currentY = currentPos.y

					# Check if the current pixel is within the map boundaries and is water
					if currentX >= 0 && currentX < width && currentY >= 0 && currentY < height && grayscaleMap.get_pixel(currentX, currentY).r < 0.3 && !visited[currentX][currentY]:
						visited[currentX][currentY] = true
						waterArea += 1
						
						var a = Vector2(currentX,currentX)
						area.append(a)
						
						# Add neighboring pixels to the queue
						queue.append(Vector2(currentX - 1, currentY))  # Left
						queue.append(Vector2(currentX + 1, currentY))  # Right
						queue.append(Vector2(currentX, currentY - 1))  # Up
						queue.append(Vector2(currentX, currentY + 1))  # Down
						
				# If the water area is greater than 100, add it to the result
				if waterArea > 1000:
#					waterAreas.append(waterArea)
					waterAreas.append(area)
					print("area",area.size())
					area = []
	return waterAreas

