"use strict";

define ["DisplayObject"], (DisplayObject) ->

	class Image extends DisplayObject

		# 
		# Изображение
		# 
		constructor: (options) ->

			super options

			# реальные размеры по умолчанию
			@_realSizes = [100, 100]
			@needAnimation = false

			# создаем элемент
			@_image = document.createElement "img"

			@setSrc options.src

		# загрузка картинки
		setSrc: (src, local = true) ->

			# не загружена
			@_loaded = false

			@_image.onload = () => 

				# запоминаем реальные размеры
				@_realSizes = [@_image.width, @_image.height]

				# если нужно меняем размеры
				# иначе потом будем масштабировать
				@_sizes = @_realSizes if (@_sizes[0] <= 0) or (@_sizes[1] <= 0)

				@needAnimation = true

				@_loaded = true

			@_image.src = src

		animate: (context) ->

			return unless @_loaded

			super context

			# в реальном размере
			if (@_sizes[0] == @_realSizes[0]) and (@_sizes[1] == @_realSizes[1])

				context.drawImage @_image, @_deltaX, @_deltaY

			else

				# в масштабе
				context.drawImage @_image, @_deltaX, @_deltaY, @_sizes[0], @_sizes[1]

			context.restore()

			@needAnimation = false