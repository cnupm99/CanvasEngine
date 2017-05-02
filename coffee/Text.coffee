"use strict";

define ["DisplayObject"], (DisplayObject) ->

	class Text extends DisplayObject

		constructor: (options) ->

			super options

			# текст
			@_text = options.text or ""
			# шрифт
			@setFont options.font
			# заливка
			@_fillStyle = options.fillStyle or false
			# обводка
			@_strokeStyle = options.strokeStyle or false
			# в это свойство мы складываем ширину текста при его отображении
			# это свойство обновляется только при отображении,
			# так как для этого нужно знать context
			@width = 0

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

			# устанавливаем реальную высоту шрифта в пикселях
			span = document.createElement "span"
			span.appendChild document.createTextNode("height")
			span.style.cssText = "font: " + @_font + "; white-space: nowrap; display: inline;"
			document.body.appendChild span
			@fontHeight = span.offsetHeight
			document.body.removeChild span

			@needAnimation = true

		animate: (context) ->

			super context

			context.font = @_font
			# по умолчанию позиционируем текст по верхнему краю
			context.textBaseline = "top"
			
			if @_fillStyle

				context.fillStyle = @_fillStyle
				context.fillText @_text, @_deltaX, @_deltaY

			if @_strokeStyle

				context.strokeStyle = @_strokeStyle
				context.strokeText @_text, @_deltaX, @_deltaY

			# обновляем ширину текста
			@width = context.measureText(@_text).width

			context.restore()

			@needAnimation = false