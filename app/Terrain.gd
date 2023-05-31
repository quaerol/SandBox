extends MeshInstance3D

const DEBUG = false

var img = Image.new()
var img_colormap = Image.new()

# Use SimplexNoise if debug enabled, else use GDRealsense
# 如果是DEBUG，采用“开放简单噪声”来生成数据源
#var realsense = FastNoiseLite.new() if (DEBUG) else load("res://bin/x11/gdrealsense.gdns").new()
#var realsense = OpenSimplexNoise.new() if (DEBUG) else load("res://bin/x11/gdrealsense.gdns").new()
var realsense 

var st = SurfaceTool.new()

var mdt = MeshDataTool.new()

#var top_offset = 75
#var right_offset = 50
#var bottom_offset = 40
#var left_offset = 120
#var segment_size = 3

var top_offset = 0
var right_offset = 0
var bottom_offset = 0
var left_offset = 0
var segment_size = 1

#var sea_level = 0.02
var material
var rng = RandomNumberGenerator.new()

var fish = preload("res://Scenes/Fish/fish.tscn")
#读取传感器帧数据
func get_frame():
	var width : float
	var height: float
	var depth_array: PackedByteArray
	
	#如果是DEBUG，则读取人工生成的数据；如果是运行状态，则从传感器中读取当前深度数据帧
	if DEBUG:
		realsense.seed = randi()
		width = ceil((1280 - right_offset - left_offset)/segment_size) + 1
		height = ceil((600 - top_offset - bottom_offset)/segment_size) + 1
		depth_array = realsense.get_image(width, height).get_data()
	else:
		depth_array = realsense.get_depth_frame(top_offset, right_offset, bottom_offset, left_offset,segment_size)
		width = realsense.get_frame_width()
		height = realsense.get_frame_height()
	return {"width": width, "height": height, "depth_array": depth_array}

# 初始化：获取传感器帧图像，创建网格模型Called when the node enters the scene tree for the first time.
func _ready():
	realsense = $"../Realsense"
	realsense.setup()
	var frame = get_frame()	

#	#创建帧图像img
	img = img.create_from_data(frame.width, frame.height, false, Image.FORMAT_R8, frame.depth_array)
	
#	#清空初始化表面工具SurfaceTool
#	st.clear()
#	#开始创建三角形
#	st.begin(Mesh.PRIMITIVE_TRIANGLES)
#
#	var vert_x_width = frame.width - 1
#	var vert_y_height = frame.height - 1
#	for y in range(frame.height):
#		for x in range(frame.width):
#			#st.add_smooth_group(true)
#
#			#添加顶点
#			st.add_vertex(Vector3(((8.0*x)/(frame.width)), 0.0, ((4.5 * y)/(frame.height))))
#			# Build indices for a complete mesh
#			var vert_y = y
#			var vert_x = x
#			var next_vert_y = vert_y + 1
#			var next_vert_x = vert_x + 1
#			#将顶点添加到索引数组
#			if(vert_y < vert_y_height and vert_x < vert_x_width):
#				st.add_index((vert_x_width * vert_y) + vert_x)
#				st.add_index((vert_x_width * vert_y) + next_vert_x)
#				st.add_index((vert_x_width * next_vert_y) + next_vert_x)
#
#				st.add_index((vert_x_width * vert_y) + vert_x)
#				st.add_index((vert_x_width * next_vert_y) + next_vert_x)
#				st.add_index((vert_x_width * next_vert_y) + vert_x)
	
#	var water = find_pos_in_water(img)
#
#	var fish_instance = fish.instantiate()
#
#	# 获取根节点
#	var root_node = get_tree().get_root()
#
#	var fish_init = water[water.size /2]
#	var space_fish_init = coordinates_pixel2space(fish_init,img.get_size(),self.mesh.size)
#	# 设置场景实例的位置	
#	fish_instance.position = space_fish_init

	# 将实例添加到根节点下
#	root_node.add_child(fish_instance)
	
	
	
	$"../one_fish".img = img
	$"../one_fish".terrain_size = self.mesh.size

#	$"../one_fish".terrain_size = Vector2(frame.width, frame.height)






func _process(delta):
#	var frame = get_frame()
#	img.create_from_data(frame.width, frame.height, false, Image.FORMAT_R8, frame.depth_array)
#	false # img.lock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	
	#获取当前帧
	var frame = get_frame()	
	#print(frame.depth_array)
	#print(frame.depth_array)
	img = img.create_from_data(frame.width, frame.height, false, Image.FORMAT_R8, frame.depth_array)
#	var texture = ImageTexture.new()
#	texture.create_from_image(img) 
	var texture = ImageTexture.create_from_image(img)
	img.save_png("image.png")
	
	img_colormap.load("res://graymapforblender.png")	
	var texture_2 = ImageTexture.new()
	texture_2.create_from_image(img_colormap) 

	
	img_colormap.load("res://4volcono1.png")	
	var texture_1 = ImageTexture.new()
	texture_1.create_from_image(img_colormap) #,0
	
	get_surface_override_material(0).set_shader_parameter("texture_albedo", texture)

	$"../one_fish".img = img
	$"../one_fish".terrain_size = self.mesh.size

#	img.load("res://image - 副本.png")




#	update_shader(texture,texture_1)
#	#get_surface_override_material(0).set_shader_parameter("texture_albedo", texture)
#
#func update_shader(texture, texture_1):
#
#	#$Terrain.get_surface_override_material(0).set_shader_parameter( "texture_albedo", img )
#
#	get_surface_override_material(0).set_shader_parameter("texture_albedo", texture)
#	get_surface_override_material(0).set_shader_parameter("ColorMapSampler", texture_1)
#	#get_surface_material(0)

func find_pos_in_water(img:Image):
	var water_area:Array
	for y in range(0,img.get_height()):
		for x in range(0,img.get_width()):
			var pixel = img.get_pixel(x ,y)
			var vector = Vector2(x, y)
			if pixel.r < 100:
					water_area.append(vector)
	return water_area

func coordinates_pixel2space(pixel_coord: Vector2,img_size:Vector2,terrain_size:Vector2)->Vector3:
	var pixel_space_x =   pixel_coord.x  *(terrain_size.x / img_size.x )
	var pixel_space_y =   pixel_coord.y  *(terrain_size.y / img_size.y )
	return Vector3(pixel_space_x,0,pixel_space_y)

