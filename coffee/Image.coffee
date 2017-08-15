"use strict";

define ["DisplayObject"], (DisplayObject) ->

	class Image extends DisplayObject

		# 
		# Класс для загрузки и отображения изображений
		# 
		# свойства:
		# 
		#  onload: Function - ссылка на функцию, которая должна выполниться после загрузки картинки
		#  loaded: Boolean - загружена ли картинка
		#  image: Image - объект картинки
		#  loadedFrom: String - строка с адресом картинки
		#  
		# методы:
		# 
		#  src(string): загрузка картинки с указанным адресом
		#  from(Object) - создание из уже существующей и загруженной картинки
		#  animate() - попытка нарисовать объект
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
			# нужно ли загружать картинку
			# 
			if options.src?
				
				@src options.src

			# 
			# или она уже загружена
			# 
			else 

				@from options.from

		# 
		# Метод для загрузки картики
		# 
		src: (value) ->

			@loaded = false
			@loadedFrom = value

			# загружаем
			@image.src = value

		# 
		# Создание картинки из уже созданной и загруженной
		# 	
		# 	image: Image
		# 	src: String // не обязательно
		# 
		from: (from, src) ->

			# 
			# если картинки нет, то нет смысла продолжать
			# 
			return unless from?

			# 
			# а вот и картинка
			# 
			@image = from

			# 
			# Запоминаем src
			# 
			@loadedFrom = src or ""

			# 
			# запоминаем реальные размеры
			# 
			@upsize [@image.width, @image.height]

			# 
			# если нужно меняем размеры
			# иначе потом будем масштабировать
			# 
			@resize @realSize if @size[0] <= 0 or @size[1] <= 0

			# можно рисовать
			@loaded = true
			@parent.needAnimation = true

		animate: (context) ->

			# 
			# если картинка не загружена, то рисовать ее не будем
			# 
			return unless @loaded

			# 
			# действия по умолчанию для DisplayObject
			# 
			super context

			# 
			# рисуем в реальном размере?
			# 
			if @size[0] == @realSize[0] and @size[1] == @realSize[1]

				context.drawImage @image, @_deltaX, @_deltaY

			else

				# 
				# тут масштабируем картинку
				# 
				context.drawImage @image, @_deltaX, @_deltaY, @size[0], @size[1]

		_imageOnLoad: (e) =>

			# 
			# запоминаем реальные размеры
			# 
			@upsize [@image.width, @image.height]

			# 
			# если нужно меняем размеры
			# иначе потом будем масштабировать
			# 
			@resize @realSize if @size[0] <= 0 or @size[1] <= 0

			@loaded = true
			@parent.needAnimation = true

			# 
			# если у картинки есть свойство onload, то вызываем его и
			# сообщаем реальные размеры картинки
			# 
			@onload @realSize if @onload?