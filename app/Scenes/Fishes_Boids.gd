extends Node3D

#@onready var boid_scene = preload("res://Scenes/Farm/boid_fish.tscn")
@onready var boid_carp= preload("res://Animals/one_fish/single_fish.tscn")

@export var numBoids := 3 # Number of boids spawned at the start (int, 0, 1000) (it should be adjustable dynamically).


#分离(避开）行为参数
#分离行为半径1m,1m之外看不见
@export var avoidNeighborDistance :float = 0.30
#分离行为权重Weight for AvoidOthers(seperate) behaviour
@export var avoidOthersFactor : float = 0.25 

#对齐行为参数
#分离行为半径1m,1m之外看不见
@export var alineNeighborDistance :float = 1.0 
#分离行为权重Weight for AvoidOthers(seperate) behaviour
@export var alineFactor : float = 0.05 

#凝聚行为参数
#凝聚行为半径5m,5m之外看不见
@export var cohesionNeighborDistance : float = 2.0
#凝聚行为权重 Weight for flyTowardsCenter behaviour.
@export var cohesionFactor : = 0.02

#越界行为权重
@export var boundFactor : = 0.025

#随机转向权重
@export var steerRandomFactor : = 0.09

#规则的总系数
@export var ruleScalar : = 0.5

@export var maxSpeed : = 1

#20m*1.2M*4.8M 长高宽
@export var tankSize : Vector3 = Vector3(20,0.6,3.4)

@export var maxBound : Vector3 = Vector3(7.8,0.6,4.3)
@export var minBound : Vector3 = Vector3(0.2,0,0.2)


var randomWavelenScalar = 0.6

#运动速度的控制
@export var playSpeed : = 4

#随机运动标识
@export var randomSign : = true

var boids = []
var goalPos = Vector3.ZERO


var x_lower = 0
var x_upper = 8
var y_lower = 0
var y_upper = 0.8
var z_lower = 0
var z_upper = 4.5

#鱼活动的边界 x起点的X坐标，y起点的Y坐标，z值保存X轴方向上的宽度，w值保存Y轴方向上的宽度
var borders : Vector4 = Vector4(0, 0 , 8, 4.5)
var border_coef = 0.95

var internalBorders : Vector4 = border_coef * borders


var topSpeed : = 1
var maxVelocityChange : = 0.1

#var globalVelocityChange : Vector3 = Vector3(0,0,0)

#var terrain_mesh = $"../Terrain".mesh
#var width = terrain_mesh.

@export var img_size : = Vector2(1280,720)
@export var terrain_size := Vector2(8,4.5)

@export var img : Image = Image.new()

@export var img_gradlient : Image = Image.new()

@export var water_depth  := 0.7

func _ready():
	#add_child(mouse_sphere_kinematicbody)
	for i in range(1):
		var new_boid = boid_carp.instantiate()
		add_child(new_boid) # This needs to be done first because boids call get_parent on initBoid()
		var temp = new_boid.init_pos(x_lower+0.2,x_upper-0.2,y_lower,y_upper,z_lower+0.2,z_upper-0.2)
# 不在水中，继续找，
		while true:
			temp = new_boid.init_pos(x_lower+0.2,x_upper-0.2,y_lower,y_upper,z_lower+0.2,z_upper-0.2)
			if !is_pos_in_water(temp,new_boid):
				print("-------------temp--------------------",temp)
				break
		
		new_boid.initBoid(temp)
		print("new_boid.position-----------",new_boid.position)
		print("new_boid.velocity------------------",new_boid.velocity)

func _process(delta):
	var playDelta = playSpeed * delta * 100
	for boid in get_children():
		boid.ownTime += playDelta * 0.0002
#		print("boid.Velocity-----------",boid.velocity)
# randf_range可能取到0或1
		if randf_range(0,1) < 1 :   
# 一个规则，碰到边界改变方向
			ApplyRules(boid,delta)     
#		print("boid.globalVelocityChange-----------",boid.globalVelocityChange)
# 改变速度
		update(boid,delta)     
# 叉积，不共线，看向那个方向
		if boid.velocity.cross(Vector3.UP) != null:
			boid.transform.basis = transform.basis.looking_at(boid.velocity,Vector3.UP)
	pass

