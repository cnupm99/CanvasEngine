"use strict";

define () ->

	# 
	# Global functions
	# 	- Element.add (type, params)
	# 	- Element.clr()
	# 

	# 
	# exit if d isset
	# 
	return false if window.d?

	#
	# Element.add function
	# 
	Element.prototype.add = (type = "div", params) ->

		if typeof type != "string"
			params = type
			type = "div"

		r = document.createElement type
		@appendChild r

		for param, value of params
			r[param] = value

		return r

	#
	# Element.clr function
	#
	Element.prototype.clr = () ->

		@removeChild(@lastChild) while @lastChild

		return @

	# Main function
	d = (id) ->
		document.getElementById(id)

	# Global function
	window.d = d