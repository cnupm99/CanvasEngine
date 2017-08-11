"use strict";

define ["DisplayObject"], (DisplayObject) ->

	class Image extends DisplayObject

		# 
		# Изображение
		# 
		constructor: (options) ->

			# 
			# создаем класс родителя
			# 
			super options

			# 
			# тип объекта
			# 
			@type = "image"

			# 
			# событие, выполняемое при загрузке картинки
			# 
			@onload = options.onload

			# 
			# Загружена ли картинка,
			# в данный момент нет,
			# а значит рисовать ее не нужно
			# 
			@loaded = false
			@needAnimation = false

			# 
			# создаем элемент
			# 
			@image = document.createElement "img"

			# 
			# Событие при загрузке картинки
			# 
			@image.onload = @_imageOnLoad

			# 
			# Здесь будем хранить src картинки как строку.
			# При вызове src картика загружается, а адрес устанавливается в loadedFrom
			# При присвоении loadedFrom картинка не загружается
			# Это просто строка для хранения адреса картинки
			# 
			@loadedFrom = ""

			# 
			# Свойство для загрузки картики
			# Возвращает адрес картинки,
			# но при присвоении загружает ее
			# 
			Object.defineProperty @, "src", {

				get: () -> @loadedFrom
				set: (value) ->

					@loaded = false
					@needAnimation = false
					@loadedFrom = value

					# загружаем
					@image.src = value

			}

			# 
			# нужно ли загружать картинку
			# 
			if options.src?
				
				@src = options.src

			# 
			# или она уже загружена
			# 
			else 

				@from options.from

		# 
		# from = {
		# 
		# 	image: Image
		# 	src: String // не обязательно
		# 	sizes: [Number, Number] // не обязательно
		# 	
		# }
		# 
		from: (from) ->

			# 
			# если картинки нет, то нет смысла продолжать
			# 
			return unless from.image?

			# 
			# а вот и картинка
			# 
			@image = from.image

			# 
			# Запоминаем src
			# 
			@loadedFrom = from.src or ""

			# 
			# запоминаем реальные размеры
			# 
			@realSize = [@image.width, @image.height]

			# 
			# если нужно меняем размеры
			# иначе потом будем масштабировать
			# 
			@size = @realSize if @size[0] <= 0 or @size[1] <= 0

			# можно рисовать
			@loaded = true
			@needAnimation = true

		animate: () ->

			# 
			# если картинка не загружена, то рисовать ее не будем
			# 
			return unless @loaded

			# 
			# действия по умолчанию для DisplayObject
			# 
			super()

			# 
			# рисуем в реальном размере?
			# 
			if @size[0] == @realSize[0] and @size[1] == @realSize[1]

				@context.drawImage @image, @_deltaX, @_deltaY

			else

				# 
				# тут масштабируем картинку
				# 
				@context.drawImage @image, @_deltaX, @_deltaY, @size[0], @size[1]

			@context.restore()

			@needAnimation = false

		_imageOnLoad: (e) =>

			# 
			# запоминаем реальные размеры
			# 
			@realSize = [@image.width, @image.height]

			# 
			# если нужно меняем размеры
			# иначе потом будем масштабировать
			# 
			@size = @realSize if @size[0] <= 0 or @size[1] <= 0

			@loaded = true
			@needAnimation = true

			# 
			# если у картинки есть свойство onload, то вызываем его и
			# сообщаем реальные размеры картинки
			# 
			@onload @realSize if @onload?