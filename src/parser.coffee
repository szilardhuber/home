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
			# Section header - name of the room
			if line.substring(0, 2) == '# '
				groupname = line.substring(2, line.length)
				isInGlobalSection = true
				globals = []
			# Section global variable
			else if isInGlobalSection and line.substring(0, 3) == '## '
				line = line.substring(3, line.length)
				tokens = line.split(':')
				globals[tokens[0].trim()] = tokens[1].trim()
			# Wall
			else if line.trim().toLowerCase() == 'wall'
				isInGlobalSection = false
				if object?
					@objects.push object
				@count++
				object =[]
				object['type'] = 'wall'
				for key of globals
					object[key] = globals[key]
			# Slab
			else if line.trim().toLowerCase() == 'slab'
				isInGlobalSection = false
				if object?
					@objects.push object
				@count++
				object =[]
				object['type'] = 'slab'
				for key of globals
					object[key] = globals[key]
			else if object?
				tokens = line.split(':')
				if tokens.length == 2
					arrayTyped = false
					name = tokens[0].trim()
					if name.substring(0, 1) == "-"
						arrayTyped = true
						name = name.substring(2, name.length)
					value = tokens[1].trim()
					if not arrayTyped
						object[name] = value
					else 
						if name not of object
							v = []
							object[name] = v
						object[name].push value

		if object?
			@objects.push object 

	ended: () ->
		@built >= @count

	get: () ->
		object = @objects[@built]
		patterns = undefined
		if object['pattern']?
			patterns = {}
			for point in object['pattern']
				values = point.split(',')
				id = parseInt(values[0].trim())
				x = parseInt(values[1].trim())
				y = parseInt(values[2].trim())
				if not patterns[id]?
					patterns[id] = {}
					patterns[id].points = []
				patterns[id].points.push ('x': x, 'y': y)
		if object['patternDetails']?
			for item in object['patternDetails']
				values = item.split(',')
				id = parseInt(values[0].trim())
				color = values[2].trim()
				patterns[id].color = color
		if object['window']?
			for item, i in object['window']
				values = item.split(',')
				x1 = parseInt(values[0].trim())
				y1 = parseInt(values[1].trim())
				x2 = parseInt(values[2].trim())
				y2 = parseInt(values[3].trim())
				if not patterns?
					patterns = {}
				patterns["window#{i}"] = {}
				patterns["window#{i}"].points = []
				patterns["window#{i}"].points.push(('x': x1, 'y': y1))
				patterns["window#{i}"].points.push(('x': x1, 'y': y2))
				patterns["window#{i}"].points.push(('x': x2, 'y': y2))
				patterns["window#{i}"].points.push(('x': x2, 'y': y1))
				patterns["window#{i}"].color = "#99999922"
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
					if object['bottom.color']?
						wall.changeTexture(0, object['bottom.color'], patterns)
					if object['top.color']?
						wall.changeTexture(1, object['top.color'], patterns)
					if object['right.color']?
						wall.changeTexture(2, object['right.color'], patterns)
					if object['rear.color']?
						wall.changeTexture(3, object['rear.color'], patterns)
					if object['left.color']?
						wall.changeTexture(4, object['left.color'], patterns)
					if object['front.color']?
						wall.changeTexture(5, object['front.color'], patterns)
					wall
			when 'slab'
				@built++
				vertices = []
				for vertex in object['point']
					points = vertex.split(',')
					vertices.push new THREE.Vector3(parseInt(points[0].trim()), parseInt(points[1].trim()), parseInt(points[2].trim()))
				slab = new Slab(vertices, 40, object['color'])
				if object['bottom.color']?
					slab.changeTexture(0, object['bottom.color'], patterns)
				if object['top.color']?
					slab.changeTexture(1, object['top.color'], patterns)
				if object['right.color']?
					slab.changeTexture(2, object['right.color'], patterns)
				if object['rear.color']?
					slab.changeTexture(3, object['rear.color'], patterns)
				if object['left.color']?
					slab.changeTexture(4, object['left.color'], patterns)
				if object['front.color']?
					slab.changeTexture(5, object['front.color'], patterns)
				slab

