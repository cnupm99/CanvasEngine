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
				# создаем
				scene = new Scene options
				@_stage.appendChild scene.canvas
				@_scenes.push scene

			# если нужно, устанавливаем сцену активной
			setActive = if options.setActive? then options.setActive else true
			@_activeSceneName = sceneName if setActive

			return scene

		# получаем имя активной сцены
		active: () -> @_activeSceneName

		# устанавливаем активную сцену по имени
		@.prototype.active.set = (sceneName) ->

			# ищем сцену
			scene = @get sceneName
			# если она существует, устанавливаем ее имя в активное
			@_activeSceneName = sceneName if scene
			# возвращаем результат
			return scene

		# возвращаем активную сцену
		@.prototype.active.get = () -> @get @_activeSceneName

		# ищем сцену по имени
		get: (sceneName) ->

			answer = false

			# перебор всех сцен, пока не встретим нужную
			@_scenes.some (scene) -> 

				flag = scene.name == sceneName
				answer = scene if flag
				return flag

			return answer

		# удаление сцены по имени
		remove: (sceneName) ->

			# ищем индекс сцены
			index = @_index sceneName
			# если такая сцена есть
			if index > -1

				# удаляем канвас с экрана
				@_parent.removeChild @_scenes[index].canvas
				# удаляем сцену из массива сцен
				@_scenes.splice index, 1
				return true

			return false

		# переименовать сцену
		rename: (sceneName, newName) ->

			# ищем сцену с нужным именем
			scene = @get sceneName

			# если она существует, меняем ей имя
			scene.name = newName if scene

			return scene

		# поднимаем сцену на верх отображения
		onTop: (sceneName) ->

			maxZ = 0
			result = false

			@_scenes.forEach (scene) ->

				maxZ = scene.getZ() if scene.getZ() > maxZ
				result = scene if sceneName == scene.name

			result.setZ maxZ + 1 if result

			return result

		# нужна ли анимация хоть одной сцены
		needAnimation: () ->

			@_scenes.some (scene) -> scene.needAnimation()

		# анимация всех сцен, если нужно
		animate: () ->

			@_scenes.forEach (scene) -> scene.animate() if scene.needAnimation()

		# получить индекс сцены по ее имени
		_index: (sceneName) ->

			index = -1

			# перебор всех сцен, пока не встретим нужную
			@_scenes.some (scene) -> 

				flag = scene.name == sceneName
				index = scene if flag
				return flag

			return index