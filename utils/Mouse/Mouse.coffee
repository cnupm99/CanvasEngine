"use strict";

define () ->

	# 
	# Класс для добавления в CanvasEngine событий мыши
	# 

	class Mouse

		# указываем родителя, на котором находится CanvasEngine
		constructor: (parent) ->

			@_parent = parent or document.body

			# список событий
			@_events = []
			# включены ли слушатели
			@_enabled = false

		# добавляем событие
		# _object: CanvasEngine object - графический объект движка
		# _event: String - событие мыши, одно из: mousemove, mouseover, mouseout, mousedown, mouseup, click
		# func: Function - выполняемая функция
		# type: String - 
		# 	"rect" - сравнение по координатам
		# 	"point" - сравнение по точке
		# 	"both" - сначала по координатам, потом по точке
		add: (_object, _event, func, type = "both") ->

			# проверяем нет ли уже такого события
			index = @_getIndex _object, _event, func, type

			return true if index >= 0

			# добавляем
			@_events.push {

				object: _object
				event: _event
				func: func
				# мышь над объектом
				mouseOn: false
				# нажата клавиша над объектом
				mouseDown: false
				type: type

			}

			# если нужно, подключаем слушателей
			unless @_enabled

				@_parent.addEventListener "mousemove", @_mouseMove
				@_parent.addEventListener "mousedown", @_mouseDown
				@_parent.addEventListener "mouseup", @_mouseUp
				@_enabled = true

		# удаляем событие
		remove: (_object, _event, func, type = "both") ->

			index = @_getIndex _object, _event, func, type

			return false if index < 0

			@_events.splice index, 1

			# выключаем, если нет ниодного события
			if @_events.length == 0

				@_parent.removeEventListener "mousemove", @_mouseMove
				@_parent.removeEventListener "mousedown", @_mouseDown
				@_parent.removeEventListener "mouseup", @_mouseUp
				@_enabled = false

		# установка курсора
		# style: String, одно из pointer, default и т.п.
		setCursor: (style) ->

			@_parent.style.cursor = style

		# возвращает индекс события в массиве
		_getIndex: (_object, _event, func, type = "both") ->

			index = -1

			@_events.some (e, i) =>

				if e.object == _object and e.event == _event and e.func == func and e.type == type

					index = i
					return true

				return false

			return index

		_mouseUp: (e) =>

			@_events.forEach (_event) ->

				# 
				# невозвомжно взаимодействовать с невидимыми объектами
				# 
				return unless _event.object.visible

				_event.func e, _event.object if _event.mouseOn and _event.event == "mouseup"
				# клик формируем сами, если нажали и отпустили над объектом
				_event.func e, _event.object if _event.mouseOn and _event.mouseDown and _event.event == "click"
				# даже если мышь не над объектом
				_event.mouseDown = false

		_mouseDown: (e) =>

			@_events.forEach (_event) ->

				# 
				# невозвомжно взаимодействовать с невидимыми объектами
				# 
				return unless _event.object.visible

				if _event.mouseOn 

					_event.func e, _event.object if _event.event == "mousedown"
					# только если мышь над объектом
					_event.mouseDown = true

		_mouseMove: (e) =>

			@_events.forEach (_event) ->

				# 
				# невозвомжно взаимодействовать с невидимыми объектами
				# 
				return unless _event.object.visible

				# здесь мы проверяем, над объектом ли мышь, используя нужный метод объекта
				mouseOn = false
				switch _event.type

					when "rect" then mouseOn = _event.object.testRect e.pageX, e.pageY
					when "point" then mouseOn = _event.object.testPoint e.pageX, e.pageY
					when "both" then mouseOn = _event.object.testRect(e.pageX, e.pageY) and _event.object.testPoint(e.pageX, e.pageY)

				_event.func e, _event.object if mouseOn and _event.event == "mousemove"
				
				_event.func e, _event.object if mouseOn and not _event.mouseOn and _event.event == "mouseover"

				_event.func e, _event.object if not mouseOn and _event.mouseOn and _event.event == "mouseout"

				_event.mouseOn = mouseOn