"use strict";

define ["DisplayObject"], (DisplayObject) ->

	class Image extends DisplayObject

		# 
		# Изображение
		# 
		constructor: (options) ->

			super options

			# событие, выполняемое при загрузке картинки
			@onload = options.onload

			# загрузка или создание картинки
			if options.src?

				# создаем элемент
				@_image = document.createElement "img"
				# картинка не загружена
				@needAnimation = false
				@_loaded = false
				# загружаем картинку
				@setSrc options.src

			# картинка уже есть
			else @from options.from

		# загрузка картинки
		setSrc: (src) ->

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

				# если у картинки есть свойство onload, то вызываем его и
				# сообщаем реальные размеры картинки
				@onload @_realSizes if @onload?

			@_image.src = src

		# 
		# options.from = {
		# 
		# 	image: Image
		# 	src: String
		# 	sizes: [Number, Number]
		# 	
		# }
		# 
		from: (from) ->

			@_image = from.image
			# получаем ее путь
			@_src = from.src
			# размеры
			@_realSizes = from.sizes
			# если нужно меняем размеры
			# иначе потом будем масштабировать
			@_sizes = @_realSizes if (@_sizes[0] <= 0) or (@_sizes[1] <= 0)
			# можно рисовать
			@_loaded = true
			@needAnimation = true

		# вешаем событие на изображение
		addEvent: (eventName, func) -> @_image.addEventListener eventName, func
		# убираем событие с изображения
		removeEvent: (eventName, func) -> @_image.removeEventListener eventName, func

		# возвращаем размер
		getSizes: () -> @_sizes
		# реальный размер картинки
		getRealSizes: () -> @_realSizes

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