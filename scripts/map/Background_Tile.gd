extends Sprite3D

class_name Background_Tile

func initialize(tex_region: Vector2, img: Texture, position: Vector2, scale : float):
	
	set_up_skin(img)
	region_rect.position = tex_region
	region_rect.size = Vector2(1000 / scale, 1000 / scale)
	self.scale = Vector3(scale, scale, scale)
	translation = Vector3(position.x, 0, -position.y)

func set_up_skin(img: Texture):
	if img != null:
		texture = img
