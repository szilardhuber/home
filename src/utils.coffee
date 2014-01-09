class Utils
	@hexToRgba: (hex) ->
		r = parseInt(hex.substring(1, 3), 16)
		g = parseInt(hex.substring(3, 5), 16)
		b = parseInt(hex.substring(5, 7), 16)
		if hex.length > 7
			a = parseFloat(hex.substring(7, 9), 16) / 255
		else
			a = 1
		"rgba( #{r}, #{g}, #{b}, #{a}"
