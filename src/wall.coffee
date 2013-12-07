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
   	###

	length: () ->
		Math.sqrt( Math.pow(@startx - @endx, 2) + Math.pow(@starty - @endy, 2) ) 