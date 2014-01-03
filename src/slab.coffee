class Slab

	geometry: undefined
	sampleMaterial = undefined


	# 
	constructor: (@vertices, @height, color = undefined) ->
		texture = new THREE.Texture @generateTexture(color)
		texture.needsUpdate = true
		material = @getMaterial(texture)

		@mesh = new THREE.Mesh(new @createGeometry(@vertices, @height), material)
		@mesh.castShadow = true
		@mesh.receiveShadow = true
		###
		# TODO display slabs on 2d
		@polygon = new Kinetic.Polygon
			points: [@startx, @starty, @endx, @endy, endx2, endy2, startx2, starty2]
			fill: 'green'
			stroke: 'black'
			strokeWidth: 4
		###


	# Input parameter is an array of vertices and the height
	# We put the points in the vertices of the geometry and we add an additional vertex for each of the originals with the height added to it
	createGeometry: (polygon, height) ->
		geometry = new THREE.Geometry()
		for vertex in polygon
			geometry.vertices.push new THREE.Vector3(vertex.x, vertex.z, vertex.y)
			geometry.vertices.push new THREE.Vector3(vertex.x, vertex.z + height, vertex.y)
		n = geometry.vertices.length / 2
		# Sides
		x = 0
		while x <= (n - 2) * 2
			geometry.faces.push new THREE.Face3(x, x + 1, x + 2)
			geometry.faces.push new THREE.Face3(x + 3, x + 2, x + 1)
			x += 2

		x = (n - 1) * 2
		geometry.faces.push new THREE.Face3(x, x + 1, 0)
		geometry.faces.push new THREE.Face3(1, 0, x + 1)

		# top
		x = 1
		while x <= (n - 2)
			geometry.faces.push new THREE.Face3(((x + 1) * 2) + 1, (x * 2) + 1, 1)
			x++

		# bottom
		x = 1
		while x <= (n - 2)
			geometry.faces.push new THREE.Face3(0, x * 2, (x + 1) * 2)
			x++

		geometry.computeBoundingSphere()
		geometry


	# Utility function for creating a material with a given texture.
	# Used for having different materials for different faces of the mesh and later we only have to change the texture object in the material.
	getMaterial: (texture) ->
		if not Slab.sampleMaterial?
			Slab.sampleMaterial = new THREE.MeshBasicMaterial()
		material = Slab.sampleMaterial.clone()
		material.map = texture
		material.wrapAroud = true
		material


   	# Add custom texture to the Slab.
   	# Currently we only support adding a background color and a rect with a color above it.
   	# This is enough for the current needs but as this method uses a canvas later it could
   	# be extended to arbitrary complexity.
	generateTexture: (color, pattern = undefined, patternColor = undefined) ->
		if not color?
			color = '#FFFFFF'
		# create the canvas that we will draw to and set the size to the size of the wall
		canvas = document.createElement("canvas")
		canvas.width = 100
		canvas.height = 100

		# get context
		context = canvas.getContext("2d")

		# draw the background with the given color. 
		# we draw it full sized on the canvas
		context.fillStyle = color
		context.fillRect 0, 0, canvas.width, canvas.height

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
	#		0 - rear
	#		1 - front
	#		2 - top 
	#		3 - bottom
	#		4 - right
	#		5 - left
	changeTexture: (side, color, pattern = undefined, patternColor = undefined) ->
		texture = new THREE.Texture @generateTexture(color, pattern, patternColor)
		texture.needsUpdate = true
		texture.name = "#{side}-#{color}-#{pattern}"
		@mesh.material.materials[side].map = texture
		@mesh.material.materials[side].needsUpdate = true


	# Returns the length of the Slab. Simple Euclidean distance between start and end.
	length: () ->
		Math.sqrt( Math.pow(@startx - @endx, 2) + Math.pow(@starty - @endy, 2) ) 

