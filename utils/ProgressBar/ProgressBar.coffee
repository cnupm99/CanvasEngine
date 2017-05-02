"use strict";

define () ->

	class ProgressBar

		constructor: (options) ->

			scene = options.scene
			return false unless scene

			@_position = options.position or [0, 0]
			@_sizes = options.sizes or [300, 50]
			@_padding = options.padding or 3

			@_graph = scene.add {

				type: "graph"
				position: @_position

			}

			colors = options.colors or {}
			@_colors = {

				backgroundColor: colors.backgroundColor or ["#C3BD73", "#DCD9A2"]
				backgroundShadowColor: colors.backgroundShadowColor or "#FFF"
				strokeColor: colors.strokeColor or "#000"

				progress25: colors.progress25 or ["#f27011", "#E36102"]
				progress50: colors.progress50 or ["#f2b01e", "#E3A10F"]
				progress75: colors.progress75 or ["#f2d31b", "#E3C40C"]
				progress100: colors.progress100 or ["#86e01e", "#67C000"]

				progressShadowColor: colors.progressShadowColor or "#000"

				caption: colors.caption or "#B22222"
				captionStroke: colors.captionStroke or "#A11111"

			}

			@_rounded = if options.rounded? then options.rounded else true
			@_radius = options.radius or 5

			@_showCaption = if options.showCaption? then options.showCaption else false
			@_showProgress = if options.showProgress? then options.showProgress else true
			@_caption = options.caption or "Progress: "
			strokeCaption = if options.strokeCaption? then options.strokeCaption else true
			if @_showCaption or @_showProgress

				@_text = scene.add {

					type: "text"
					font: options.font or "24px Arial"
					fillStyle: @_colors.caption
					strokeStyle: if strokeCaption then @_colors.captionStroke else false
					position: @_position

				}

			@_minValue = options.minValue or 0
			@_maxValue = options.maxValue or 100
			@_progress = options.progress or 0
			@_value = options.value or 0

			if @_progress > 0 then @progress @_progress
			else if @_value > 0 then @value @_value

		setValues: (min, max) ->

			return false if min >= max

			@_minValue = min
			@_maxValue = max
			@_animate()

		progress: (progress) ->

			@_progress = progress
			@_value = progress * @_maxValue / 100
			@_drawProgress = true
			@_animate()

		value: (value) ->

			@_value = value
			@_progress = Math.floor(value * 100 / @_maxValue)
			@_drawProgress = false
			@_animate()

		getProgress: () -> @_progress

		getValue: () -> @_value

		_animate: () ->

			@_graph.clear()
			@_graph.setShadow {

				color: @_colors.backgroundShadowColor
				blur: 3
				offset: 0

			}
			@_graph.linearGradient 0, 0, 0, @_sizes[1], [

				[0, @_colors.backgroundColor[0]]
				[0.5, @_colors.backgroundColor[1]]
				[1, @_colors.backgroundColor[0]]

			]
			@_graph.strokeStyle @_colors.strokeColor
			@_graph.lineWidth 1

			@_graph.rect 0, 0, @_sizes[0], @_sizes[1], @_radius
			@_graph.fill()
			@_graph.stroke()

			if @_progress <= 25 then color = @_colors.progress25
			else if @_progress <= 50 then color = @_colors.progress50
			else if @_progress <= 75 then color = @_colors.progress75
			else color = @_colors.progress100

			size = Math.floor((@_sizes[0] - @_padding * 2) * @_value / @_maxValue)

			@_graph.setShadow {

				color: @_colors.progressShadowColor
				blur: 3
				offset: 0

			}
			@_graph.linearGradient @_padding, @_padding, @_padding, @_sizes[1] - @_padding, [

				[0, color[0]]
				[0.5, color[1]]
				[1, color[0]]

			]

			@_graph.rect @_padding, @_padding, size, @_sizes[1] - @_padding * 2, @_radius
			@_graph.fill()

			if @_text?

				text = ""
				text += @_caption if @_showCaption

				if @_showProgress

					text += if @_drawProgress then @_progress + "%" else @_value

				@_text.setText text
				@_text.setPosition [@_position[0] + (@_sizes[0] - @_text.width) / 2, @_position[1] + (@_sizes[1] - @_text.fontHeight) / 2]