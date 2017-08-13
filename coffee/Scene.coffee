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
			@context.clearRect 0, 0, @size[0], @size[1]

			# 
			# установка маски
			# 
			if @mask

				@context.beginPath()
				@context.rect @mask[0], @mask[1], @mask[2], @mask[3]
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

		setPosition: (value) ->

			super value

			# 
			# двигаем канвас по экрану
			# 
			@canvas.style.left = @position[0] + "px"
			@canvas.style.top = @position[1] + "px"
			@position

		setSize: (value) ->

			super value

			# 
			# меняем размер канваса
			# 
			@canvas.width = @size[0]
			@canvas.height = @size[1]
			@size

		setCenter: (value) ->

			super value

			# 
			# сдвигаем начало координат в центр
			# 
			@context.translate @center[0], @center[1]
			@center

		setRotation: (value) ->

			super value

			# 
			# поворот всего контекста на угол
			# 
			@context.rotate @deg2rad(@rotation)
			@rotation

		setAlpha: (value) ->

			super value

			@context.globalAlpha = @alpha
			@alpha