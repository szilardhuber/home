class Slab extends BuildingObject


	# 
	constructor: (@vertices, @height, color = undefined) ->
		texture = new THREE.Texture @generateTexture(color)
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

		@mesh = new THREE.Mesh(new @createGeometry(@vertices, @height), new THREE.MeshFaceMaterial(materials))
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
		shape = new THREE.Shape()
		first = true
		for vertex in polygon
			if first
				shape.moveTo vertex.x, vertex.y
				first = false
			else
				shape.lineTo vertex.x, vertex.y
		shape.lineTo polygon[0].x, polygon[0].y
		extrudeSettings = { amount: height }
		extrudeSettings.bevelEnabled = false;
		# extrudeSettings.bevelSegments = 2;
		# extrudeSettings.steps = 2;
		new THREE.ExtrudeGeometry( shape, extrudeSettings );

	getLength: () ->
		100

	getHeight: () ->
		100