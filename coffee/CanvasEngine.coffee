"use strict";

define ["ContainerObject", "Scene"], (ContainerObject, Scene) ->

	# 
	# Движок для Canvas
	# 
	class CanvasEngine extends ContainerObject

		# 
		# Главный класс, через него осуществляется взаимодействие с движком
		# 
		# свойства:
		# 
		#  parent:Element - элемент для отрисовки движка
		#  
		# методы:
		# 
		#  add(options):DisplayObject - метод для добавления новых объектов / сцен
		#  remove(childName):Boolean - удаляем сцену
		#  onTop(childName):Scene/Boolean - поднимаем сцену на верх отображения
		#  getActive():Scene/Boolean - получить активную сцену
		#  setActive(sceneName:String):Scene - установить активную сцену по имени
		#  start() - запускаем цикл анимации
		#  stop() - останавливаем цикл анимации
		#  addEvent(func) - добавить функцию, выполняемую каждый раз перед анимацией
		#  removeEvent(func) - удалить функцию из цикла анимации
		#  fullscreen(Boolean):Boolean - включить/выключить полноэкранный режим
		#  isFullscreen():Boolean - определяет, включен ли полноэкранный режим
		#  canvasSupport():Boolean - проверка, поддерживает ли браузер canvas и context
		# 
		constructor: (options) ->

			# 
			# базовые свойства и методы
			# 
			super options

			# 
			# проверка поддержки канвас и контекст
			# 
			unless @canvasSupport()

				console.log "your browser not support canvas and/or context"
				return false

			# 
			# элемент для отрисовки движка
			# свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ
			# 
			@parent = options.parent or document.body

			# 
			# если размеры движка не заданы, то пытаемся установить их равными
			# размеру контейнера
			# 
			if @size[0] == 0 and @size[1] == 0

				@size = [@int(@parent.clientWidth), @int(@parent.clientHeight)]

			# 
			# массив функций для выполнения в цикле перед анимацией
			# 
			@_beforeAnimate = []

			# 
			# Свойство хранит имя активной сцены в виде строки
			# 
			@_scene = "default"

			# 
			# создаем сцену по умолчанию
			#
			@add {

				type: "scene"
				name: "default"

			}

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
				scene = @getActive() unless scene

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

			result.setZIndex maxZ + 1 if result

			return result

		# 
		# Возвращает активную сцену
		# 
		getActive: () ->

			result = @get(@_scene)
			result = @childrens[0] unless result
			result = false unless result
			result

		# 
		# Устанавливает активную сцену по ее имени
		# 
		setActive: (sceneName) ->

			@_scene = sceneName or "default"
			@getActive()

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
			# передаем родителя, как элемент для создания канваса
			# 
			options.parent = @parent

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
			@setActive scene.name

			return scene

		# 
		# цикл анимации, запускается автоматически,
		# не нужно это делать вручную,
		# для этого есть методы start() и stop()
		# 
		_animate: () =>

			# 
			# выполняем все функции в массиве
			# 
			@_beforeAnimate.forEach (func, i) =>

				# 
				# если это функция, то выполняем ее
				# 
				if typeof(func) == "function" then func()
				# 
				# а иначе удаляем эту чушь из массива
				# 
				else @_beforeAnimate.splice i, 1

			# 
			# АНИМАЦИЯ ТУТ
			# 

			# а может не надо?
			@needAnimation = false
			
			# перебираем сцены
			@childrens.forEach (child) =>

				needAnimation = child.needAnimation or child.childrens.some (childOfChild) -> childOfChild.needAnimation

				# сохраняем значение
				@needAnimation = @needAnimation or needAnimation

				# собственно анимация
				child.animate() if needAnimation

			# 
			# продолжаем анимацию
			# 
			@_render = requestAnimationFrame @_animate