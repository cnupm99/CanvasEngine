"use strict";

define ["base", "Image", "Text", "Graph", "TilingImage"], (base, Image, Text, Graph, TilingImage) ->

	class Scene extends base

		# 
		# Сцена
		# 
		constructor: (options) ->

			super options

			# имя
			@name = options.name

			# имя сцены FPS является зарезервированным
			# не желательно использовать это имя для своих сцен
			# во избежание проблем

			# канвас
			@canvas = document.createElement "canvas"
			@canvas.style.position = "absolute"
			# z индекс
			@setZ options.zIndex

			# контекст
			@context = @canvas.getContext "2d"
			
			# установка опций
			@setTransform options
			# маска отключена
			@_mask = false
			# анимация пока не нужна
			@_needAnimation = false
			# список объектов для анимации
			@_objects = []

		# установка z-индекса
		setZ: (value) ->

			@_zIndex = @_int value
			@canvas.style.zIndex = @_zIndex

		# получить z-индекс
		getZ: () -> @_zIndex

		# добавление объектов в список анимации
		add: (options) ->

			return unless options.type?

			switch options.type

				when "image" then result = new Image options
				when "text" then result = new Text options
				when "graph" then result = new Graph options
				when "tile" 

					# область замостивания по умолчанию равна размеру контекста
					options.rect = [0, 0, @_sizes[0], @_sizes[1]] unless options.rect?
					result = new TilingImage options

			@_objects.push result

			return result

		# поиск объекта по его имени
		get: (objectName) ->

			answer = false

			# перебор всех объектов, пока не встретим нужный
			@_objects.some (_object) -> 

				flag = _object.name == objectName
				answer = _object if flag
				return flag

			return answer

		# удаляем объект по его имени
		remove: (objectName) ->

			index = -1

			# перебор всех объектов, пока не встретим нужный
			@_objects.some (_object, i) -> 

				flag = _object.name == objectName
				index = i if flag
				return flag

			if index > -1

				@_objects.splice index, 1
				return true

			return false

		# добавляем внешний объект в список отображения
		addChild: (_object) ->

			@_objects.push _object
			@_needAnimation = true

		# удалить внешний объект из списка отображения
		removeChild: (_object) ->

			index = -1

			# перебор всех объектов, пока не встретим нужный
			@_objects.some (_object2, i) -> 

				flag = _object2 == _object
				index = i if flag
				return flag

			if index > -1

				@_objects.splice index, 1
				return true

			return false

		# нужна ли анимация
		needAnimation: () ->

			@_needAnimation or @_objects.some (_object) -> _object.needAnimation

		# проверяем, пуста ли точка с данными координатами
		# ВНИМАНИЕ!
		# использовать этот метод ЛОКАЛЬНО нужно осторожно, так как
		# в браузерах на основе chrome будет возникать ошибка безопасности
		# (как будто пытаешься загрузить изображение с другого хоста).
		# В firefox работает и локально без проблем.
		# При загрузке кода на сервер работает во всех браузерах.
		testPoint: (pointX, pointY) ->

			# данные пикселя
			imageData = @context.getImageData pointX, pointY, 1, 1
			# цвет пикселя
			pixelData = imageData.data

			# проверяем нужный метод?
			pixelData.every = Array.prototype.every if not pixelData.every?

			# проверяем все цвета, если 0, значит мимо
			return not pixelData.every (value) -> value == 0

		# установка прямоугольной маски
		# ВНИМАНИЕ!
		# В браузере firefox есть баг (на 25.04.17), а именно:
		# при попытке нарисовать на канве изображение, используя одновременно
		# маску и тень (setMask and setShadow в данном случае), получается
		# странная хрень, а точнее маска НЕ работает в данном случае.
		# Доказательство и пример здесь: http://codepen.io/cnupm99/pen/wdGKBO
		setMask: (x, y, width, height) ->

			if arguments.length < 4

				# если меньше четырех аргументов,
				# просто удаляем маску
				@_mask = false

			else

				@_mask = {

					x: @_int x
					y: @_int y
					width: @_int width
					height: @_int height

				}

			@_needAnimation = true

		# установка опций
		setTransform: (options) ->

			@setSizes options.sizes
			@setPosition options.position
			@setCenter options.center
			@setRotation options.rotation
			@setAlpha options.alpha

		# размер
		setSizes: (sizes) ->

			@_sizes = @_point sizes if sizes?

			@canvas.width = @_sizes[0]
			@canvas.height = @_sizes[1]

			@_needAnimation = true

		# позиция
		setPosition: (position) ->

			@_position = @_point position if position?

			@canvas.style.left = @_position[0]
			@canvas.style.top = @_position[1]

			@_needAnimation = true

		# центр
		setCenter: (center) ->

			@_center = @_point center if center?

			@context.translate @_center[0], @_center[1]

			@_needAnimation = true

		# поворот
		setRotation: (rotation) ->

			@_rotation = @_value rotation if rotation?

			@context.rotation = @_rotation * Math.PI / 180

			@_needAnimation = true

		# прозрачность
		setAlpha: (alpha) ->

			@_alpha = @_value alpha if alpha?

			@context.globalAlpha = @_alpha
			@_needAnimation = true

		# анимация сцены
		animate: () ->

			# очистка контекста
			@context.clearRect 0, 0, @canvas.width, @canvas.height

			# установка маски
			if @_mask

				@context.beginPath()
				@context.rect @_mask.x, @_mask.y, @_mask.width, @_mask.height
				@context.clip()

			# анимация
			@_objects.forEach (_object) => _object.animate @context

			# анимация больше не нужна
			@_needAnimation = false