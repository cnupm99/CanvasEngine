"use strict";

define ["AbstractObject", "Scene"], (AbstractObject, Scene) ->

	# 
	# Движок для Canvas
	# 
	class CanvasEngine extends AbstractObject

		# 
		# 
		# 
		constructor: (options) ->

			# 
			# проверка поддержки канвас и контекст
			# 
			unless @canvasSupport()

				console.log "your browser not support canvas and/or context"
				return false

			# 
			# базовые свойства и методы
			# 
			super options

			# 
			# создаем сцену по умолчанию
			#
			@add {

				type: "scene"
				name: "default"

			}

			# 
			# Свойство хранит имя активной сцены в виде строки,
			# НО при обращении возвращает активную СЦЕНУ, либо если она была удалена,
			# то первую сцену в списке, либо если список пуст, то false
			# 
			Object.defineProperty @, "activeScene", {

				get: () -> 

					result = @get _scene
					result = @childrens[0] unless result
					result = false unless result
					result

				set: (value) -> 

					_scene = "" + value
					@get _scene

			}
			@scene = "default"

			# 
			# массив функций для выполнения в цикле перед анимацией
			# 
			@beforeAnimate = []

			# 
			# запуск анимации
			# 
			@start()

		# 
		# Глобальная функция для добавления всего, что угодно
		# 
		add: (options) ->

			# 
			# создаем пустой объект, если необходимо
			# 
			options = {} unless options?

			# 
			# тип добавляемого объекта,
			# по умолчанию - сцена
			# 
			type = options.type or "scene"

			# 
			# добавить сцену?
			# 
			if type == "scene"

				@_createScene options

			# 
			# добавление всего остального, кроме сцен
			# 
			else

				# 
				# на какую сцену добавить объект?
				# 
				scene = @get options.scene

				# 
				# если в опциях не указана сцена, то добавляем на активную сцену
				# 
				scene = @activeScene unless scene

				# 
				# если в списке нет ниодной сцены, создадим сцену по умолчанию
				# 
				unless scene

					scene = @add {

						type: "scene"
						name: "default"

					}

				# 
				# добавляем объект на нужную сцену
				# 
				scene.add options

		# 
		# создание сцены с нужными опциями
		# 
		createScene: (options) ->

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
			# передаем родителя, как элемент для создания канваса
			# 
			options.stage = @parent

			# 
			# создаем сцену
			# 
			scene = new Scene options

			# 
			# добавляем в список дочерних объектов
			# 
			@childrens.push scene

			# 
			# делаем новую сцену активной
			# 
			@activeScene = scene.name

		# 
		# удаляем сцену по ее имени
		# отдельная функция, т.к. тут нужно удалить канвас с элемента
		# 
		remove: (childName) ->

			index = @index childName
			if index == -1 then return false
			@parent.removeChild @childrens[index].canvas
			@childrens.splice index, 1
			return true

		# 
		# переносим сцену на верх отображения
		# для чего делаем ее zIndex на 1 больше максимального из существующих
		# 
		onTop: (childName) ->

			maxZ = 0
			result = false

			@childrens.forEach (child) ->

				maxZ = child.zIndex if child.zIndex > maxZ
				result = child if childName == child.name

			result.zIndex = maxZ + 1 if result

			return result

		# 
		# запуск анимации
		# 
		start: () -> @_render = requestAnimationFrame @animate

		# 
		# остановка анимации
		# 
		stop: () -> cancelAnimationFrame @_render

		# 
		# цикл анимации, запускается автоматически,
		# не нужно это делать вручную,
		# для этого есть методы start() и stop()
		# 
		animate: () =>

			# 
			# выполняем все функции в массиве
			# 
			@beforeAnimate.forEach (handler) ->

				handler() if typeof(handler) == "function"

			# 
			# АНИМАЦИЯ ТУТ
			# 

			# а может не надо?
			@needAnimation = false
			
			# перебираем сцены
			@childrens.forEach (child) ->

				# для каждой сцены проверяем дочерние элементы
				needAnimation = child.needAnimation or child.childrens.some (childOfChild) ->

					# нужно ли рисовать этот дочерний элемент сцены
					childOfChild.needAnimation

				# собственно анимация
				child.animate() if needAnimation

				# сохраняем значение
				@needAnimation = @needAnimation or needAnimation

			# 
			# продолжаем анимацию
			# 
			@_render = requestAnimationFrame @animate

		# 
		# добавить функцию для выполнения в цикле
		# функции выполняются в порядке добавления
		# ПЕРЕД аниамацией
		# 
		addEvent: (handler) -> @beforeAnimate.push handler

		# 
		# удаление функции из массива
		# эта функция больше не будет выполняться перед анимацией
		# 
		removeEvent: (handler) ->

			@beforeAnimate.forEach (item, i) => @beforeAnimate.splice i, 1 if item == handler

		# 
		# установить / снять полноэкранный режим
		# для элемента parent
		# 
		fullscreen: (value = true) ->

			if value

				if @parent.requestFullScreen? then @parent.requestFullScreen()
				else if @parent.webkitRequestFullScreen? then @parent.webkitRequestFullScreen()
				else if @parent.mozRequestFullScreen? then @parent.mozRequestFullScreen()
				else return false

			else

				if document.cancelFullScreen? then document.cancelFullScreen()
				else if document.webkitCancelFullScreen? then document.webkitCancelFullScreen()
				else if document.mozCancelFullScreen? then document.mozCancelFullScreen()
				else if document.exitFullScreen? then document.exitFullScreen()
				else return false

			return true

		# проверка, находится ли документ в полноэкранном режиме
		isFullscreen: () -> 

			element = document.fullscreenElement or document.webkitFullscreenElement or document.mozFullscreenElement
			element?

		# 
		# проверка, поддерживает ли браузер canvas и context
		# 
		canvasSupport: () -> document.createElement("canvas").getContext?