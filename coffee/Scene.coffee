"use strict";

define ["DisplayObject", "Image", "Text", "Graph", "TilingImage"], (DisplayObject, Image, Text, Graph, TilingImage) ->

	class Scene extends DisplayObject

		# 
		# Сцена
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
			# элемент для добавления канваса
			# всегда должен быть
			# 
			@stage = options.stage
			
			# 
			# создаем канвас
			# 
			@canvas = document.createElement "canvas"
			@canvas.style.position = "absolute"
			@stage.addChild @canvas

			# 
			# контекст
			# 
			@context = @canvas.getContext "2d"

			# 
			# индекс, определяющий порядок сцен, чем выше индекс, тем выше сцена над остальными
			# целое число >= 0
			# 
			_zIndex = @point options.zIndex
			Object.defineProperty @, "zIndex", {

				get: () -> _zIndex
				set: (value) -> 

					_zIndex = @int value
					@canvas.style.zIndex = _zIndex
					_zIndex

			}

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

			@canvas.style.left = @_position[0] + "px"
			@canvas.style.top = @_position[1] + "px"

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