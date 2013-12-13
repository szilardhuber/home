class Wall

	# 
	constructor: (@startx, @starty, @endx, @endy, @height, @width) ->
		texture = new THREE.Texture @generateTexture()
		texture.needsUpdate = true
		uniforms = 
			texture: 
				type: 't'
				value: texture
		attributes = {}

		material = new THREE.ShaderMaterial
			attributes: attributes
			uniforms: uniforms
			vertexShader: document.getElementById( 'vertex_shader' ).textContent
			fragmentShader: document.getElementById( 'fragment_shader' ).textContent



		materials = [
			new THREE.MeshBasicMaterial(color: 0xBBCC00)
			new THREE.MeshBasicMaterial(color: 0xBBCC00)
			new THREE.MeshBasicMaterial(color: 0xBBCC00) # top
			new THREE.MeshBasicMaterial(color: 0xBBCC00)
			material
			new THREE.MeshBasicMaterial(color: 0xCCCC00) # left
		]
		# create the sphere's material
		sphereMaterial = new THREE.MeshFaceMaterial(materials)
		@mesh = new THREE.Mesh(new THREE.CubeGeometry(@length(), @height, @width), sphereMaterial)

		@mesh.rotation.y = Math.atan( (@endy - @starty) / (@endx - @startx) )
		endx2 = @endx + @width * Math.sin(@mesh.rotation.y)
		endy2 = @endy - @width * Math.cos(@mesh.rotation.y)
		startx2 = @startx + @width * Math.sin(@mesh.rotation.y)
		starty2 = @starty - @width * Math.cos(@mesh.rotation.y)
		@mesh.position.x = (endx2 + @startx) / 2
		@mesh.position.z = -(endy2 + @starty) / 2
		@polygon = new Kinetic.Polygon
			points: [@startx, @starty, @endx, @endy, endx2, endy2, startx2, starty2]
			fill: 'green'
			stroke: 'black'
			strokeWidth: 4

	###
# OUTER WALLS
	Wall, 0, -580, 0, 240, 270, 44
	Wall, 44, 240, 990, 240, 270, 44
        Wall, 990, -580, 990, 240, 270, 44 
        Wall, 44, -536, 990, -536, 270, 44
# BATHROOM
	Wall, 315, 196, 315, -60, 270, 10
	Wall, 44, 10, 137, 10, 270, 10
	Wall, 211, 10, 305, 10, 270, 10
	Wall, 137, 0, 137, -60, 270, 10
	Wall, 221, 0, 221, -60, 270, 10
# BEDROOM
        Wall, 315, -150, 315, -536, 270, 10


	# OUTER WALLS
	## height: 270
	## width: 44
	## right.color: #B1E74C
	## start.z: 0
	## end.z: 0
	Wall
		start: 0, -580
		end: 0, 240
	Wall
		start: 44, 240
		end: 990, 240
	Wall
		start: 990, -580
		end: 990, 240
	Wall
		start: 44, -536
		end: 990, -536

	# BATHROOM
	## height: 270
	## width: 10
	## right.color: #B1E74C
	## start.z: 0
	## end.z: 0
	Wall
		start 315, 196
		end: 315, -6§
	Wall
		start: 44, 10
		end: 137, 10
	Wall
		start: 211, 10
		end: 305, 10
	Wall
		start: 137, 0
		end: 137, -60
	Wall
		start: 221, 0
		end: 221, -60

	# BEDROOM
	Wall
		start: 315, -150, 0
		end: 315, -536, 0
		height: 270
		with: 10
		right.color: #B1E74C

   	###

   	# Add custom texture to the wall.
   	# Currently we only support adding a background color and a rect with a color above it.
   	# This is enough for the current needs but as this method uses a canvas later it could
   	# be extended to arbitrary complexity.
	generateTexture: () ->
		# create the canvas that we will draw to and set the size to the size of the wall
		canvas = document.createElement("canvas")
		canvas.width = @length()
		canvas.height = @height

		# get context
		context = canvas.getContext("2d")

		# draw the background with the given color. 
		# we draw it full sized on the canvas
		context.fillStyle = "rgba( 177, 231, 76, 1 )"
		context.fillRect 0, 0, @length(), @height

		# draw foreground rect
		context.fillStyle = "rgba( 100, 81, 67, 1 )"
		context.fillRect 0, 0, @length() / 3, @height

		# return the canvas
		canvas


	length: () ->
		Math.sqrt( Math.pow(@startx - @endx, 2) + Math.pow(@starty - @endy, 2) ) 

