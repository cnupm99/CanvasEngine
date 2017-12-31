"use strict";

define ["ContainerObject", "Image", "Text", "Graph", "TilingImage"], (ContainerObject, Image, Text, Graph, TilingImage) ->

	class Scene extends ContainerObject

		# 
		# Класс сцены, на который добавляются все дочерние объекты
		# Фактически представляет собой canvas
		# 
		# свойства:
		# 
		#  canvas:Element - canvas для рисования, создается автоматически
		#  context:context2d - контекст для рисования, создается автоматически
		#  zIndex:int - индекс, определяющий порядок сцен, чем выше индекс, тем выше сцена над остальными
		#  mask:Array - маска объекта
		#  needAnimation:Boolean - нужно ли анимировать данный объект с точки зрения движка
		#  
		# методы:
		# 
		#  add(data:Object):DisplayObject - добавление дочернего объекта
		#  clear() - полная очистка сцены
		#  animate() - попытка нарисовать объект
		#  
		# установка свойств:
		# 
		#  setMask(value:Object):Object - установка маски
		#  setZIndex(value:int):int - установка зед индекса канваса
		#  hide() - скрыть сцену
		#  move(value1, value2:int):Array - изменить позицию канваса
		#  shiftAll(value1, value2:int) - сдвигаем все дочерные объекты
		#  resize(value1, value2:int):Array - изменить размер канваса
		#  setCenter(value1, value2:int):Array - установить новый центр канваса
		#  setAnchor(value1, value2:int):Array - установить якорь канваса
		#  rotate(value:int):int - установить угол поворота канваса
		#  setAlpha(value:Number):Number - установить прозрачность канваса
		# 
		constructor: (options) ->

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
			@setZIndex options.zIndex

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
			@setMask options.mask

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
			# передаем канвас и контекст для рисования
			# 
			options.canvas = @canvas
			options.context = @context

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
		# очистка сцены
		# 
		clear: () ->

			# 
			# удаляем все дочерние элементы
			# 
			@childrens = []
			# 
			# перерисовка
			# 
			@needAnimation = true

		# 
		# Установка прямоугольной маски для рисования
		# 
		setMask: (value) ->

			if (not value?) or (not value) then @mask = false else @mask = value

			@needAnimation = true
			@mask

		# 
		# Установка zIndex
		# 
		setZIndex: (value) ->

			@zIndex = @int value
			@canvas.style.zIndex = @zIndex
			@zIndex

		# 
		# Далее функции, перегружающие свойсва экранного объекта,
		# т.к. нам нужно в этом случае двигать, поворачивать и т.д. сам канвас
		# 

		hide: () ->

			super()
			@context.clearRect 0, 0, @size[0], @size[1]

		move: (value1, value2) ->

			super value1, value2

			# 
			# двигаем канвас по экрану
			# 
			@canvas.style.left = @position[0] + "px"
			@canvas.style.top = @position[1] + "px"
			@position

		# 
		# сдвигаем все дочерние объекты
		# 
		shiftAll: (value1, value2 = 0) ->

			@childrens.forEach (child) -> child.shift value1, value2

		resize: (value1, value2) ->

			super value1, value2

			# 
			# меняем размер канваса
			# 
			@canvas.width = @size[0]
			@canvas.height = @size[1]
			@size

		setCenter: (value1, value2) ->

			super value1, value2

			# 
			# сдвигаем начало координат в центр
			# 
			@context.translate @center[0], @center[1]
			@center

		setAnchor: (value1, value2) ->

			super value1, value2

			# 
			# сдвигаем начало координат в центр
			# 
			@context.translate @center[0], @center[1]
			@anchor

		rotate: (value) ->

			super value

			# 
			# поворот всего контекста на угол
			# 
			@context.rotate @_rotation
			@rotation

		setAlpha: (value) ->

			super value

			@context.globalAlpha = @alpha
			@alpha

		# 
		# анимация сцены
		# 
		animate: () ->

			# 
			# если объект не видимый
			# то рисовать его не нужно
			# 
			if not @visible

				@needAnimation = false
				return

			# 
			# очистка контекста
			# 
			@context.clearRect 0, 0, @size[0], @size[1]

			# 
			# установка маски
			# 
			if @mask

				@context.beginPath()
				@context.rect @mask[0], @mask[1], @mask[2], @mask[3]
				@context.clip()

			# 
			# анимация в буфер
			# 
			@childrens.forEach (child) => 

				@context.save()
				child.animate()
				@context.restore()

			# 
			# анимация больше не нужна
			# 
			@needAnimation = false