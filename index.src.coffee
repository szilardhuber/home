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
			scale: 
				x: 1
				y: -1
			offset:
				x: -50
				y: 250

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
		lines = content.split('\n')
		for line in lines
			tokens = line.split(',')
			if tokens[0].trim().toLowerCase() == 'wall'
				object = new Wall(parseInt(tokens[1].trim()), parseInt(tokens[2].trim()), parseInt(tokens[3].trim()), parseInt(tokens[4].trim()), parseInt(tokens[5].trim()), parseInt(tokens[6].trim()))
				console.log object
				plan.add object



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
		materials = [
			new THREE.MeshBasicMaterial(color: 0xAACC00)
			new THREE.MeshBasicMaterial(color: 0xCCCC00)
			new THREE.MeshBasicMaterial(color: 0xBBCC00)
			new THREE.MeshBasicMaterial(color: 0xAACC00)
			new THREE.MeshBasicMaterial(color: 0xCC0000)
			new THREE.MeshBasicMaterial(color: 0xCCCC00)
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



	length: () ->
		Math.sqrt( Math.pow(@startx - @endx, 2) + Math.pow(@starty - @endy, 2) ) 