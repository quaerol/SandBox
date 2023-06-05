extends Node3D

var image:Image
var fish = preload("res://Scenes/Fish/fish.tscn")
var waterAreas = []

func _ready():
	image = Image.new()
	image.load("res://test.png")
	waterAreas = findWaterAreas(image)
	print(waterAreas.size())
	var scene = preload("res://Scenes/Fish/fish.tscn").instantiate()
# Add the node as a child of the node the script is attached to.
	add_child(scene)
#	var fish_instance = fish.instantiate()	
#
#	fish_instance.position =  Vector3(4,0.3,3)
#	get_parent().add_child(fish_instance)
#
#	var root_node = get_tree().get_root()
#	root_node.add_child(fish_instance)


func _process(delta):
	pass

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
					if currentX >= 0 && currentX < width && currentY >= 0 && currentY < height && grayscaleMap.get_pixel(currentX, currentY).r < 0.5 && !visited[currentX][currentY]:
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

