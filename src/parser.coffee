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
