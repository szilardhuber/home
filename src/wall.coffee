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

	length: () ->
		Math.sqrt( Math.pow(@startx - @endx, 2) + Math.pow(@starty - @endy, 2) ) 