"use strict";

define ["base", "Scenes"], (base, Scenes) ->

	# 
	# Движок для Canvas
	# 
	class CanvasEngine extends base

		# 
		# options = {
		# 
		# 	parent: DomElement
		# 	rotation: number
		# 	alpha: number
		# 	
		# 	sizes: Array / Object
		# 	center: Array / Object
		# 
		# }
		# 
		constructor: (options) ->

			# базовые свойства и методы
			super options
			# менеджер сцен
			@_scenes = new Scenes(@_parent)

		# 
		# Глобальная функция для добавления всего, что угодно
		# 
		add: (options) ->

			# тип добавляемого объекта,
			# по умолчанию - сцена
			type = options.type or "scene"

			# добавить сцену?
			if type == "scene"

				@_scenes.create options

			else

				# на какую сцену добавить объект?
				sceneName = options.scene or @_scenes.active() or "default"
				# если такой сцены нет, то создадим ее
				scene = @_scenes.create {

					name: sceneName
					setActive: true

				}

				# добавляем объект на нужную сцену
				scene.add options