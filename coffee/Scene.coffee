"use strict";

define ["DisplayObject", "Image", "Text", "Graph", "TilingImage"], (DisplayObject, Image, Text, Graph, TilingImage) ->

	class Scene extends DisplayObject

		# 
		# Класс сцены, на который добавляются все дочерние объекты
		# Фактически представляет собой canvas
		# 
		# свойства:
		# 
		#  stage: Element - родительский элемент для добавления canvas
		#  canvas: Element - canvas для рисования, создается автоматически
		#  context: context2d - контекст для рисования, создается автоматически
		#  zIndex: int - индекс, определяющий порядок сцен, чем выше индекс, тем выше сцена над остальными
		#  
		# методы:
		# 
		#  add(Object): DisplayObject - добавление дочернего объекта
		#  animate() - попытка нарисовать объект
		# 
		constructor: (options) ->

			# 
			# элемент для добавления канваса
			# всегда должен быть
			# 
			Object.defineProperty @, "stage", {

				value: options.stage or document.body
				writable: false
				configurable: false

			}
			
			# 
			# создаем канвас
			# 
			Object.defineProperty @, "canvas", {

				value: document.createElement "canvas"
				writable: false
				configurable: false

			}
			@canvas.style.position = "absolute"
			@stage.appendChild @canvas

			# 
			# контекст
			# 
			Object.defineProperty @, "context", {

				value: @canvas.getContext "2d"
				writable: false
				configurable: false

			}

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