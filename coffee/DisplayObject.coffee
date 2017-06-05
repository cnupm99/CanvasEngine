"use strict";

define ["base"], (base) ->

	class DisplayObject extends base

		# 
		# Базовые методы и свойства экранных объектов
		# 
		constructor: (options) ->

			super options

			# имя
			@name = options.name
			# тень
			@_shadow = false
			# видимость объекта
			@_visible = if options.visible? then options.visible else true
			# контекст для рисования
			@_context = options.parent.context
			# позиция родителя для вычисления координат
			@_parentPosition = options.parent.position

			# нужна ли анимация
			@needAnimation = @_visible

		# проверяем, пуста ли точка с данными координатами
		# а для начала находится ли точка внутри объекта
		# ВНИМАНИЕ!
		# использовать этот метод ЛОКАЛЬНО нужно осторожно, так как
		# в браузерах на основе chrome будет возникать ошибка безопасности
		# (как будто пытаешься загрузить изображение с другого хоста).
		# В firefox работает и локально без проблем.
		# При загрузке кода на сервер работает во всех браузерах.
		testPoint: (pointX, pointY) ->

			return false unless @testRect pointX, pointY

			# данные пикселя
			imageData = @context.getImageData pointX, pointY, 1, 1
			# цвет пикселя
			pixelData = imageData.data

			# проверяем нужный метод?
			pixelData.every = Array.prototype.every if not pixelData.every?

			# проверяем все цвета, если 0, значит мимо
			return not pixelData.every (value) -> value == 0

		# находится ли точка внутри объекта по его позиции / размерам
		testRect: (pointX, pointY) ->

			rect = {

				left: @_position[0]
				top: @_position[1]
				right: @_position[0] + @_sizes[0]
				bottom: @_position[1] + @_sizes[1]

			}

			return (pointX >= rect.left) and (pointX <= rect.right) and (pointY >= rect.top) and (pointY <= rect.bottom)

		# возвращаем позицию
		getPosition: () -> @_position

		# сдвигаем объект на нужную величину по осям
		shift: (_deltaX = 0, _deltaY = 0) ->

			@setPosition [_deltaX + @_position[0], _deltaY + @_position[1]]

		# установка видимости
		setVisible: (value) ->

			@_visible = if value? then value else true
			@needAnimation = @_visible

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

			@needAnimation = true

		# позиция
		setPosition: (position) ->

			@_position = @_point position if position?

			@needAnimation = true

		# центр, вокруг которого происходит вращение
		setCenter: (center) ->

			@_center = @_point center if center?

			@needAnimation = true

		# поворот
		setRotation: (rotation) ->

			@_rotation = @_value rotation if rotation?

			@needAnimation = true

		# прозрачность
		setAlpha: (alpha) ->

			@_alpha = @_value alpha if alpha?

			@needAnimation = true

		# тень
		# # ВНИМАНИЕ!
		# В браузере firefox есть баг (на 25.04.17), а именно:
		# при попытке нарисовать на канве изображение, используя одновременно
		# маску и тень (setMask and setShadow в данном случае), получается
		# странная хрень, а точнее маска НЕ работает в данном случае.
		# Доказательство и пример здесь: http://codepen.io/cnupm99/pen/wdGKBO
		setShadow: (options) ->

			if options?

				@_shadow = {

					color: options.color or "#000"
					blur: options.blur or 3
					offsetX: options.offsetX or 0
					offsetY: options.offsetY or 0
					offset: options.offset or 0

				}

			else

				@_shadow = false

			@needAnimation = true

		# анимация
		animate: (context) ->

			# если объект не видимый
			# то рисовать его не нужно
			unless @_visible

				@needAnimation = false
				return

			# сохранить контекст
			context.save()

			# смещение
			@_deltaX = @_position[0]
			@_deltaY = @_position[1]

			# установка тени
			if @_shadow

				context.shadowColor = @_shadow.color
				context.shadowBlur = @_shadow.blur
				context.shadowOffsetX = Math.max @_shadow.offsetX, @_shadow.offset
				context.shadowOffsetY = Math.max @_shadow.offsetY, @_shadow.offset

			# смещение и поворот холста
			if @_rotation != 0

				context.translate @_center[0] + @_position[0], @_center[1] + @_position[1]
				context.rotate @_rotation * Math.PI / 180
				@_deltaX = -@_center[0]
				@_deltaY = -@_center[1]

			# анимация больше не нужна
			@needAnimation = false