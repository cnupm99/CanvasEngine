"use strict";

define ["Image"], (Image) ->

	class TilingImage extends Image

		# 
		# Изображение, которое замостит указанную область
		# 
		constructor: (options) ->

			super options

			@_rect = options.rect

		# установка области
		setRect: (rect) ->

			@_rect = rect
			@needAnimation = true

		animate: (context) ->

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