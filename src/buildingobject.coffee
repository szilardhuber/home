class BuildingObject
	sampleMaterial = undefined
	geometry = undefined

   	# Add custom texture to the wall.
   	# Currently we only support adding a background color and a rect with a color above it.
   	# This is enough for the current needs but as this method uses a canvas later it could
   	# be extended to arbitrary complexity.
	generateTexture: (color = "#cccccc", pattern = undefined, patternColor = undefined) ->
		# create the canvas that we will draw to and set the size to the size of the wall
		canvas = document.createElement("canvas")
		canvas.width = @getLength()
		canvas.height = @getHeight()

		# get context
		context = canvas.getContext("2d")

		# draw the background with the given color. 
		# we draw it full sized on the canvas
		context.fillStyle = Utils.hexToRgba(color)
		context.fillRect 0, 0, @getLength(), @getHeight()
		context.fill()

		# draw foreground rect - TODO I need more than one patterns
		if pattern?
			context.save()
			context.globalCompositeOperation = 'destination-out'
			context.beginPath()
			context.moveTo pattern[0].x, pattern[0].y
			for point in pattern[1..]
				context.lineTo point.x , point.y
			context.closePath()	
			context.fill()
			context.restore()
			
			context.globalCompositeOperation = 'source-over'
			context.fillStyle = Utils.hexToRgba(patternColor)
			context.beginPath()
			context.moveTo pattern[0].x, pattern[0].y
			for point in pattern[1..]
				context.lineTo point.x , point.y
			context.closePath()
			context.fill()

		# return the canvas
		canvas

	# Utility function for creating a material with a given texture.
	# Used for having different materials for different faces of the mesh and later we only have to change the texture object in the material.
	getMaterial: (texture) ->
		if not BuildingObject.sampleMaterial?
			BuildingObject.sampleMaterial = new THREE.MeshLambertMaterial()
		material = BuildingObject.sampleMaterial.clone()
		material.transparent = true
		material.map = texture
		material.wrapAroud = true
		material

	# Change the texture of the given side to the given color.
	# Sides (looking from start -> end direction from above):
	#		0 - bottom
	#		1 - top
	#		2 - right 
	#		3 - rear
	#		4 - left
	#		5 - front
	changeTexture: (side, color, pattern = undefined, patternColor = undefined) ->
		texture = new THREE.Texture @generateTexture(color, pattern, patternColor)
		texture.needsUpdate = true
		texture.name = "#{side}-#{color}-#{pattern}"
		@mesh.material.materials[side].map = texture
		@mesh.material.materials[side].needsUpdate = true
		@mesh.geometry.faces[side * 2].materialIndex = side
		@mesh.geometry.faces[(side * 2) + 1].materialIndex = side
		if pattern?
			@updateUVs(side)

	updateUVs: (side) ->
		if side == 0 or side == 1
			@mesh.geometry.faceVertexUvs[0][side * 2] = [ new THREE.Vector2(0, 0), new THREE.Vector2(1, 0), new THREE.Vector2(1, 1)]
			@mesh.geometry.faceVertexUvs[0][(side * 2) + 1] = [ new THREE.Vector2(1, 1), new THREE.Vector2(0, 1), new THREE.Vector2(0, 0)]
		else
			@mesh.geometry.faceVertexUvs[0][side * 2] = [ new THREE.Vector2(0, 0), new THREE.Vector2(1, 0), new THREE.Vector2(0, 1)]
			@mesh.geometry.faceVertexUvs[0][(side * 2) + 1] = [ new THREE.Vector2(1, 0), new THREE.Vector2(1, 1), new THREE.Vector2(0, 1)]
