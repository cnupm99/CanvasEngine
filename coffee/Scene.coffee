"use strict";

define ["DisplayObject", "Image", "Text", "Graph", "TilingImage"], (DisplayObject, Image, Text, Graph, TilingImage) ->

	class Scene extends DisplayObject

		# 
		# Сцена
		# 
		constructor: (options) ->

			# 
			# элемент для добавления канваса
			# всегда должен быть
			# 
			@stage = options.stage or document.body
			
			# 
			# создаем канвас
			# 
			@canvas = document.createElement "canvas"
			@canvas.style.position = "absolute"
			@stage.appendChild @canvas

			# 
			# контекст
			# 
			@context = @canvas.getContext "2d"

			# 
			# создаем DisplayObject
			# 
			super options

			# 
			# тип объекта
			# 
			@type = "scene"

			# 
			# индекс, определяющий порядок сцен, чем выше индекс, тем выше сцена над остальными
			# целое число >= 0
			# 
			Object.defineProperty @, "zIndex", {

				get: () -> _zIndex
				set: (value) -> 

					_zIndex = @int value
					@canvas.style.zIndex = _zIndex
					_zIndex

			}
			@zIndex = @int options.zIndex

			# 
			# анимация пока не нужна (сцена пуста)
			# 
			@needAnimation = false

		# 
		# создание и добавление дочерних объектов в список анимации
		# 
		add: (options) ->

			# 
			# нет типа - нечего создавать
			# 
			return unless options.type?

			# 
			# если нужно, задаем значения по умолчанию
			# 
			options.visible = @visible unless options.visible?
			options.position = @position unless options.position?
			options.size = @sizes unless options.size?
			options.center = @center unless options.center?
			options.rotation = @rotation unless options.rotation?
			options.alpha = @alpha unless options.alpha?
			options.mask = @mask unless options.mask?
			options.shadow = @shadow unless options.shadow?

			# 
			# передаем себя, как родителя
			# 
			options.parent = @

			# 
			# создание объекта
			# 
			switch options.type

				when "image" then result = new Image options
				when "text" then result = new Text options
				when "graph" then result = new Graph options
				when "tile" then result = new TilingImage options

			# 
			# добавляем в список дочерних объектов
			# 
			@childrens.push result

			# 
			# возвращаем результат
			# 
			return result

		# 
		# анимация сцены
		# 
		animate: () ->

			# 
			# очистка контекста
			# 
			@context.clearRect 0, 0, @canvas.width, @canvas.height

			# 
			# установка маски
			# 
			if @mask

				@context.beginPath()
				@context.rect @mask.x, @mask.y, @mask.width, @mask.height
				@context.clip()

			# 
			# анимация
			# 
			@childrens.forEach (child) -> child.animate()

			# 
			# анимация больше не нужна
			# 
			@needAnimation = false

		# 
		# Далее функции, перегружающие свойсва экранного объекта,
		# т.к. нам нужно в этом случае двигать, поворачивать и т.д. сам канвас
		# 

		_setPosition: () ->

			super()

			# 
			# двигаем канвас по экрану
			# 
			@canvas.style.left = @position[0] + "px"
			@canvas.style.top = @position[1] + "px"

			@position

		_setSize: () ->

			super()

			# 
			# меняем размер канваса
			# 
			@canvas.width = @size[0]
			@canvas.height = @size[1]

			@size

		_setCenter: () ->

			super()

			# 
			# сдвигаем начало координат в центр
			# 
			@context.translate @center[0], @center[1]

			@center

		_setRotation: () ->

			super()

			# 
			# поворот всего контекста на угол
			# 
			@context.rotate @deg2rad(@rotation)

			@rotation

		_setAlpha: () ->

			super()

			@context.globalAlpha = @alpha
			@alpha