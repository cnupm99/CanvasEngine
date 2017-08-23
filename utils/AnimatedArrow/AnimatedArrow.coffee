"use strict";

define () ->

	class AnimatedArrow

		# 
		# options = {
		# 
		# 	 from: Array - point from line
		# 	 to: Array - point to line
		# 	 width: Number - line width
		# 	 style: String - style of line and arrow
		# 	 blockSize: Number - width block in line
		# 	 spaceSize: Number - width space in line
		#
		# }
		# 
		constructor: (options) ->

			# сцена для рисования
			@_scene = options.scene
			return unless options.scene

			@_graph = @_scene.add({ type: "graph" })
			@_arrow = @_scene.add({ type: "graph" })

			# set sizes
			@_blockSize = options.blockSize or 50
			@_spaceSize = options.spaceSize or 20
			# set size and style
			@_width = options.width or 100
			@_style = options.style or "rgb(255, 0, 0)"
			# offset of line animation
			@_offset = @_blockSize + @_spaceSize
			# animation speed
			@_speed = options.speed or 1
			# set arrow sizes
			@_arrowWidth = Math.round @_blockSize
			@_arrowHeight = Math.round @_width

			# set points
			@_from = options.from or [0, 0]
			@_to = options.to or [500, 500]
			@setPoints @_from, @_to			

		# 
		# установка начальной и конечной точки стрелки
		# 
		setPoints: (point1, point2) ->

			# line from point
			@_from = @_scene.pixel point1

			# line to point
			@_to = @_arrowTo = @_scene.pixel point2

			# line to point must be smaller then arrow to point, now do it

			# calc length of line and new length, that smaller
			dx = @_from[0] - @_to[0]
			dy = @_from[1] - @_to[1]
			length = Math.sqrt(dx * dx + dy * dy)
			newlength = length - @_blockSize + 2
			newlength = 0.00001 if newlength == 0

			# calc new line to point
			@_to[0] = @_from[0] - newlength * dx / length
			@_to[1] = @_from[1] - newlength * dy / length

			# calc arrow angle
			dx = 0.00001 if dx == 0
			@_angle = Math.atan dy / dx
			@_angle += Math.PI if dx > 0
			@_angle /= @_scene._PIDIV180

			@_redraw()

		@setTo: (point) -> @setPoints @_from, point

		@setFrom: (point) -> @setPoints point, @_to

		update: () =>

			# update offset
			@_offset -= @_speed
			@_offset = @_blockSize + @_spaceSize if @_offset < 0
			@_redrawLine()

		_redrawLine: () ->

			@_graph.clear()

			# @_graph.beginPath()

			@_graph.strokeStyle @_style
			@_graph.lineWidth @_width
			@_graph.setLineDash [@_blockSize, @_spaceSize]
			@_graph.lineDashOffset = @_offset

			@_graph.moveTo @_from
			@_graph.lineTo @_to
			@_graph.stroke()
			# @_graph.line @_from[0], @_from[1], @_to[0], @_to[1]

		_redraw: () ->

			@_redrawLine()

			###@_arrow.clear()
			@_arrow.lineWidth 1
			@_arrow.setCenter @_arrowTo
			@_arrow.rotate @_angle
			@_arrow.moveTo @_arrowTo[0] - @_arrowWidth, @_arrowTo[1] - @_arrowHeight
			@_arrow.lineTo @_arrowTo[0], @_arrowTo[1]
			@_arrow.lineTo @_arrowTo[0] - @_arrowWidth, @_arrowTo[1] + @_arrowHeight
			@_arrow.lineTo @_arrowTo[0] - @_arrowWidth, @_arrowTo[1] - @_arrowHeight
			@_arrow.fillStyle @_style
			@_arrow.fill()###