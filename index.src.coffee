$ ->
	# set the scene size
	WIDTH = 400
	HEIGHT = 300

	# set some camera attributes
	VIEW_ANGLE = 45
	ASPECT = WIDTH / HEIGHT
	NEAR = 0.1
	FAR = 10000

	camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)
	camera.rotation.x = -0.7

	$('body').keypress (event) ->
		switch event.charCode
			when 119
				camera.position.z -= 10
			when 115
				camera.position.z += 10
			when 97
				camera.position.x += 10
			when 100
				camera.position.x -= 10
		renderer.render scene, camera


	# get the DOM element to attach to
	# - assume we've got jQuery to hand
	$container = $("#container")

	# create a WebGL renderer, camera
	# and a scene
	renderer = new THREE.WebGLRenderer()
	scene = new THREE.Scene()

	# add the camera to the scene
	scene.add camera

	# the camera starts at 0,0,0
	# so pull it back
	camera.position.z = 600
	camera.position.y = 600

	# start the renderer
	renderer.setSize WIDTH, HEIGHT

	# attach the render-supplied DOM element
	$container.append renderer.domElement

	objects = []
	objects[0] = new Wall(0, 240, 270, 240, 270, 44)
	objects[1] = new Wall(0, 0, 0, 240, 270, 44)
	objects[2] = new Wall(270, 240, 270, 0, 270, 10)

	# add the wall to the scene
	for object in objects
		scene.add object.mesh

	# create a point light
	pointLight = new THREE.AmbientLight(0xEEEEEE)

	# set its position
	pointLight.position.x = 10
	pointLight.position.y = 50
	pointLight.position.z = 130

	# add to the scene
	scene.add pointLight

	# draw!
	renderer.render scene, camera

	# Floorplan
	stage = new Kinetic.Stage
		container: floorplan
		width: WIDTH
		height: HEIGHT
		scale: 
			x: 1
			y: -1
		offset:
			x: -50
			y: 250
	
	layer = new Kinetic.Layer

	for object in objects
		layer.add object.polygon

	stage.add layer
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
		@mesh.position.x = (@startx + @endx) / 2 + (@width / 2)
		@mesh.position.z = -((@starty + @endy) / 2 + (@width / 2))
		@mesh.rotation.y = Math.atan( (@endy - @starty) / (@endx - @startx) )
		endx2 = @endx + @width * Math.sin(@mesh.rotation.y)
		endy2 = @endy - @width * Math.cos(@mesh.rotation.y)
		startx2 = @startx + @width * Math.sin(@mesh.rotation.y)
		starty2 = @starty - @width * Math.cos(@mesh.rotation.y)
		@polygon = new Kinetic.Polygon
			points: [@startx, @starty, @endx, @endy, endx2, endy2, startx2, starty2]
			fill: 'green'
			stroke: 'black'
			strokeWidth: 4



	length: () ->
		Math.sqrt( Math.pow(@startx - @endx, 2) + Math.pow(@starty - @endy, 2) ) 