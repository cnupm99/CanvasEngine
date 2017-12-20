"use strict";

define ["AbstractObject"], (AbstractObject) ->

	# 
	# Абстрактный объект, отображаемый на экране,
	# имеющий для этого все необходимые свойства и методы
	# 
	class DisplayObject extends AbstractObject

		# 
		# свойсва:
		# 
		#  name:String - имя объекта для его идентификации
		#  type:String - тип объекта
		#  canvas:Canvas - канвас для рисования
		#  context:Context2d - контекст для рисования
		#  
		#  visible:Boolean - видимость объекта, устанавливаемая пользователем
		#  position:Array - позиция объекта
		#  size:Array - размер объекта
		#  realSize:Array - реальный размер объкта
		#  center:Array - относительные координаты точки центра объекта, вокруг которой происходит вращение
		#  anchor:Array - дробное число, показывающее, где должен находиться цент относительно размеров объекта
		#  scale:Array - коэффициенты для масштабирования объектов
		#  rotation:int - число в градусах, на которое объект повернут вокруг центра по часовой стрелке
		#  alpha:Number - прозрачность объекта
		#  shadow:Object - тень объекта
		#  
		#  needAnimation: Boolean - сообщает движку, нужно ли анимировать объект
		#  
		# методы:
		# 
		#  set(value:Object) - установка сразу нескольких свойств
		#  show():Boolean - 
		#  hide():Boolean - 
		#  move(value1, value2:int):Array - изменить позицию объекта
		#  shift(deltaX, deltaY:int):Array - сдвигаем объект на нужное смещение по осям
		#  resize(value1, value2:int):Array - изменить размер объекта
		#  upsize(value1, value2:int):Array - обновить реальные размеры объекта
		#  setCenter(value1, value2: int):Array - установить новый центр объекта
		#  setAnchor(value1, value2: Number):Array - установить новый якорь объекта
		#  zoom(value1, value2:Number):Array - установить масштаб объекта
		#  rotate(value:int):int - установить угол поворота объекта
		#  rotateOn(value:int):int - повернуть объект на угол относительно текщего
		#  setAlpha(value:Number):Number - установить прозрачность объекта
		#  setShadow(value:Object): Object - установить тень объекта
		#  
		#  testPoint(pointX, pointY:int):Boolean - проверка, пуста ли данная точка
		#  testRect(pointX, pointY:int):Boolean - проверка, входит ли точка в прямоугольник объекта
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
			# канвас для рисования
			# в случае сцены, создается новый канвас
			# в остальных случаях получаем из опций от родителя (сцены)
			# свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ
			# 
			if options.canvas?
			
				@canvas = options.canvas

			else

				# 
				# элемент для добавления канваса
				# всегда должен быть
				# свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ
				# 
				stage = options.parent or document.body

				# 
				# создаем канвас
				# свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ
				# 
				@canvas = document.createElement "canvas"
				@canvas.style.position = "absolute"
				stage.appendChild @canvas

			# 
			# контекст для рисования
			# в случае сцены, берется из канваса,
			# в остальных случаях получаем из опций от родителя (сцены)
			# свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ
			# 
			@context = options.context or @canvas.getContext "2d"

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
			if @visible then @show() else @hide()
			@move options.position if options.position?
			@resize options.size if options.size?
			@upsize options.realSize if options.realSize?
			@setCenter options.center if options.center?
			@setAnchor options.anchor if options.anchor?
			@zoom options.scale if options.scale?
			@rotate options.rotation if options.rotation?
			@setAlpha options.alpha if options.alpha?
			@setShadow options.shadow if options.shadow?
			@needAnimation = true

		# 
		# показать объект
		# 
		show: () -> 

			@visible = true
			@needAnimation = true
			true

		# 
		# скрыть объект
		# 
		hide: () ->

			@visible = false
			@needAnimation = true
			false

		# 
		# изменить позицию объекта
		# 
		move: (value1, value2) ->

			@position = @pixel value1, value2
			@needAnimation = true
			@position

		# 
		# сдвигаем объект на нужную величину по осям
		# 
		shift: (value1, value2 = 0) -> @move [value1 + @position[0], value2 + @position[1]]

		# 
		# изменить размер объекта
		# 
		resize: (value1, value2) ->

			@size = @pixel value1, value2
			@setAnchor @anchor
			@needAnimation = true
			@size

		# 
		# обновить реальные размеры объекта
		# 
		upsize: (value1, value2) ->

			@realSize = @pixel value1, value2
			@setAnchor @anchor
			@realSize

		# 
		# установить новый центр объекта
		# 
		setCenter: (value1, value2) ->

			@center = @pixel value1, value2

			size = if @size[0] == 0 and @size[1] == 0 then @realSize else @size
			anchorX = if size[0] == 0 then 0 else @center[0] / size[0]
			anchorY = if size[1] == 0 then 0 else @center[1] / size[1]
			@anchor = [anchorX, anchorY]

			@needAnimation = true
			@center

		# 
		# установить новый якорь объекта
		# 
		setAnchor: (value1, value2) ->

			@anchor = @point value1, value2
			
			size = if @size[0] == 0 and @size[1] == 0 then @realSize else @size
			@center = [@int(size[0] * @anchor[0]), @int(size[1] * @anchor[1])]

			@needAnimation = true
			@anchor

		# 
		# установить масштаб объекта
		# 
		zoom: (value1, value2) ->

			@scale = if value1? then @point value1, value2 else [1, 1]
			@needAnimation = true
			@scale

		# 
		# установить угол поворота объекта
		# 
		rotate: (value) ->

			@rotation = @int value
			@rotation = 360 + @rotation if @rotation < 0
			@rotation = @rotation % 360 if @rotation >= 360
			@_rotation = @rotation * @_PIDIV180
			@needAnimation = true
			@rotation

		# 
		# повернуть объект на угол относительно текщего
		# 
		rotateOn: (value) -> @rotate @rotation + @int(value)

		# 
		# установить прозрачность объекта
		# 
		setAlpha: (value) ->

			@alpha = if value then @number value else 1
			@alpha = 0 if @alpha < 0
			@alpha = 1 if @alpha > 1

			@needAnimation = true
			@alpha

		# 
		# установить тень объекта
		# 
		setShadow: (value) ->

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

			@needAnimation = true
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
			rect = @canvas.getBoundingClientRect()

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

			rect = @canvas.getBoundingClientRect()

			# 
			# если это НЕ сцена
			# 
			unless @type == "scene"

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
			# собственно сравнение координат
			# 
			return (pointX >= rect.left) and (pointX <= rect.right) and (pointY >= rect.top) and (pointY <= rect.bottom)

		# 
		# анимация объекта, запускается автоматически,
		# делать вручную это не нужно
		# 
		animate: () ->

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

			if @alpha != 1

				@context.globalAlpha = @alpha

			# смещение и поворот холста
			if @rotation != 0

				@context.translate @center[0] + @position[0], @center[1] + @position[1]
				@context.rotate @_rotation
				@_deltaX = -@center[0]
				@_deltaY = -@center[1]

			# 
			# анимация больше не нужна
			# 
			@needAnimation = false

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
			if @visible then @show() else @hide()

			# 
			# позиция объекта
			# массив вида [x, y]
			# 
			@move options.position

			# 
			# реальный размер объекта,
			# может отличаться от заданного пользователем, например
			# в случае загрузки картинки
			# 
			# пока не рассчитан программно, считается равным [0, 0]
			# 
			# массив вида [width, height]
			# 
			@realSize = [0, 0]

			# 
			# размер объекта
			# массив вида [width, height]
			# 
			@resize options.size

			# 
			# координаты точки, являющейся центром объекта,
			# вокруг этой точки производится вращение объекта
			# координаты точки задаются не относительно начала координат,
			# а относительно левого верхнего угла объекта
			# массив вида [x, y], либо объект вида {x: int, y: int}
			# 
			@setCenter options.center if options.center? or not options.anchor?

			# 
			# Якорь, дробное число, показывающее, где должен находиться цент относительно размеров объекта,
			# т.е. center = size * anchor
			# массив [number, number]
			# 
			@setAnchor options.anchor if options.anchor? and not options.center?

			# 
			# Свойство хранит коэффициенты для масштабирования объектов
			# массив вида [x, y]
			# 
			@zoom options.scale

			# 
			# поворот объекта вокруг точки center по часовой стрелке, измеряется в градусах
			# число
			# 
			@rotate options.rotation

			# 
			# прозрачность объекта
			# число от 0 до 1
			# 
			@setAlpha options.alpha

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
			@setShadow options.shadow

			# 
			# считаем, что надо нарисовать объект, если не указано иного
			# 
			@needAnimation = true