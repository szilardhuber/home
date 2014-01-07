class Wall

	geometry: undefined
	sampleMaterial = undefined
	# 
	constructor: (@startx, @starty, @endx, @endy, @height, @width) ->
		texture = new THREE.Texture @generateTexture()
		texture.needsUpdate = true
		materials = 
			[ 
				@getMaterial(texture)
				@getMaterial(texture)
				@getMaterial(texture)
				@getMaterial(texture)
				@getMaterial(texture)
				@getMaterial(texture)
			]

		@mesh = new THREE.Mesh(@createGeometry(@startx, @starty, @endx, @endy, @height, @width), new THREE.MeshFaceMaterial(materials))
		console.log @mesh.geometry.faces.length
		@mesh.castShadow = true
		@mesh.receiveShadow = true
		rotation = Math.atan( (@endy - @starty) / (@endx - @startx) )
		endx2 = @endx + @width * Math.sin(rotation)
		endy2 = @endy - @width * Math.cos(rotation)
		startx2 = @startx + @width * Math.sin(rotation)
		starty2 = @starty - @width * Math.cos(rotation)
		@polygon = new Kinetic.Polygon
			points: [@startx, @starty, @endx, @endy, endx2, endy2, startx2, starty2]
			fill: 'green'
			stroke: 'black'
			strokeWidth: 4

	createGeometry: (startx, starty, endx, endy, height, width) ->
		shape = new THREE.Shape()
		rotation = Math.atan( (@endy - @starty) / (@endx - @startx) )
		endx2 = endx + width * Math.sin(rotation)
		endy2 = endy - width * Math.cos(rotation)
		startx2 = startx + width * Math.sin(rotation)
		starty2 = starty - width * Math.cos(rotation)
		shape.moveTo startx, starty
		shape.lineTo endx, endy
		shape.lineTo endx2, endy2
		shape.lineTo startx2, starty2
		shape.lineTo startx, starty
		extrudeSettings = { amount: height }
		extrudeSettings.bevelEnabled = false;
		new THREE.ExtrudeGeometry( shape, extrudeSettings );


	# Utility function for creating a material with a given texture.
	# Used for having different materials for different faces of the mesh and later we only have to change the texture object in the material.
	getMaterial: (texture) ->
		if not Wall.sampleMaterial?
			Wall.sampleMaterial = new THREE.MeshLambertMaterial()
		material = Wall.sampleMaterial.clone()
		material.map = texture
		material.wrapAroud = true
		material


   	# Add custom texture to the wall.
   	# Currently we only support adding a background color and a rect with a color above it.
   	# This is enough for the current needs but as this method uses a canvas later it could
   	# be extended to arbitrary complexity.
	generateTexture: (color = "#cccccc", pattern = undefined, patternColor = undefined) ->
		# create the canvas that we will draw to and set the size to the size of the wall
		canvas = document.createElement("canvas")
		canvas.width = @length()
		canvas.height = @height

		# get context
		context = canvas.getContext("2d")

		# draw the background with the given color. 
		# we draw it full sized on the canvas
		context.fillStyle = color
		context.fillRect 0, 0, @length(), @height

		# draw foreground rect - TODO I need more than one patterns
		if pattern?
			context.fillStyle = patternColor
			context.beginPath()
			context.moveTo pattern[0].x, pattern[0].y
			for point in pattern[1..]
				context.lineTo point.x , point.y
			context.closePath()
			context.fill()

		# return the canvas
		canvas

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
		@mesh.geometry.faceVertexUvs[0][side * 2] = [ new THREE.Vector2(0, 0), new THREE.Vector2(1, 0), new THREE.Vector2(0, 1)]
		@mesh.geometry.faceVertexUvs[0][(side * 2) + 1] = [ new THREE.Vector2(1, 0), new THREE.Vector2(1, 1), new THREE.Vector2(0, 1)]

	# Returns the length of the wall. Simple Euclidean distance between start and end.
	length: () ->
		Math.sqrt( Math.pow(@startx - @endx, 2) + Math.pow(@starty - @endy, 2) ) 

