shader_type spatial;
//shader_type canvas_item;
uniform sampler2D texture_albedo ;
uniform sampler2D ColorMapSampler;
//
//varying vec3 color;


//水效果参变量
uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;
uniform float metallic : hint_range(0.0, 1.0) = 0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;
uniform sampler2D wave;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap; // 新增加语句
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap; // 新增加语句

uniform vec2 wave_direction = vec2(2.0,0.0); // Direction of wave 1
uniform vec2 wave_direction2 = vec2(0.0,1.0); // Direction of wave 2
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.025; // Rate of movement multiplied by TIME
uniform float noise_scale = 10.0;
uniform float height_scale = 0.15;

uniform vec4 color_deep : source_color; // Deep depth color
uniform vec4 color_shallow : source_color; // Shallow depth color
uniform float beers_law = 2.0; // Beer's law application
uniform float depth_offset = -0.75; // Offset

uniform float edge_scale = 0.1;
uniform float near = 1.0;
uniform float far = 100.0;
uniform vec3 edge_color : source_color;

// Varying variables
varying float height;
varying vec3 world_pos;


//雪效果参变量
varying vec2 floor_uv;
varying float edge_1;
varying float height_1;
uniform float snow_height = 0.3;

uniform sampler2D color_sample;
uniform sampler2D normal_sample;
uniform sampler2D roughness_sample;






//水效果中间函数
float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}
float edge(float depth){
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}







//顶点着色
void vertex() {
	
	float depth = texture(texture_albedo, UV).r;
//
//	vec4 tempVec4=texture(ColorMapSampler,vec2(depth,0.5));
//
//	vec3 colorDic = vec3(tempVec4.x,tempVec4.y, tempVec4.z);
//
//	color = colorDic;
	//水效果
	if(depth < 0.2)
	{
		world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
		height = texture(wave, world_pos.xz / noise_scale + TIME * time_scale).r;
		VERTEX.y += height * height_scale;

	}
	
	//雪效果
//	if(depth > 0.5)
//		vec2 edges = abs(UV - vec2(0.5,0.5)) * 2.0;
//	    float maxDist  = max(abs(edges.x), abs(edges.y));
//	    float circular = length(edges);
//	    float square   = maxDist;
//	    edge_1 = smoothstep(mix(circular,square,maxDist), 1.25, 1.0);
//
//		floor_uv = vec2(VERTEX.x - player_position.x, VERTEX.z - player_position.z);
//		float ratio = 1.0 / 40.0; 
//		floor_uv *= vec2(ratio, -ratio);
//		floor_uv -= vec2(0.5);
//
//		height_1 = 1.0 - texture(player_trail, floor_uv).r;
//		height_1 *= edge_1;
//
//		VERTEX.y += snow_height * height_1;
//
//		vec2 texture_increment = 1.0 / vec2(textureSize(player_trail, 0));
//
//		// The following calculations for surface normal information are 
//		// Approximate derivative along the z axis
//		float height_up = 1.0 - texture(player_trail, floor_uv + vec2(0.0, texture_increment.y)).a;
//		float height_down = 1.0 - texture(player_trail, floor_uv + vec2(0.0, -texture_increment.y)).a;
//		// Approximate derivative along the x axis
//		float height_left = 1.0 - texture(player_trail, floor_uv + vec2(-texture_increment.x, 0.0)).a;
//		float height_right = 1.0 - texture(player_trail, floor_uv + vec2(texture_increment.x, 0.0)).a;
//
//		BINORMAL = normalize(vec3(1.0, height_right - height_left, 0.0));
//		TANGENT = normalize(vec3(0.0, height_up - height_down, 1.0));
//		NORMAL = normalize(cross(TANGENT, BINORMAL));
//	}

}


//片元像素着色
void fragment() {
	vec2 base_uv = UV;
	//vec4 albedo_tex = texture(texture_albedo,base_uv);
	float depth = texture(texture_albedo,base_uv).r;
	//VERTEX.z = depth;
	//VERTEX.z = 0.4;
	//对应在色卡上的颜色
	vec4 tempVec4=texture(ColorMapSampler,vec2(depth,0.5));
	//vec4 tempVec4=texture(ColorMapSampler,vec2(depth,0.5));
	//vec4 tempVec4=vec4(0.4,0.8, 0.9, 1.0);
	//vec3 colorDic = vec3(tempVec4.x+0.6,tempVec4.y+0.3, tempVec4.z+0.3);
	//vec3 colorDic = vec3(depth,depth, depth);
	//vec3 colorDic = vec3(0.4,0.8, 0.9);
	
    //COLOR = tempVec4;
     //ALBEDO = colorDic;
	 //ALBEDO = vec3(depth,depth, depth);
	ALBEDO =  vec3(tempVec4.x,tempVec4.y, tempVec4.z);
	
	
	
	
	
	//ALBEDO = albedo.rgb * albedo_tex.rgb;


	if(depth < 0.2)
	{


		// Depth variables and calc
		float depth_texture = texture(DEPTH_TEXTURE, SCREEN_UV).r * 2.0 - 1.0;
		float depth = PROJECTION_MATRIX[3][2] / (depth_texture + PROJECTION_MATRIX[2][2]);
		float depth_blend = exp((depth+VERTEX.z + depth_offset) * -beers_law);
		depth_blend = clamp(1.0 - depth_blend, 0.0, 1.0);	
		float depth_blend_power = clamp(pow(depth_blend, 2.5), 0.0, 1.0);

		// Retrieving depth color and applying the deep and shallow colors
		vec3 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, depth_blend_power * 2.5).rgb;
		vec3 depth_color = mix(color_shallow.rgb, color_deep.rgb, depth_blend_power);
		vec3 color = mix(screen_color * depth_color, depth_color * 0.25, depth_blend_power * 0.5);
		
		// Getting edge depth calc
		float z_depth = edge(texture(DEPTH_TEXTURE, SCREEN_UV).x);
		float z_pos = edge(FRAGCOORD.z);
		float z_dif = z_depth - z_pos;
		
		// Time calculations for wave (normal map) movement
		vec2 time = (TIME * wave_direction) * time_scale; // Movement rate of first wave
		vec2 time2 = (TIME * wave_direction2) * time_scale; // Movement rate of second wave
		
		// Blend normal maps into one
		vec3 normal_blend = mix(texture(texture_normal,world_pos.xz + time).rgb, texture(texture_normal2,world_pos.xz + time2).rgb, 0.5);
		
		// Calculate Fresnel
		float fresnel = fresnel(5.0, NORMAL, VIEW);
		vec3 surface_color = mix(albedo, albedo2, fresnel); // Interpolate albedo values by frensel
		
		vec3 depth_color_adj = mix(edge_color, color, step(edge_scale, z_dif));

		ALBEDO = clamp(surface_color + depth_color_adj,vec3(0.0),vec3(1.0));
		METALLIC = metallic;
		ROUGHNESS = roughness;
		NORMAL_MAP = normal_blend;
	
	
	}
	
	if(depth > 0.7)
	{

		//ALBEDO = texture(color_sample, UV).rgb * 1.0 * 0.5;
		ALBEDO = texture(color_sample, UV).rgb ;
		ROUGHNESS = texture(roughness_sample, UV).r;
		NORMAL_MAP = texture(normal_sample, UV).rgb;
	}
}