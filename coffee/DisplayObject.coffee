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

			# нужна ли анимация
			@needAnimation = @_visible

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