"use strict";

define () ->

	class Button

		# 
		# options = {
		# 
		# 	scene:Scene - сцена для прорисовки
		# 	texturesList:Object - список текстур 
		# 	  (а точнее массивы с размерами текстур)
		# 	downSupport:Boolean - есть ли поддержка нажатого состояния
		# 	downed:Boolean - активно ли нажатое состояние
		# 	enabled:Boolean - активна ли кнопка
		# 	from:Image - картинка со всеми текстурами
		# 	position:Array - позиция
		# 	size:Array -размер
		# 	action:Function - событие при клике на кнопку
		# 
		# }
		# 
		constructor: (options) ->

			# 
			# сцена для отрисовки
			# 
			scene = options.scene
			return unless scene?

			# 
			# лист текстур:
			# 
			# options.texturesList = {
			#  
			#   normal: обычный вид
			#   disabled: отключенная кнопка
			#   mouseOver: мышь над кнопкой
			#   mouseDown: нажата клавиша мыши
			#   downed: кнопка в нажатом состоянии
			#   downedMouseOver: мышь над кнопкой в нажатом состоянии
			#   blink: текстура для мигания кнопки
			#  
			# }
			@_texturesList = options.texturesList

			# 
			# есть ли поддержка нажатого состояния
			# 
			@downSupport = if options.downSupport? then options.downSupport else false
			# 
			# находится ли кнопка в нажатом состоянии
			# 
			@_downed = if options.downed? then options.downed else false

			# 
			# активна ли кнопка
			# 
			@_enabled = if options.enabled? then options.enabled else true

			# 
			# нужно ли анимировать мигание кнопки
			# 
			@_blink = if options.blink? then options.blink else false

			# 
			# спрайт кнопки
			# 
			@_sprite = scene.add {

				type: "image"
				from: options.from
				rect: if @_enabled then @_texturesList.normal else @_texturesList.disabled
				position: options.position
				size: options.size

			}

			# 
			# событие нажатия на кнопку
			# 
			@action = options.action or false
			# 
			# событие нажатия на кнопку, если после него
			# кнопка остается в нажатом состоянии
			# 
			@down = options.down or false
			# 
			# событие нажатия на кнопку, если после него
			# кнопка остается в отжатом состоянии
			# 
			@up = options.up or false

			# 
			# если кнопка активна
			# 
			if @_enabled

				# 
				# устанавливаем события кнопки
				# 
				@_setEvents()
				# 
				# а не начать ли отображать мигание?
				# 
				@_blinkStart() if @_blink

		# 
		# вернуть размер кнопки
		# который фактически равен размеру спрайта
		# 
		size: () -> @_sprite.size

		# 
		# перемещние кнопки
		# 
		move: (position) ->	@_sprite.move position

		# 
		# возвращает позицию спрайта,
		# т.е. фактически координаты кнопки
		# 
		position: () -> @_sprite.position

		# 
		# получаем либо устанавливаем видимость кнопки
		# 
		visible: (value) ->

			if value?

				if value then @_sprite.show() else @_sprite.hide()

			return @_sprite.visible

		# 
		# сообщаем, находится ли кнопка в нажатом состоянии
		# 
		downed: () -> @_downed

		# 
		# установка и получение значения enabled
		# 
		enabled: (value) ->

			if value?

				@_enabled = value

				if @_enabled

					@_sprite.setRect @_texturesList.normal
					@_setEvents()

				else

					@_sprite.setRect @_texturesList.disabled
					@_resetEvents()
					mouse.setCursor "default"

			return @_enabled

		# 
		# установка и получение значения blink
		# 
		blink: (value) ->

			if value?

				@_blink = value

				if @_blink

					@_blinkStart()

				else

					@_blinkStop()

			return @_blink

		# 
		# начинаем мигание кнопки
		# 
		_blinkStart: () ->

			# 
			# может уже мигаем?
			# 
			return if @_blinkTimer?

			# 
			# счетчик состояния
			# 
			@_blinkCounter = 0
			
			# 
			# добавляем таймер
			# 
			@_blinkTimer = setInterval () =>

				# 
				# пересчет счетчика состояний
				# 
				@_blinkCounter++
				@_blinkCounter = 0 if @_blinkCounter > 1
				
				# 
				# установка нужной текстуры
				# 
				if @_blinkCounter == 1

					@_sprite.setRect @_texturesList.blink

				else

					@_sprite.setRect @_texturesList.normal

			# 
			# временной интервал мигания
			# 
			, 500

		# 
		# останавливаем мигание
		# 
		_blinkStop: () ->

			# 
			# может уже стоим?
			# 
			return unless @_blinkTimer?

			# 
			# выключаем таймер
			# 
			clearInterval @_blinkTimer
			@_blinkTimer = null

			# 
			# установка нормальной текстуры
			# 
			@_sprite.setRect @_texturesList.normal

		# 
		# сброс всех возможных событий
		# есть ли такое событие пусть разбирается Mouse
		# 
		_resetEvents: () ->

			mouse.remove @_sprite, "mouseover", @_mouseOver
			mouse.remove @_sprite, "mouseout", @_mouseOut
			mouse.remove @_sprite, "mousedown", @_mouseDown
			mouse.remove @_sprite, "mouseup", @_mouseUp
			mouse.remove @_sprite, "click", @_onClick

		# 
		# установка событий
		# 
		_setEvents: () ->

			# 
			# простые события
			# 
			mouse.add @_sprite, "mouseover", @_mouseOver if @_texturesList.mouseOver?
			mouse.add @_sprite, "mouseout", @_mouseOut if @_texturesList.mouseOver?
			mouse.add @_sprite, "mousedown", @_mouseDown if @_texturesList.mouseDown?
			mouse.add @_sprite, "mouseup", @_mouseUp if @_texturesList.mouseDown?

			# 
			# события при нажатии на кнопку
			# 
			if @action or @down or @up

				mouse.add @_sprite, "click", @_onClick

		# 
		# установить кнопку в отжатое положение
		# 
		setUp: () ->

			# 
			# нет поддержки нажатого состояния - на выход
			# 
			return unless @downSupport

			# 
			# переход в отжатое состояние
			# 
			@_downed = false
			@_sprite.setRect @_texturesList.normal


		# 
		# далее идут события мыши
		# с учетом возможности нажатого состояния
		# 

		_onClick: (e) =>

			@action() if @action

		_mouseOver: (e) =>

			# 
			# приостановим мигание, если надо
			# 
			@_blinkStop() if @_blink

			mouse.setCursor "pointer"

			if @downSupport and @_downed

				@_sprite.setRect @_texturesList.downedMouseOver

			else

				@_sprite.setRect @_texturesList.mouseOver

		_mouseOut: (e) =>

			# 
			# если надо, запускаем мигание
			# 
			@_blinkStart() if @_blink

			mouse.setCursor "default"

			if @downSupport and @_downed

				@_sprite.setRect @_texturesList.downed

			else

				@_sprite.setRect @_texturesList.normal

		_mouseDown: (e) =>

			@_downed = not @_downed if @downSupport
			@_sprite.setRect @_texturesList.mouseDown
			@down() if @_downed and @down

		_mouseUp: (e) =>

			if @downSupport and @_downed

				@_sprite.setRect @_texturesList.downedMouseOver
				@up() if not @_downed and @up

			else

				@_sprite.setRect @_texturesList.mouseOver