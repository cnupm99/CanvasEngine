"use strict";

define ["Image"], (Image) ->

	# 
	# Изображение, которое замостит указанную область
	# 
	# свойства:
	#  
	#  rect:Array - прямоугольник для замастивания
	#  
	# методы:
	# 
	#  animate() - попытка нарисовать объект 
	# 
	class TilingImage extends Image

		constructor: (options) ->

			super options

			# 
			# область замостивания по умолчанию равна размеру контекста
			# 
			# массив вида [int, int, int, int]
			# 
			_rect = 0
			Object.defineProperty @, "rect", {

				get: () -> _rect
				set: (value) ->

					_rect = value or [0, 0, @parent.size[0], @parent.size[1]]
					@needAnimation = true
					_rect

			}
			@rect = options.rect 

		animate: () ->

			return unless @loaded

			# 
			# Начало отрисовки
			# 
			@context.beginPath()

			# 
			# создаем паттерн
			# 
			@context.fillStyle = @context.createPattern @image, "repeat"

			# 
			# рисуем прямоугольник
			# 
			@context.rect @rect[0], @rect[1], @rect[2], @rect[3]

			# 
			# заливаем паттерном
			# 
			@context.fill()

			@context.restore()

			@needAnimation = false