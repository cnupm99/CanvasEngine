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
		#  visible: Boolean - видимость объекта, устанавливаемая пользователем
		#  position: Array - позиция объекта
		#  size: Array - размер объекта
		#  realSize: Array - реальный размер объкта
		#  center: Array - относительные координаты точки центра объекта, вокруг которой происходит вращение
		#  anchor: Array - дробное число, показывающее, где должен находиться цент относительно размеров объекта
		#  scale: Array - коэффициенты для масштабирования объектов
		#  rotation: Number - число в градусах, на которое объект повернут вокруг центра по часовой стрелке
		#  alpha: [0..1] - прозрачность объекта
		#  mask: Array - маска объекта
		#  shadow: Object - тень объекта
		#  
		# методы:
		# 
		#  testPoint(pointX, pointY) - проверка, пуста ли данная точка
		#  testRect(pointX, pointY) - проверка, входит ли точка в прямоугольник объекта
		#  shift(deltaX, deltaY:int):Array - сдвигаем объект на нужное смещение по осям
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
			# установка свойств
			# 
			@_setProperties options

		# 
		# Установка всех или определенных свойств через объект опций
		# 
		set: (options) ->

			return unless options?

			@visible = options.visible if options.visible?
			@position = @pixel options.position if options.position?
			@size = @pixel options.size if options.size?
			@realSize = @pixel options.realSize if options.realSize?
			@focus options.center if options.center?
			@attach options.anchor if options.anchor?
			@scale = @point options.scale if options.scale?
			@rotation = @number options.rotation if options.rotation?
			@opasity options.alpha if options.alpha?
			@shade options.shadow if options.shadow?

			@parent.needAnimation = true

		# 
		# показать объект
		# 
		show: () -> 

			return if @visible
			@visible = true
			@parent.needAnimation = true
			true

		# 
		# скрыть объект
		# 
		hide: () ->

			return unless @visible
			@visible = false
			@parent.needAnimation = true
			false

		# 
		# изменить позицию объекта
		# 
		move: (value1, value2) ->

			position = @pixel value1, value2
			return if position[0] == @position[0] and position[1] == @position[1]
			@position = position
			@parent.needAnimation = true
			@position

		# 
		# сдвигаем объект на нужную величину по осям
		# 
		shift: (value1, value2) -> @move [value1 + @position[0], value2 + @position[1]]

		# 
		# изменить размер объекта
		# 
		resize: (value1, value2) ->

			size = @pixel value1, value2
			return if size[0] == @size[0] and size[1] == @size[1]
			@size = size
			@attach @anchor
			@parent.needAnimation = true
			@size

		# 
		# обновить реальные размеры объекта
		# 
		upsize: (value1, value2) ->

			size = @pixel value1, value2
			return if size[0] == @realSize[0] and size[1] == @realSize[1]
			@realSize = size
			@attach @anchor
			@realSize

		# 
		# установить новый центр объекта
		# 
		focus: (value1, value2) ->

			center = @pixel value1, value2
			return if center[0] == @center[0] and center[1] == @center[1]
			@center = center

			size = if @size[0] == 0 and @size[1] == 0 then @realSize else @size
			anchorX = if size[0] == 0 then 0 else @center[0] / size[0]
			anchorY = if size[1] == 0 then 0 else @center[1] / size[1]
			@anchor = [anchorX, anchorY]

			@parent.needAnimation = true
			@center

		# 
		# установить новый якорь объекта
		# 
		attach: (value1, value2) ->

			@anchor = @point value1, value2
			
			size = if @size[0] == 0 and @size[1] == 0 then @realSize else @size
			@center = [@int(size[0] * @anchor[0]), @int(size[1] * @anchor[1])]

			@parent.needAnimation = true
			@anchor

		# 
		# установить масштаб объекта
		# 
		scaling: (value1, value2) ->

			scale = if value1? then @point value1, value2 else [1, 1]
			return if scale[0] == @scale[0] and scale[1] == @scale[1]
			@scale = scale
			@parent.needAnimation = true
			@scale

		# 
		# установить угол поворота объекта
		# 
		rotate: (value) ->

			rotation = @int value
			rotation = 360 + rotation if rotation < 0
			rotation = rotation % 360 if rotation >= 360
			return if rotation == @rotation
			@rotation = rotation
			@_rotation = @rotation * @_PIDIV180
			@parent.needAnimation = true
			@rotation

		# 
		# повернуть объект на угол относительно текщего
		# 
		rotateOn: (value) -> @rotate @rotation + @int(value)

		# 
		# установить прозрачность объекта
		# 
		opasity: (value) ->

			alpha = if value then @number value else 1
			alpha = 0 if alpha < 0
			alpha = 1 if alpha > 1
			return if alpha == @alpha
			@alpha = alpha

			@parent.needAnimation = true
			@alpha

		shade: (value) ->

			if (not value?) or (not value) then @shadow = false
			else

				@shadow = {

					# 
					# не проверяем значения color и blur, потому что по умолчанию они отличны от 0
					# 
					color: value.color or "#000"
					blur: value.blur or 3
					offsetX: @int value.offsetX
					offsetY: @int value.offsetY
					offset: @int value.offset

				}

			@parent.needAnimation = true
			@shadow

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

			# ищем контекст
			context = @context or @parent.context
			# данные пикселя
			imageData = context.getImageData offsetX, offsetY, 1, 1
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
		animate: (context) ->

			# смещение
			@_deltaX = @position[0]
			@_deltaY = @position[1]

			# установка тени
			if @shadow

				context.shadowColor = @shadow.color
				context.shadowBlur = @shadow.blur
				context.shadowOffsetX = Math.max @shadow.offsetX, @shadow.offset
				context.shadowOffsetY = Math.max @shadow.offsetY, @shadow.offset

			if @scale[0] != 1 or @scale[1] != 1

				context.scale @scale[0], @scale[1]

			if @alpha != 1

				context.globalAlpha = @alpha

			# смещение и поворот холста
			if @rotation != 0

				context.translate @center[0] + @position[0], @center[1] + @position[1]
				context.rotate @_rotation
				@_deltaX = -@center[0]
				@_deltaY = -@center[1]

		# 
		# Создание и установка свойств объекта
		# 
		_setProperties: (options) ->

			# 
			# Ниже идут свойтсва объекта
			# 

			# 
			# видимость объекта, устанавливаемая пользователем
			# true / false
			# 
			@visible = if options.visible? then options.visible else true

			# 
			# позиция объекта
			# массив вида [x, y], либо объект вида {x: int, y: int}
			# 
			@position = @pixel options.position

			# 
			# реальный размер объекта,
			# может отличаться от заданного пользователем, например
			# в случае загрузки картинки
			# 
			# пока не рассчитан программно, считается равным [0, 0]
			# 
			# массив вида [width, height], либо объект вида {width: int, height: int}
			# 
			@realSize = [0, 0]

			# 
			# размер объекта
			# массив вида [width, height], либо объект вида {width: int, height: int}
			# 
			@size = @pixel options.size

			# 
			# координаты точки, являющейся центром объекта,
			# вокруг этой точки производится вращение объекта
			# координаты точки задаются не относительно начала координат,
			# а относительно левого верхнего угла объекта
			# массив вида [x, y], либо объект вида {x: int, y: int}
			# 
			if options.center? or not options.anchor?

				@center = [0, 0]
				@focus options.center

			# 
			# Якорь, дробное число, показывающее, где должен находиться цент относительно размеров объекта,
			# т.е. center = size * anchor
			# массив [number, number]
			# 
			if options.anchor? and not options.center?

				@anchor = [0, 0]
				@attach options.anchor

			# 
			# Свойство хранит коэффициенты для масштабирования объектов
			# массив вида [x, y]
			# 
			@scale = if options.scale then @point options.scale else [1, 1]

			# 
			# поворот объекта вокруг точки center по часовой стрелке, измеряется в градусах
			# число
			# 
			@rotation = @int options.rotation

			# 
			# прозрачность объекта
			# число от 0 до 1
			# 
			@alpha = options.alpha or 1

			# 
			# тень объекта
			# объект вида {color: string, blur: int, offsetX: int, offsetY: int, offset: int} или false
			# не нужно указывать одновременно offsetX, offsetY и offset
			# offset указывается вместо offsetX и offsetY, если offsetX == offsetY
			# 
			# ВНИМАНИЕ!
			# В браузере firefox есть баг (на 25.04.17), а именно:
			# при попытке нарисовать на канве изображение, используя одновременно
			# маску и тень (mask и shadow в данном случае), получается
			# странная хрень, а точнее маска НЕ работает в данном случае
			# Доказательство и пример здесь: http://codepen.io/cnupm99/pen/wdGKBO
			#
			@shadow = options.shadow or false