"use strict";

define ["AbstractObject", "Scene"], (AbstractObject, Scene) ->

	# 
	# Движок для Canvas
	# 
	class CanvasEngine extends AbstractObject

		# 
		# Главный класс, через него осуществляется взаимодействие с движком
		# 
		# свойства:
		# 
		#  scene: Scene - хранит имя активной сцены, возвращает сцену
		#  
		# методы:
		# 
		#  add(options): DisplayObject - метод для добавления новых объектов / сцен
		#  remove(childName): Boolean - удаляем сцену
		#  onTop(childName): Scene/Boolean - поднимаем сцену на верх отображения
		#  start() - запускаем цикл анимации
		#  stop() - останавливаем цикл анимации
		#  addEvent(func) - добавить функцию, выполняемую каждый раз перед анимацией
		#  removeEvent(func) - удалить функцию из цикла анимации
		#  fullscreen(Boolean): Boolean - включить/выключить полноэкранный режим
		#  isFullscreen(): Boolean - определяет, включен ли полноэкранный режим
		#  canvasSupport(): Boolean - проверка, поддерживает ли браузер canvas и context
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
			# если размеры движка не заданы, то пытаемся установить их равными
			# размеру контейнера
			# 
			if @size[0] == 0 and @size[1] == 0

				@size = [@int(@parent.clientWidth), @int(@parent.clientHeight)]

			# 
			# Свойство хранит имя активной сцены в виде строки,
			# НО при обращении возвращает активную СЦЕНУ, либо если она была удалена,
			# то первую сцену в списке, либо если список пуст, то false
			# 
			_scene = "default"
			Object.defineProperty @, "scene", {

				get: () -> 

					result = @get _scene
					result = @childrens[0] unless result
					result = false unless result
					result

				set: (value) -> 

					_scene = "" + value
					@get _scene

			}

			# 
			# создаем сцену по умолчанию
			#
			@add {

				type: "scene"
				name: "default"

			}

			# 
			# массив функций для выполнения в цикле перед анимацией
			# 
			@_beforeAnimate = []

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
				scene = @scene unless scene

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
		start: () -> @_render = requestAnimationFrame @_animate

		# 
		# остановка анимации
		# 
		stop: () -> cancelAnimationFrame @_render

		# 
		# добавить функцию для выполнения в цикле
		# функции выполняются в порядке добавления
		# ПЕРЕД аниамацией
		# 
		addEvent: (func) -> @_beforeAnimate.push func

		# 
		# удаление функции из массива
		# эта функция больше не будет выполняться перед анимацией
		# 
		removeEvent: (func) ->

			@_beforeAnimate.forEach (item, i) => @_beforeAnimate.splice i, 1 if item == func

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

		# 
		# создание сцены с нужными опциями
		# 
		_createScene: (options) ->

			# 
			# если нужно, задаем значения по умолчанию
			# 
			options.visible = @visible unless options.visible?
			options.position = @position unless options.position?
			options.size = @size unless options.size?
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
			@scene = scene.name

		# 
		# цикл анимации, запускается автоматически,
		# не нужно это делать вручную,
		# для этого есть методы start() и stop()
		# 
		_animate: () =>

			# 
			# выполняем все функции в массиве
			# 
			@_beforeAnimate.forEach (handler) ->

				handler() if typeof(handler) == "function"

			# 
			# АНИМАЦИЯ ТУТ
			# 

			# а может не надо?
			@needAnimation = false
			
			# перебираем сцены
			@childrens.forEach (child) =>

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
			@_render = requestAnimationFrame @_animate