func ApplyRules(boid , delta):
#	#五个向量和：避开、对齐、加入、掉头转回、随机转向
#	var avoid = Vector3(0,0,0)
#	var aline = Vector3(0,0,0)
#	var joinin = Vector3(0,0,0)
#	var steerback = Vector3(0,0,0)
#	var steerRandom = Vector3(0,0,0)
#
#	var totalAcceleration = Vector3(0,0,0)
#	var newVelocity = Vector3(0,0,0)
#	var newVelocity_clone = Vector3(0,0,0)
#
#	var boidPosition = Vector3(boid.x, boid.y, boid.z)
#	var difference = Vector3(0,0,0)
#	var distance = 0.0
#	#计算分离转向向量
#	for otherBoid in boids:
#		if boid != otherBoid:
#			var otherBoidPosition = Vector3(otherBoid.x, otherBoid.y, otherBoid.z)
#
#
#			difference = boidPosition - otherBoidPosition
#			distance = boidPosition.distance_to(otherBoidPosition)
#			#print("distance")
#			#print(distance)
#			if(distance < avoidNeighborDistance and distance >0.0):
#				avoid += difference.normalized() * (1- distance/avoidNeighborDistance)
#			if(distance < alineNeighborDistance  and distance >0.0):
#				aline += otherBoid.velocity.normalized() * (1- distance/alineNeighborDistance)
#			if(distance < cohesionNeighborDistance  and distance >0.0):
#				joinin += -difference.normalized() * (1- distance/cohesionNeighborDistance)
#
##	avoid = avoid/avoid.length()
##	aline = aline/aline.length()
##	joinin = joinin/joinin.length()
#
#	avoid = avoid.limit_length(1)
#	aline = aline.limit_length(1)
#	joinin = joinin.limit_length(1)
#
#	totalAcceleration = avoid * avoidOthersFactor + aline * alineFactor * 0.4 + joinin * cohesionFactor 
#
#
#	#游出边界处理
#	if (boidPosition.x >= maxBound.x) : steerback.x = maxBound.x - boidPosition.x
#	elif  (boidPosition.x <= minBound.x) : steerback.x = minBound.x - boidPosition.x
#	if (boidPosition.y >= maxBound.y) :  steerback.y = maxBound.y - boidPosition.y
#	elif  (boidPosition.y <= minBound.y) :steerback.y = (minBound.y - boidPosition.y)*2  #从地底下快速上来
#	if (boidPosition.z >= maxBound.z) : steerback.z = maxBound.z - boidPosition.z
#	elif  (boidPosition.z <= minBound.z) : steerback.z = minBound.z - boidPosition.z
#	#print(steerback)
#
#	if steerback != Vector3(0, 0, 0) :
#		totalAcceleration += steerback * boundFactor
#
#
#	#增加随机性
#	if randomSign :
#		var wavelen = 0.3;
#		var time = boid.ownTime * randomWavelenScalar;
#
#		var time_x = time
#		var time_y = time + 0.1
#		var time_z = time + 0.2
#
#		if (time_x >= boid.cumWavLen.x) :
#			boid.cumWavLen.x += wavelen
#			#boid.randomValues_X.remove_at(0)
#			boid.randomValues_X.pop_front()
#			boid.randomValues_X.push_back(randf())
#
#		if (time_y >= boid.cumWavLen.y) :
#			boid.cumWavLen.y += wavelen
#			boid.randomValues_Y.pop_front()
#			boid.randomValues_Y.push_back(randf())
#
#		if (time_z >= boid.cumWavLen.z) :
#			boid.cumWavLen.z += wavelen
#			boid.randomValues_Z.pop_front()
#			boid.randomValues_Z.push_back(randf())
#
#		steerRandom.x = cubicInterpolate(boid.randomValues_X, fmod(time_x , wavelen) / wavelen ) *2 - 1
#		steerRandom.y = (cubicInterpolate(boid.randomValues_Y, fmod(time_y, wavelen) / wavelen ) *2 - 1 )* 0.2
#		steerRandom.z = cubicInterpolate(boid.randomValues_Z, fmod(time_z, wavelen) / wavelen ) *2 - 1
#
#		if steerRandom != Vector3(0, 0, 0) :
#			totalAcceleration += steerRandom * steerRandomFactor
#
#
#
#
#
#
#	#总加速度
#	#print(totalAcceleration)
#	totalAcceleration = totalAcceleration * delta * ruleScalar *100
#	#print(totalAcceleration)
#
#	#totalAcceleration.y *= 0.8
#	totalAcceleration.y *= 0.0
#
#	newVelocity = boid.velocity
#	newVelocity += totalAcceleration
#	#newVelocity_clone = newVelocity.limit_length(maxSpeed)
#	newVelocity_clone = newVelocity
#	newVelocity_clone = newVelocity_clone * delta * 20
#	newVelocity_clone = newVelocity_clone * delta 	* 5
#	boid.velocity = newVelocity_clone
#	boid.velocity = Vector3(newVelocity_clone.x, 0 , newVelocity_clone.z)
#
#
#
#
##	#更新位置
##	#boid.position = Vector3(boid.x, boid.y, boid.z) + newVelocity_clone
##	boid.position = boidPosition + newVelocity_clone 
##	print(newVelocity_clone)
##	print(boid.position)
##
##
##
##
##	#更新方向
##	boid.look_at(boid.position, Vector3.UP)      #  转向目标，以纵轴旋转
#
##		var up_vector = base.basis * Vector3.UP
##		var base = boids_multi_mesh.multimesh.get_instance_transform(i)
##			base.basis = base.basis.looking_at(
	# 碰到下一位置是边界和不在水中，都改变方向
	boid.bordersF = bordersEffect(boid, delta)
	if boid.border :
		boid.applyVelocityChange(boid.bordersF)
		print("-----------------borders---boid.bordersF--------",boid.bordersF,"--boid.velocity---",boid.velocity)
