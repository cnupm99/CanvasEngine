"use strict";

define ["Scene"], (Scene) ->

	# 
	# Управление сценами
	# 
	# Все сцены добавляются на глобальное поле stage
	# Сцена не может содержать в себе другую сцену
	# 
	class Scenes

		constructor: (stage) ->

			# массив сцен
			@_scenes = []
			# глобальный объект / родитель сцен
			@_stage = stage
			# имя активной сцены
			@_activeSceneName = ""

		# создание сцены
		create: (options) ->

			# имя сцены FPS является зарезервированным
			# не желательно использовать это имя для своих сцен
			# во избежание проблем

			# получаем имя сцены
			sceneName = options.name or "default"
			# пробуем найти, нет ли уже такой сцены
			scene = @get sceneName
			# если нет
			unless scene
				
				# вычисляем позицию родителя и передаем ее в сцену
				stagePosition = [@_stage.offsetLeft, @_stage.offsetTop]
				options.parentPosition = stagePosition

				# создаем
				scene = new Scene options
				@_stage.appendChild scene.canvas
				@_scenes.push scene

			# если нужно, устанавливаем сцену активной
			setActive = if options.setActive? then options.setActive else true
			@_activeSceneName = sceneName if setActive

			return scene