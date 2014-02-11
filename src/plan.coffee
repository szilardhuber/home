class Plan
	# set the scene size
	WIDTH = 1500
	HEIGHT = 800

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
		@saveImage = false
		@needsUpdate = true

		# the camera starts at 0,0,0
		# so pull it back
		@camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)
		@camera.position = new THREE.Vector3(100, -200, 160)

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
		hemiLight.position.set( 0, 0, 500 )
		@scene.add( hemiLight )

		dirLight = new THREE.DirectionalLight( 0xffffff, 0.4 )
		dirLight.position.set( -0.5, 5, 8 )
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

		@switchViewMode()

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
		if @needsUpdate or @controlsEnabled
			@renderer.render @scene, @camera
			@needsUpdate = false
		if @saveImage
			imageData = @renderer.domElement.toDataURL("image/png").replace("image/png", "image/octet-stream")
			window.location.href = imageData
			@saveImage = false
		@layer.batchDraw()

	add: (object) ->
		object.mesh.name = "block"
		if not @optimize
			@scene.add object.mesh
		else
			for face, i in object.mesh.geometry.faces
				if i % 2 == 0
					@materials.push object.mesh.material.materials[i / 2]
				face.materialIndex = @materials.length - 1
			THREE.GeometryUtils.merge Wall::geometry, object.mesh
		if object.line?
			@layer.add object.line
		if object.polygon?
			@layer.add object.polygon
		@needsUpdate = true

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
		scale = Math.min(scaleX, scaleY) * .90
		@stage.setScaleY(- scale)
		@stage.setScaleX(scale)
		@stage.setOffsetY(yMax + 2)
		@stage.setOffsetX(-20)

	switchViewMode: () ->
		@needsUpdate = true
		if @controlsEnabled
			@controlsEnabled = false
			@savedCameraPosition = @camera.position
			@camera.position = new THREE.Vector3(400, -600, 700)
			@camera.lookAt new THREE.Vector3(400, 0, 0)
		else
			@controlsEnabled = true
			if @savedCameraPosition?
				@camera.position = @savedCameraPosition
			else
				@camera.position = new THREE.Vector3(0, 0, 0)



$ ->
	plan = new Plan()

	$('body').keypress (event) ->
		switch event.charCode
			when 99 # c - switch FPS mode
				plan.switchViewMode()
			when 112 # p - save current canvas as image
				plan.saveImage = true


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