##
	var waterF =  water_effect(boid, delta)
	if boid.water :
		boid.applyVelocityChange(waterF)
		print("---------------------no---water---waterF--------",waterF,"--boid.velocity---",boid.velocity)

func update(boid, delta):
	boid.velocity += boid.globalVelocityChange
	print("----------boid.globalVelocityChange-----------------",boid.globalVelocityChange)
	print("----------boid.velocity-----------------",boid.velocity)
	# length 计算速度
	if  boid.velocity.length() > topSpeed : 
		print("too fast")
		boid.velocity = topSpeed * boid.velocity.normalized()
#	print("boid.velocity==========================",boid.velocity)
	#boid.transform.origin += boid.velocity
	boid.position += boid.velocity * delta *3
	boid.globalVelocityChange *= 0
		
#	if boid.velocity.cross(Vector3.UP) != null:
#		var new_transform= boid.transform.basis.looking_at(boid.velocity, Vector3.UP)
#		boid.transform = boid.transform.interpolate_with(new_transform, 10 * delta)


# 立方插值 cubic interpolation using Paul Breeuwsma coefficients
func cubicInterpolate(values, x) :
	var x2 = x * x
	var a0 = -0.5 * values[0] + 1.5 * values[1] - 1.5 * values[2] + 0.5 * values[3]
	var a1 = values[0] - 2.5 * values[1] + 2 * values[2] - 0.5 * values[3]
	var a2 = -0.5 * values[0] + 0.5 * values[2]
	var a3 = values[1]
	return a0 * x * x2 + a1 * x2 + a2 * x + a3


#判断一个三维的点，是否落在一个平面的矩形框内 
##鱼活动的边界Borders是一个四元向量: x是起点的X坐标，y是起点的Y坐标，z值保存X轴方向上的宽度，w值保存Y轴方向上的宽度
func inside(Borders , location):
	if (Borders.x <= location.x and location.x<= Borders.x + Borders.z) and (Borders.y <= location.z and location.z <= Borders.y + Borders.w):
		return true
	else:
		return false
		

func bordersEffect(boid , delta):
	var desired : Vector3
	var futureLocation : Vector3
	var location : Vector3
	var velocity : Vector3    
	var velocityChange : Vector3 
	
	location = boid.position
	velocity = boid.velocity
	
	#Predict location 10 (arbitrary choice) frames ahead
	futureLocation = location + velocity*10;
	
	#目标位置
	var target = location
	
	#如果鱼超出了范围，
	if (!inside(internalBorders, futureLocation)): #Go to the opposite direction
		boid.border = true
		if (futureLocation.x < internalBorders.x):
			target.x = borders.x + borders.z
		if (futureLocation.z < internalBorders.y):
			target.z = borders.y + borders.w
		if (futureLocation.x > internalBorders.x + internalBorders.z):
			target.x = borders.x
		if (futureLocation.z > internalBorders.y + internalBorders.w):
			target.z = borders.y
	else :
		boid.border = false
		
	desired = target - location
	desired.normalized()
	desired *= topSpeed

	velocityChange = desired - velocity;
	if 	velocityChange.length() > maxVelocityChange: 
		velocityChange = maxVelocityChange * velocityChange.normalized()
		
	return velocityChange

func water_effect(boid , delta):
	var desired : Vector3
	var velocity = boid.velocity
	var futureLocation = boid.position + velocity*3;
#	var target = boid.position
	# 如果下一个位置不在水中，改变desired
	if !is_pos_in_water(futureLocation,boid):
		# 计算对应灰度图的梯度图
		img_gradlient =  calculateGradientField(img)
		img_gradlient.save_png("image_gradlient.png")
	# img_gradlient 梯度图
		var img_gradlient_futureLocation = coordinates_space2pixel(futureLocation,img_gradlient,terrain_size)
