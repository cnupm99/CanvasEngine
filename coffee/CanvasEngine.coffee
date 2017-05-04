"use strict";

define ["base", "Scenes", "FPS"], (base, Scenes, FPS) ->

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
		# 	showFPS: Boolean
		# 	
		# }
		# 
		constructor: (options) ->

			# проверка поддержки канвас и котекст
			unless @_canvasSupport()

				console.log "your browser not support canvas and/or context"
				return false

			# базовые свойства и методы
			super options
			# менеджер сцен
			@_scenes = new Scenes(@_parent)
			# массив функций для выполнения в цикле перед анимацией
			@_beforeAnimate = []

			# нужно ли показывать фпс
			@_showFPS = if options.showFPS? then options.showFPS else true
			# создаем счетчик, если нужно
			if @_showFPS

				# сцена для фпс
				scene = @_scenes.create {

					name: "FPS"
					sizes: [90, 40]
					position: [5, 5]
					# чтобы сцена была выше всех
					zIndex: 9999
					setActive: false

				}
				# счетчик
				@_FPS = new FPS { scene: scene }

			# запуск анимации
			@start()

		# запуск анимации
		start: () -> @_render = requestAnimationFrame @_animate

		# остановка анимации
		stop: () -> closeRequestAnimation @_render

		# добавить функцию для выполнения в цикле
		# функции выполняются в порядке добавления
		# ПЕРЕД аниамацией
		addEvent: (handler) -> @_beforeAnimate.push handler

		# удаление функции из массива
		removeEvent: (handler) ->

			@_beforeAnimate.forEach (item, i) => @_beforeAnimate.splice i, 1 if item == handler

		# 
		# Глобальная функция для добавления всего, что угодно
		# 
		add: (options) ->

			# имя сцены FPS является зарезервированным
			# не желательно использовать это имя для своих сцен
			# во избежание проблем

			# тип добавляемого объекта,
			# по умолчанию - сцена
			type = options.type or "scene"

			# добавить сцену?
			if type == "scene"

				# размеры сцены по умолчанию равны размерам движка
				options.sizes = @_sizes unless options.sizes?

				@_scenes.create options

			else

				# на какую сцену добавить объект?
				sceneName = options.scene or @_scenes.active() or "default"
				# если такой сцены нет, то создадим ее
				scene = @_scenes.create {

					name: sceneName
					sizes: options.sizes or @_sizes

				}

				# добавляем объект на нужную сцену
				scene.add options

		# проверка, поддерживает ли браузер canvas и context
		_canvasSupport: () -> document.createElement("canvas").getContext?

		# цикл анимации
		_animate: () =>

			# выполняем все функции в массиве
			@_beforeAnimate.forEach (handler) ->

				handler() if typeof(handler) == "function"

			# проверка, нужна ли анимация
			needAnimation = @_scenes.needAnimation()

			# если анимация нужна, делаем ее
			@_scenes.animate() if needAnimation

			# обновляем фпс
			@_FPS.update needAnimation if @_showFPS

			# продолжаем анимацию
			@_render = requestAnimationFrame @_animate