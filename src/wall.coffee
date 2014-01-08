class Wall extends BuildingObject

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


	# Returns the length of the wall. Simple Euclidean distance between start and end.
	getLength: () ->
		Math.sqrt( Math.pow(@startx - @endx, 2) + Math.pow(@starty - @endy, 2) ) 

	getHeight: () ->
		@height