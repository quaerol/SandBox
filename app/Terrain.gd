extends MeshInstance3D

var img = Image.new()
var img_colormap = Image.new()

var realsense 

var st = SurfaceTool.new()

var mdt = MeshDataTool.new()


var top_offset = 0
var right_offset = 0
var bottom_offset = 0
var left_offset = 0
var segment_size = 1

#var sea_level = 0.02
var material

@onready var node_3d = $"../Node3D"

var thread

#读取传感器帧数据
func get_frame():
	var width : float
	var height: float
	var depth_array: PackedByteArray

	depth_array = realsense.get_depth_frame(top_offset, right_offset, bottom_offset, left_offset,segment_size)
	width = realsense.get_frame_width()
	height = realsense.get_frame_height()
	return {"width": width, "height": height, "depth_array": depth_array}

# 初始化：获取传感器帧图像，创建网格模型Called when the node enters the scene tree for the first time.
func _ready():
	
#	thread = Thread.new()
#
#	var callable = Callable(self, "_thread_function")
#	callable.call("hello")  # Prints "hello world ".
#	# Third argument is optional userdata, it can be any variable.
#
#	thread.start(callable, 1)
	
	realsense = $"../Realsense"
	realsense.setup()
	var frame = get_frame()	
	
#	#创建帧图像img
#	img = img.create_from_data(frame.width, frame.height, false, Image.FORMAT_R8, frame.depth_array)FORMAT_LA8
#	img = img.create_from_data(frame.width, frame.height, false, Image.FORMAT_R8, frame.depth_array)
	$"../Node3D".img = img
	img.load("res://test.png")	

	
#func _thread_function():
#	# Print the userdata ("Wafflecopter")
#	print("I'm a thread! Userdata is-----------------: ")
#
func _thread_function(userdata):
	# Print the userdata ("Wafflecopter")
	print("I'm a thread! Userdata is: ", userdata)
# Thread must be disposed (or "joined"), for portability.


func _exit_tree():
	thread.wait_to_finish()
	
func _process(delta):

	var frame = get_frame()	

#	img = img.create_from_data(frame.width, frame.height, false, Image.FORMAT_R8, frame.depth_array)
	img.load("res://test.png")	
	$"../Node3D".img = img
	
	
	var texture = ImageTexture.create_from_image(img)
	img.save_png("image.png")
	
	
	
	img_colormap.load("res://graymapforblender.png")	
	var texture_2 = ImageTexture.new()
	texture_2.create_from_image(img_colormap) 

	
	img_colormap.load("res://4volcono1.png")	
	var texture_1 = ImageTexture.new()
	texture_1.create_from_image(img_colormap) #,0
	
	get_surface_override_material(0).set_shader_parameter("texture_albedo", texture)

