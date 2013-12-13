class Parser
	constructor: (text) ->
		@count = 0
		@built = 0
		@objects = []
		@lines = text.split('\n')
		for line, i in @lines
			line = line.trim()
			if line.toLowerCase().substring(0, 2) == '# '
				groupname = line.substring(2, line.length)
				console.log "New group start here #{groupname}"
			if line.trim().toLowerCase() == 'wall'
				if object?
					@objects.push object
				@count++
				object =[]
				object['type'] = 'wall'
			else if object?
				tokens = line.split(':')
				if tokens.length == 2
					object[tokens[0].trim()] = tokens[1].trim()
					#console.log "Property: #{tokens[0].trim()} = #{object[tokens[0].trim()]}"

		if object?
			@objects.push object 

	ended: () ->
		@built >= @count

	get: () ->
		object = @objects[@built]
		#console.log object
		switch object['type']
			when 'wall'
				@built++
				if object['start']?
					coords = object['start'].split(',')
					startx = parseFloat(coords[0].trim())
					starty = parseFloat(coords[1].trim())
				if object['end']?
					coords = object['end'].split(',')
					endx = parseFloat(coords[0].trim())
					endy = parseFloat(coords[1].trim())
				if object['height']?
					height = parseFloat(object['height'].trim())
				if object['width']?
					width = parseFloat(object['width'].trim())
				if startx? and starty? and endx? and endy? and height? and width?
					new Wall(startx, starty, endx, endy, height, width)

class Plan
	# set the scene size
	WIDTH = 400
	HEIGHT = 300

	# set some camera attributes
	VIEW_ANGLE = 45
	ASPECT = WIDTH / HEIGHT
	NEAR = 0.1
	FAR = 10000

	constructor: () ->
		@camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)
		@camera.rotation.x = -0.7
		# the camera starts at 0,0,0
		# so pull it back
		@camera.position.z = 600
		@camera.position.y = 600
		@renderer = new THREE.WebGLRenderer()
		# start the renderer
		@renderer.setSize WIDTH, HEIGHT
		@scene = new THREE.Scene()
		@scene.add @camera
		# create a point light
		@pointLight = new THREE.AmbientLight(0xEEEEEE)

		# set its position
		@pointLight.position.x = 10
		@pointLight.position.y = 50
		@pointLight.position.z = 130

		# add to the scene
		@scene.add @pointLight

		# Floorplan
		@stage = new Kinetic.Stage
			container: floorplan
			width: WIDTH
			height: HEIGHT

		@layer = new Kinetic.Layer
		@stage.add @layer

	reset: () ->
		@layer.removeChildren()
		children = @scene.children[..]
		for child in children
			if child and child.name == "block"
				@scene.remove child

	draw: () ->
		@renderer.render @scene, @camera
		@layer.batchDraw()

	add: (object) ->
		object.mesh.name = "block"
		@scene.add object.mesh
		@layer.add object.polygon
		@draw()

	fitToScreen: () ->
		xMin = 0
		xMax = 0
		yMin = 0
		yMax = 0
		for child in @layer.children
			for point in child.getPoints()
				if xMin > point.x
					xMin = point.x
				if xMax < point.x
					xMax = point.x
				if yMin > point.y
					yMin = point.y
				if yMax < point.y
					yMax = point.y
		scaleY = Math.abs(HEIGHT / (yMax - yMin))
		scaleX = Math.abs(WIDTH / (xMax - xMin))
		@stage.setScaleY(- Math.min(scaleX, scaleY))
		@stage.setScaleX(Math.min(scaleX, scaleY))
		@stage.setOffsetY(yMax)
		@draw()

$ ->
	# set the scene size
	WIDTH = 400
	HEIGHT = 300

	# set some camera attributes
	VIEW_ANGLE = 45
	ASPECT = WIDTH / HEIGHT
	NEAR = 0.1
	FAR = 10000

	plan = new Plan()

	$('body').keypress (event) ->
		switch event.charCode
			when 119 # w - up
				plan.camera.position.z -= 10
			when 97 # a - left
				plan.camera.position.x += 10
			when 115 # s - down
				plan.camera.position.z += 10
			when 100 # d - right
				plan.camera.position.x -= 10
		plan.renderer.render plan.scene, plan.camera

	$('#text').change (event) ->
		plan.reset()
		content = event.target.value
		parser = new Parser(content)
		while !parser.ended()
			plan.add(parser.get())
		#for line in lines
		#	tokens = line.split(',')
		#	if tokens[0].trim().toLowerCase() == 'wall'
		#		object = new Wall(parseInt(tokens[1].trim()), parseInt(tokens[2].trim()), parseInt(tokens[3].trim()), parseInt(tokens[4].trim()), parseInt(tokens[5].trim()), parseInt(tokens[6].trim()))
		#		plan.add object
		plan.fitToScreen()




	# get the DOM element to attach to
	# - assume we've got jQuery to hand
	$container = $("#container")


	# attach the render-supplied DOM element
	$container.append plan.renderer.domElement

	# Call Change manually to load sample
	$('textarea#text').change()

	# draw!
	plan.draw()


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

