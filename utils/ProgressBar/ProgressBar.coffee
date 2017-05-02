"use strict";

define () ->

	class ProgressBar

		constructor: (options) ->

			@_scene = options.scene
			return false unless @_scene

			@_scene.addChild @

			@_minValue = options.minValue or 0
			@_maxValue = options.maxValue or 100
			@_progress = options.progress or 0
			@_value = options.value or 0

			if @_progress > 0 then @progress @_progress
			else if @_value > 0 then @value @_value

			colors = options.colors or {}
			@_colors = {

				backgroundColor: colors.backgroundColor or ["#C3BD73", "#DCD9A2"]
				backgroundShadowColor: colors.backgroundShadowColor or "#FFF"

				progress25: colors.progress25 or ["#f27011", "#E36102"]
				progress50: colors.progress50 or ["#f2b01e", "#E3A10F"]
				progress75: colors.progress75 or ["#f2d31b", "#E3C40C"]
				progress100: colors.progress100 or ["#86e01e", "#67C000"]

				progressShadowColor: colors.progressShadowColor or "#000"

				caption: colors.caption or "#B22222"
				captionStroke: colors.captionStroke or "#A11111"

			}

			@_position = options.position or [0, 0]
			@_sizes = options.sizes or [300, 50]
			@_padding = options.padding or 3

			@_rounded = if options.rounded? then options.rounded else true
			@_radius = options.radius or 5

			@_showCaption = if options.showCaption? then options.showCaption else false
			@_caption = options.caption or "Progress: "
			@_font = options.font or "24px Arial"
			@_fontHeight = @_getFontHeight()
			@_strokeCaption = if options.strokeCaption? then options.strokeCaption else true

			@_showProgress = if options.showProgress? then options.showProgress else true

			@needAnimation = true

		setValues: (min, max) ->

			return false if min >= max

			@_minValue = min
			@_maxValue = max
			@needAnimation = true

		progress: (progress) ->

			@_progress = progress
			@_value = progress * @_maxValue / 100
			@_drawProgress = true
			@needAnimation = true

		value: (value) ->

			@_value = value
			@_progress = Math.floor(value * 100 / @_maxValue)
			@_drawProgress = false
			@needAnimation = true

		getProgress: () -> @_progress

		getValue: () -> @_value

		_getFontHeight: () ->

			span = document.createElement "span"
			span.appendChild document.createTextNode("height")
			span.style.cssText = "font: " + @_font + "; white-space: nowrap; display: inline;"
			document.body.appendChild span
			height = span.offsetHeight
			document.body.removeChild span
			return height

		# рисуем пряоугольник со скругленными углами
		_drawRoundedRect: (context, x, y, width, height, radius) ->

			# предварительные вычисления
			pi = Math.PI
			halfpi = pi / 2
			x1 = x + radius
			x2 = x + width - radius
			y1 = y + radius
			y2 = y + height - radius
			# рисуем
			context.moveTo x1, y
			context.lineTo x2, y
			context.arc x2, y1, radius, -halfpi, 0
			context.lineTo x + width, y2
			context.arc x2, y2, radius, 0, halfpi
			context.lineTo x1, y + height
			context.arc x1, y2, radius, halfpi, pi
			context.lineTo x, y1
			context.arc x1, y1, radius, pi, 3 * halfpi

		_setGradient: (context, color1, color2) ->

			gradient = context.createLinearGradient @_padding, @_padding, @_padding, @_sizes[1] - @_padding * 2
			gradient.addColorStop 0, color2
			gradient.addColorStop 0.5, color1
			gradient.addColorStop 1, color2
			context.fillStyle = gradient

		animate: (context) ->

			context.save()

			context.translate @_position[0], @_position[1]

			context.shadowColor = @_colors.backgroundShadowColor
			context.shadowBlur = 3
			context.shadowOffsetX = 0
			context.shadowOffsetY = 0
			@_setGradient context, @_colors.backgroundColor[0], @_colors.backgroundColor[1]

			context.beginPath()
			if @_rounded then @_drawRoundedRect context, 0, 0, @_sizes[0], @_sizes[1], @_radius else context.rect 0, 0, @_sizes[0], @_sizes[1]
			context.strokeStyle = "#000"
			context.stroke()
			context.fill()

			if @_progress <= 25 then color = @_colors.progress25
			else if @_progress <= 50 then color = @_colors.progress50
			else if @_progress <= 75 then color = @_colors.progress75
			else color = @_colors.progress100

			size = Math.floor((@_sizes[0] - @_padding * 2) * @_value / @_maxValue)

			@_setGradient context, color[0], color[1]

			context.shadowColor = @_colors.progressShadowColor

			context.beginPath()
			if @_rounded then @_drawRoundedRect context, @_padding, @_padding, size, @_sizes[1] - @_padding * 2, @_radius else context.rect @_padding, @_padding, size, @_sizes[1] - @_padding * 2
			context.fill()

			context.shadowColor = "rgba(0, 0, 0, 0)"

			text = ""
			text += @_caption if @_showCaption

			if @_showProgress

				text += if @_drawProgress then @_progress + "%" else @_value

			if text.length > 0

				context.fillStyle = @_colors.caption
				context.font = @_font
				width = context.measureText(text).width
				context.textBaseline = "top"
				context.fillText text, (@_sizes[0] - width) / 2, (@_sizes[1] - @_fontHeight) / 2
				
				if @_strokeCaption

					context.lineWidth = 1
					context.strokeStyle = @_colors.captionStroke
					context.strokeText text, (@_sizes[0] - width) / 2, (@_sizes[1] - @_fontHeight) / 2


			@needAnimation = false

			context.restore()