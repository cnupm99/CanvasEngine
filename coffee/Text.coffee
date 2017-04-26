"use strict";

define ["DisplayObject"], (DisplayObject) ->

	class Text extends DisplayObject

		constructor: (options) ->

			super options

			# текст
			@_text = options.text or ""
			# шрифт
			@_font = options.font or "12px Arial"
			# заливка
			@_fillStyle = options.fillStyle or false
			# обводка
			@_strokeStyle = options.strokeStyle or false

			@needAnimation = true

		setText: (text) ->

			@_text = text
			@needAnimation = true

		fillStyle: (style) ->

			@_fillStyle = style or false
			@needAnimation = true

		strokeStyle: (style) ->

			@_strokeStyle = style or false
			@needAnimation = true

		setFont: (font) ->

			@_font = font or "12px Arial"
			@needAnimation = true

		animate: (context) ->

			super context

			context.font = @_font
			
			if @_fillStyle

				context.fillStyle = @_fillStyle
				context.fillText @_text, @_deltaX, @_deltaY

			if @_strokeStyle

				context.strokeStyle = @_strokeStyle
				context.strokeText @_text, @_deltaX, @_deltaY

			context.restore()

			@needAnimation = false