#		print("---------------img_gradlient_futureLocation-------------------",img_gradlient_futureLocation)
		var img_gradlient_target_color  = img_gradlient.get_pixel(img_gradlient_futureLocation.x ,img_gradlient_futureLocation.y)
#		target = Vector3(img_gradlient_target_color.r,0,img_gradlient_target_color.r)
#		print("---------------img_gradlient_target_color-------------------",img_gradlient_target_color)
		desired = Vector3(img_gradlient_target_color.r,0,img_gradlient_target_color.r)
#		if desired = Vector3.ZERO:
			
		print("---------------desired-------------------",desired)
	
#	desired = target - boid.position
	desired.normalized()
	desired *= topSpeed
	var velocityChange = desired - velocity;
	print("--------velocityChange---------",velocityChange)
	if 	velocityChange.length() > maxVelocityChange: 
		velocityChange = maxVelocityChange * velocityChange.normalized()
		
	return velocityChange
	
# 这个点是否在水中
func is_pos_in_water(pos: Vector3,boid):
	if (pos.x < 0):
		pos.x = 0
	if (pos.z < 0):
		pos.z = 0
	if (pos.x > 8):
		pos.x = 8
	if (pos.z > 4.5):
		pos.z = 4.5
		
	var pos_pixel = coordinates_space2pixel(pos,img,terrain_size) # 1280*720 / 8 *4.5
	var pixel = img.get_pixel(pos_pixel.x ,pos_pixel.y)
	print("---------------pixel------------------------",pixel)
	# 0 是纯黑 1 白色
	if pixel.r < 0.3 or pixel.r > 0.4:
		boid.water = false
		return true
	else:
		# 不是水的区域
		boid.water = true
		return false
		
func coordinates_space2pixel(space_coord: Vector3,img,terrain_size)->Vector2:
	# 图片的大小
	var img_size = img.get_size()
	# 图片像素坐标和物体坐标之间的映射,
	var pixel_coord_x =  space_coord.x * (img_size.x / terrain_size.x)
	var pixel_coord_y =  space_coord.z * (img_size.y / terrain_size.y)
	
	# int()：将浮点数舍入到最接近的整数。
	return Vector2(int(pixel_coord_x),int(pixel_coord_y))
	
	
func calculateGradientField(texture: Image) -> Image:
	# Get the image data from the texture
	# PackedByteArray get_data() const 
#	var image_data := texture.get_data()

	# Get the size of the image
	var width := texture.get_width()
	var height := texture.get_height()
	# img = img.create_from_data(frame.width, frame.height, false, Image.FORMAT_R8, frame.depth_array)
	# Create a new image to store the gradient field
#	var gradient_image := Image(width, height, false, Image.FORMAT_GRAYSCALE_ALPHA)
	var gradient_image := Image.create(width, height, false, Image.FORMAT_LA8)
	
	# Loop through each pixel of the image
	for x in range(width):
		for y in range(height):
			# Calculate the gradient for each pixel
#			var gradient_x := calculateGradientX(x, y, image_data, width, height)
			var gradient_x := calculateGradientX(x, y, texture, width, height)
			var gradient_y := calculateGradientY(x, y, texture, width, height)

			# Set the gradient value to the corresponding pixel in the gradient image
			gradient_image.set_pixel(x, y, Color(gradient_x, gradient_y, 0, 1))

	# Update the image data of the gradient texture
#	gradient_image.lock()
	var gradient_image_temp = gradient_image.duplicate()
#	gradient_image.unlock()

	# Create a new texture from the gradient image
#	var gradient_texture := Image.new()
#	gradient_texture.create_from_image(gradient_image)

	# Return the gradient texture
	
	return gradient_image_temp

func calculateGradientX(x: int, y: int, image_data: Image, width: int, height: int) -> float:
	# Calculate the gradient in the x-direction
	var left_index :int = max(x - 1, 0)
	var right_index :int = min(x + 1, width - 1)

	var left_height : = image_data.get_pixel(left_index, y).r
	var right_height : = image_data.get_pixel(right_index, y).r

	return right_height - left_height

func calculateGradientY(x: int, y: int, image_data: Image, width: int, height: int) -> float:
	# Calculate the gradient in the y-direction 
	var top_index :int= max(y - 1, 0) 
	var bottom_index :int = min(y + 1, height - 1) 
	var top_height : = image_data.get_pixel(x, top_index).r 
	var bottom_height  = image_data.get_pixel(x, bottom_index).r 
	return bottom_height - top_height

	
	
	
	
	
