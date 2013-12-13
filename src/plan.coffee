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

