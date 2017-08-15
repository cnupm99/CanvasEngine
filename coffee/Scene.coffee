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
		#  needAnimation: Boolean - нужно ли анимировать данный объект с точки зрения движка
		#  
		# методы:
		# 
		#  add(Object): DisplayObject - добавление дочернего объекта
		#  animate() - попытка нарисовать объект
		#  
		# установка свойств:
		# 
		#  setZIndex()
		#  setPosition()
		#  setSize()
		#  setCenter()
		#  setRotation()
		#  setAlpha()
		# 
		constructor: (options) ->

			# 
			# элемент для добавления канваса
			# всегда должен быть
			# свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ
			# 
			@stage = options.stage or document.body
			
			# 
			# создаем канвас
			# свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ
			# 
			@canvas = document.createElement "canvas"
			@canvas.style.position = "absolute"
			@stage.appendChild @canvas

			# 
			# контекст
			# свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ
			# 
			@context = @canvas.getContext "2d"

			# 
			# Буфер для рисования
			# 
			@_buffer = document.createElement "canvas"
			@_bufferContext = @_buffer.getContext "2d"

			# 
			# создаем DisplayObject
			# 
			super options

			@move @position
			@resize @size
			@focus @center
			@rotate @rotation
			@opasity @alpha

			# 
			# тип объекта
			# 
			@type = "scene"

			# 
			# индекс, определяющий порядок сцен, чем выше индекс, тем выше сцена над остальными
			# целое число >= 0
			# 
			@float options.zIndex

			# 
			# прямоугольная маска, применимо к Scene
			# если маска дейтсвует, то на сцене будет отображаться только объекты внутри маски
			# массив [int, int, int, int] или false
			# 
			# ВНИМАНИЕ!
			# В браузере firefox есть баг (на 25.04.17), а именно:
			# при попытке нарисовать на канве изображение, используя одновременно
			# маску и тень (mask и shadow в данном случае), получается
			# странная хрень, а точнее маска НЕ работает в данном случае
			# Доказательство и пример здесь: http://codepen.io/cnupm99/pen/wdGKBO
			# 
			@masking options.mask

			# 
			# нужно ли анимировать данный объект с точки зрения движка
			# не нужно в ручную менять это свойство, для этого есть visible
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
		# Установка прямоугольной маски для рисования
		# 
		masking: (value) ->

			if (not value?) or (not value) then @mask = false else @mask = value

			@needAnimation = true
			@mask

		# 
		# Установка zIndex
		# 
		float: (value) ->

			@zIndex = @int value
			@canvas.style.zIndex = @zIndex
			@zIndex

		# 
		# Далее функции, перегружающие свойсва экранного объекта,
		# т.к. нам нужно в этом случае двигать, поворачивать и т.д. сам канвас
		# 

		move: (value1, value2) ->

			super value1, value2

			# 
			# двигаем канвас по экрану
			# 
			@canvas.style.left = @position[0] + "px"
			@canvas.style.top = @position[1] + "px"
			@position

		resize: (value1, value2) ->

			super value1, value2

			# 
			# меняем размер канваса
			# 
			@canvas.width = @size[0]
			@canvas.height = @size[1]
			@_buffer.width = @size[0]
			@_buffer.height = @size[1]
			@size

		focus: (value1, value2) ->

			super value1, value2

			# 
			# сдвигаем начало координат в центр
			# 
			@context.translate @center[0], @center[1]
			@_bufferContext.translate @center[0], @center[1]
			@center

		rotate: (value) ->

			super value

			# 
			# поворот всего контекста на угол
			# 
			@context.rotate @deg2rad(@rotation)
			@_bufferContext.rotate @deg2rad(@rotation)
			@rotation

		opasity: (value) ->

			super value

			@context.globalAlpha = @alpha
			@_bufferContext.globalAlpha = @alpha
			@alpha

		# 
		# анимация сцены
		# 
		animate: () ->

			# 
			# если объект не видимый
			# то рисовать его не нужно
			# 
			return unless @visible

			# 
			# может не надо?
			# 
			return unless @needAnimation

			# 
			# очистка контекста
			# 
			# @_bufferContext.clearRect 0, 0, @size[0], @size[1]
			@context.clearRect 0, 0, @size[0], @size[1]

			# 
			# установка маски
			# 
			if @mask

				@_bufferContext.beginPath()
				@_bufferContext.rect @mask[0], @mask[1], @mask[2], @mask[3]
				@_bufferContext.clip()

			# 
			# анимация в буфер
			# 
			@childrens.forEach (child) => 

				# @_bufferContext.save()
				@context.save()
				# child.animate @_bufferContext
				child.animate @context
				# @_bufferContext.restore()
				@context.restore()

			# 
			# рисуем на основной канвас
			# 
			# @context.clearRect 0, 0, @size[0], @size[1]
			# @context.drawImage @_buffer, 0, 0

			# 
			# анимация больше не нужна
			# 
			@needAnimation = false