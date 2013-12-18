class Point
	constructor: (@x, @y) ->

class Parser
	constructor: (text) ->
		@count = 0
		@built = 0
		@objects = []
		@lines = text.split('\n')
		globals = []
		isInGlobalSection = false
		for line, i in @lines
			line = line.trim()
			if line.substring(0, 2) == '# '
				groupname = line.substring(2, line.length)
				isInGlobalSection = true
				globals = []
			else if isInGlobalSection and line.substring(0, 3) == '## '
				line = line.substring(3, line.length)
				tokens = line.split(':')
				globals[tokens[0].trim()] = tokens[1].trim()
			else if line.trim().toLowerCase() == 'wall'
				isInGlobalSection = false
				if object?
					@objects.push object
				@count++
				object =[]
				object['type'] = 'wall'
				for key of globals
					object[key] = globals[key]
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
					wall = new Wall(startx, starty, endx, endy, height, width)
					if object['rear.color']?
						wall.changeTexture(0, object['rear.color'])
					if object['front.color']?
						wall.changeTexture(1, object['front.color'])
					if object['top.color']?
						wall.changeTexture(2, object['top.color'])
					if object['bottom.color']?
						wall.changeTexture(3, object['bottom.color'])
					if object['right.color']?
						if startx == 44 and starty == 240 and endx == 990 and endy == 240
							pattern = []
							pattern.push new Point(160, 0)
							pattern.push new Point(160, 270)
							pattern.push new Point(260, 270)
							pattern.push new Point(260, 0)
							wall.changeTexture(4, object['right.color'], pattern, "#645143")
						else
							wall.changeTexture(4, object['right.color'])
					if object['left.color']?
						wall.changeTexture(5, object['left.color'])
					wall

class Plan
	# set the scene size
	WIDTH = 600
	HEIGHT = 300

	# set some camera attributes
	VIEW_ANGLE = 75
	ASPECT = WIDTH / HEIGHT
	NEAR = 1
	FAR = 10000

	constructor: () ->

		# start the renderer
		@renderer = new THREE.WebGLRenderer()
		@renderer.setSize WIDTH, HEIGHT
		@renderer.setClearColor( 0xf0f0f0 )
		@renderer.sortObjects = false
		@renderer.shadowMapEnabled = true
		@renderer.shadowMapType = THREE.PCFShadowMap

		# merge the meshes into one geometry
		@optimize = false

		# the camera starts at 0,0,0
		# so pull it back
		@camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)
		@camera.position.z = 600

		# initialize controls
		@controls = new THREE.FirstPersonControls( @camera, @renderer.domElement )
		@controls.movementSpeed = 300
		@controls.lookSpeed = 0.25
		@controls.lookVertical = true
		@controls.dragToLook = true
		@controlsEnabled = true

		# set up the scene
		@scene = new THREE.Scene()
		@scene.add @camera

		# create lights
		hemiLight = new THREE.HemisphereLight( 0xffffff, 0xffffff, 0.9 )
		hemiLight.color.setHSL( 0.6, 0.75, 0.5 )
		hemiLight.groundColor.setHSL( 0.095, 0.5, 0.5 )
		hemiLight.position.set( 0, 500, 0 )
		@scene.add( hemiLight )

		dirLight = new THREE.DirectionalLight( 0xffffff, 1 )
		dirLight.position.set( -1, 0.75, 1 )
		dirLight.position.multiplyScalar( 50)
		dirLight.name = "dirlight"
		# dirLight.shadowCameraVisible = true
		@scene.add( dirLight )
		dirLight.castShadow = true
		dirLight.shadowMapWidth = dirLight.shadowMapHeight = 1024*2
		d = 300
		dirLight.shadowCameraLeft = -d
		dirLight.shadowCameraRight = d
		dirLight.shadowCameraTop = d
		dirLight.shadowCameraBottom = -d
		dirLight.shadowCameraFar = 3500
		dirLight.shadowBias = -0.0001
		dirLight.shadowDarkness = 0.15

		# add plane
		Wall::geometry = new THREE.Geometry
		@materials = []

		@clock = new THREE.Clock()

		# set up 2D floorplan
		@stage = new Kinetic.Stage
			container: floorplan
			width: WIDTH
			height: HEIGHT

		@layer = new Kinetic.Layer
		@stage.add @layer

		# start rendering
		@draw()


	reset: () ->
		@materialIndex = 4
		@layer.removeChildren()
		children = @scene.children[..]
		for child in children
			if child and child.name == "block"
				@scene.remove child

	draw: () =>
		setTimeout ( () => requestAnimationFrame(@draw) ) , 1000 / 30
		if @controlsEnabled
			@controls.update(@clock.getDelta())
		@renderer.render @scene, @camera
		@layer.batchDraw()

	add: (object) ->
		object.mesh.name = "block"
		console.log Wall::geometry.faces.length
		if not @optimize
			@scene.add object.mesh
		else
			for face, i in object.mesh.geometry.faces
				if i % 2 == 0
					@materials.push object.mesh.material.materials[i / 2]
				face.materialIndex = @materials.length - 1
			THREE.GeometryUtils.merge Wall::geometry, object.mesh
		@layer.add object.polygon

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
			when 99 # c - switch FPS mode
				if plan.controlsEnabled
					plan.controlsEnabled = false
					plan.savedCameraPosition = plan.camera.position
					plan.camera.position = new THREE.Vector3(400, 600, 500)
					plan.camera.lookAt new THREE.Vector3(400, 0, 0)
				else
					plan.controlsEnabled = true
					if plan.savedCameraPosition?
						plan.camera.position = plan.savedCameraPosition
					else
						plan.camera.position = new THREE.Vector3(0, 0, 0)


	$('#text').change (event) ->
		plan.reset()
		content = event.target.value
		parser = new Parser(content)
		while !parser.ended()
			plan.add(parser.get())
		mesh = new THREE.Mesh( Wall::geometry, new THREE.MeshFaceMaterial( plan.materials ) )
		mesh.castShadow = true
		mesh.receiveShadow = true
		console.log plan.materials
		plan.scene.add mesh
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

	geometry: undefined
	sampleMaterial = undefined
	# 
	constructor: (@startx, @starty, @endx, @endy, @height, @width) ->
		texture = new THREE.Texture @generateTexture()
		texture.needsUpdate = true
		materials = [ @getMaterial(texture), @getMaterial(texture), @getMaterial(texture), @getMaterial(texture), @getMaterial(texture), @getMaterial(texture)]
		@mesh = new THREE.Mesh(new THREE.CubeGeometry(@length(), @height, @width), new THREE.MeshFaceMaterial(materials))
		@mesh.castShadow = true
		@mesh.receiveShadow = true
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

	# Returns the length of the wall. Simple Euclidean distance between start and end.
	length: () ->
		Math.sqrt( Math.pow(@startx - @endx, 2) + Math.pow(@starty - @endy, 2) ) 

