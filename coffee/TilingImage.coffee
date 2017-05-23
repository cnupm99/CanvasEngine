"use strict";

define ["Image"], (Image) ->

	class TilingImage extends Image

		# 
		# Изображение, которое замостит указанную область
		# 
		constructor: (options) ->

			super options

			# область замостивания по умолчанию равна размеру контекста
			@_rect = options.rect or [0, 0, options.parent.sizes[0], options.parent.sizes[1]]

		# установка области
		setRect: (rect) ->

			@_rect = rect
			@needAnimation = true

		animate: (context = @_context) ->

			return unless @_loaded

			super context

			# создаем паттерн
			context.fillStyle = context.createPattern @_image, "repeat"
			# рисуем прямоугольник
			context.rect @_rect[0], @_rect[1], @_rect[2], @_rect[3]
			# заливаем паттерном
			context.fill()

			context.restore()

			@needAnimation = false