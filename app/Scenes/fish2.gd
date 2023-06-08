extends Node3D

@export var d = 0.1

@export var velocity = Vector3(0,0,0)

var cumWavLen = Vector3(0,0,0)
var ownTime = 0

#鱼的位置是否超过边界
@export var border : bool
@export var bordersF : Vector3
@export var water : bool
@export var globalVelocityChange : Vector3 = Vector3(0,0,0)

func applyVelocityChange(velocityChange):
	globalVelocityChange += velocityChange
#	var speed =   velocity.length()
#	velocity =  velocityChange * speed;

func initBoid(pos:Vector3):
#	self.global_position = pos
	position = pos
	velocity = Vector3(randf_range(0, d), 0, randf_range(0, d))	
	
	transform.basis = transform.basis.looking_at(velocity,Vector3.UP)
	
func init_pos(x_lower,x_upper,y_lower,y_upper,z_lower,z_upper):
	var x = randf_range(x_lower,x_upper)
	var y = randf_range(y_lower,y_upper)
	var z = randf_range(z_lower,z_upper)
#	print(x," ", y," ", z," ")
	return Vector3(x,y,z)
#
func _process(_delta):

	pass
