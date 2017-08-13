"use strict";

define ["AbstractObject"], (AbstractObject) ->

	# 
	# Абстрактный объект, отображаемый на экране
	# 
	class DisplayObject extends AbstractObject

		# 
		# свойсва:
		# 
		#  name: String - название объекта
		#  type: String - тип объекта
		#  context: Context2d - контекст для рисования
		#  
		# методы:
		# 
		#  testPoint(pointX, pointY) - проверка, пуста ли данная точка
		#  testRect(pointX, pointY) - проверка, входит ли точка в прямоугольник объекта
		#  animate() - попытка нарисовать объект
		# 
		constructor: (options) ->

			# 
			# конструктор базового класса
			# 
			super options

			# 
			# имя, задается пользователем, либо пустая строка
			# используется для поиска по имени
			# 
			@name = options.name or ""

			# 
			# тип объекта, каждый класс пусть присваивает самостоятельно
			# 
			@type = "DisplayObject"

			# 
			# контекст для рисования
			# либо это объект для рисования, тогда берем контекст у родителя (сцены)
			# либо это сцена, тогда она сама создаст контекст
			# 
			# свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ
			# 
			@context = @parent.context unless @context?

		# 
		# проверяем, пуста ли точка с данными координатами
		# 
		# ВНИМАНИЕ!
		# использовать этот метод ЛОКАЛЬНО нужно осторожно, так как
		# в браузерах на основе chrome будет возникать ошибка безопасности
		# (как будто пытаешься загрузить изображение с другого хоста).
		# При загрузке кода на сервер работает во всех браузерах.
		# 
		testPoint: (pointX, pointY) ->

			# 
			# получаем координаты канваса в окне
			# 
			rect = if @canvas? then @canvas.getBoundingClientRect() else @parent.canvas.getBoundingClientRect()

			# получаем координаты точки на канвасе, относительно самого канваса
			# т.е. без учета родителей,
			# считая началом координат левый верхний угол канваса
			offsetX = pointX - rect.left
			offsetY = pointY - rect.top

			# данные пикселя
			imageData = @context.getImageData offsetX, offsetY, 1, 1
			# цвет пикселя
			pixelData = imageData.data

			# проверяем нужный метод?
			pixelData.every = Array.prototype.every if not pixelData.every?

			# проверяем все цвета, если 0, значит мимо
			return not pixelData.every (value) -> value == 0

		# 
		# находится ли точка внутри объекта по его позиции / размерам
		# 
		testRect: (pointX, pointY) ->

			# 
			# если это НЕ сцена
			# 
			unless @canvas?

				# 
				# получаем координаты канваса сцены
				# 
				rect = @parent.canvas.getBoundingClientRect()
				
				# 
				# корректируем позицией и размерами объекта
				# 
				rect = {

					left: rect.left + @position[0]
					top: rect.top + @position[1]
					right: rect.left + @position[0] + @size[0]
					bottom: rect.top + @position[1] + @size[1]

				}

			# 
			# а если это сцена, то просто получаем ее размеры
			# 
			else rect = @canvas.getBoundingClientRect()

			# 
			# собственно сравнение координат
			# 
			return (pointX >= rect.left) and (pointX <= rect.right) and (pointY >= rect.top) and (pointY <= rect.bottom)

		# 
		# анимация объекта, запускается автоматически,
		# делать вручную это не нужно
		# 
		animate: () ->

			# если объект не видимый
			# то рисовать его не нужно
			unless @visible

				@needAnimation = false
				return

			# сохранить контекст
			@context.save()

			# смещение
			@_deltaX = @position[0]
			@_deltaY = @position[1]

			# установка тени
			if @shadow

				@context.shadowColor = @shadow.color
				@context.shadowBlur = @shadow.blur
				@context.shadowOffsetX = Math.max @shadow.offsetX, @shadow.offset
				@context.shadowOffsetY = Math.max @shadow.offsetY, @shadow.offset

			if @scale[0] != 1 or @scale[1] != 1

				@context.scale @scale[0], @scale[1]

			# смещение и поворот холста
			if @rotation != 0

				@context.translate @center[0] + @position[0], @center[1] + @position[1]
				@context.rotate @deg2rad(@rotation)
				@_deltaX = -@center[0]
				@_deltaY = -@center[1]

			# анимация больше не нужна
			@needAnimation = false