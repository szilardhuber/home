class Parser
	constructor: (text) ->
		@count = 0
		@built = 0
		@objects = []
		@lines = text.split('\n')
		for line, i in @lines
			line = line.trim()
			if line.toLowerCase().substring(0, 2) == '# '
				groupname = line.substring(2, line.length)
				console.log "New group start here #{groupname}"
			if line.trim().toLowerCase() == 'wall'
				if object?
					@objects.push object
				@count++
				object =[]
				object['type'] = 'wall'
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
		#console.log object
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
					new Wall(startx, starty, endx, endy, height, width)
