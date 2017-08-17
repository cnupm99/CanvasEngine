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
	#  setRect()
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
			@setRect options.rect

		# 
		# Установка области
		# 
		setRect: (value) ->

			@rect = value or [0, 0, @canvas.width, @canvas.height]
			@needAnimation = true
			@rect

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