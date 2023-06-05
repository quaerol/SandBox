extends Node3D

@export var d = 0.1
@export var velocity = Vector3(0,0,0)


var cumWavLen = Vector3(0,0,0)
var ownTime = 0

#鱼的位置是否超过边界
@export var border : bool = false
@export var bordersF : Vector3
@export var globalVelocityChange : Vector3 = Vector3(0,0,0)

func applyVelocityChange(velocityChange):
	globalVelocityChange += velocityChange


func initBoid(x_lower,x_upper,y_lower,y_upper,z_lower,z_upper):
	var x = randf_range(x_lower,x_upper)
	var y = randf_range(y_lower,y_upper)
	var z = randf_range(z_lower,z_upper)
	print(x," ", y," ", z," ")
#
	velocity = Vector3(randf_range(0, d), 0, randf_range(0, d))	
	#velocity = Vector3(0, 0, 0)
	position = Vector3(x,y,z)
	transform.basis = transform.basis.looking_at(velocity,Vector3.UP)

	return self

func _process(_delta):

	pass
