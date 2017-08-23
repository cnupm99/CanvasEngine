#
# CanvasEngine
#
# version 1.10
# build 75
# Wed Aug 23 2017
#

"use strict";

define () ->

	# 
	# Абстрактный объект, не имеющий отображения на экране
	# но вмещающий в себя общедоступные базовые методы
	# 
	class AbstractObject

		# 
		# методы:
		# 
		#  point(value1, value2):Array - приведение выражений к виду [x, y]
		#  pixel(value1, value2):Array - округляет результат pixel
		#  int(value):int - приведение к целому числу
		#  number(value):Number - приведение к числу
		#  deg2rad(value):Number - перевод из градусов в радианы
		#  
		# константы:
		# 
		#  _PIDIV180 = Math.PI / 180
		#  

		constructor: (options) ->

			# 
			# если ничего не передано в качестве опций, создаем пустой объект
			# чтобы можно было обратиться к его свойствам
			# 
			options = {} unless options?

		# 
		# приведение выражений к виду [x, y]
		# 
		# 	все точки хранятся и передаются в виде массивов [x, y]
		# 	чтобы сократить время и объем записей множества точек
		# 	
		# 	если ничего не передано, возвращает [0, 0]
		# 	если передано два параметра, вернет [value1, value2]
		# 	если первый параметр массив, то вернет [value1[0], value1[1]]
		# 	если первый параметр объект, то вернет [value1.x, value1.y] либо [value1.width, value1.height]
		# 	иначе вeрнет [0, 0]
		# 	
		point: (value1, value2) ->

			# значение не существует
			return [0, 0] if (not value1?)

			# передано два параметра, считаем их числами и возвращаем массив
			return [@number(value1), @number(value2)] if value2?

			# если передан массив
			if Array.isArray value1

				# возвращаем первые два элемента
				return [@number(value1[0]), @number(value1[1])]

			# может быть это объект?
			else

				# если есть свойства x и y
				return [@number(value1.x), @number(value1.y)] if value1.x? and value1.y?
				# если есть свойства width и height
				return [@number(value1.width), @number(value1.height)] if value1.width? and value1.height?
				# по умолчанию
				return [0, 0]

		# 
		# Округляет результ point
		# 
		pixel: (value1, value2) ->

			result = @point value1, value2
			[result[0] >> 0, result[1] >> 0]

		# 
		# приведение выражения к целому числу
		# 
		int: (value) -> @number(value) >> 0

		# 
		# приведение выражения к числу
		# 
		number: (value) -> if value? then +value else 0

		# 
		# переводим градусы в радианы
		# 
		deg2rad: (value) -> @number(value) * @_PIDIV180

		# 
		# константа, для ускорения рассчетов
		# используется в rad
		# 
		_PIDIV180: Math.PI / 180

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
			# в случае сцены, создается до вызова этого конструктора,
			# в остальных случаях получаем из опций от родителя (сцены)
			# свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ
			# 
			@canvas = options.canvas unless @canvas

			# 
			# контекст для рисования
			# в случае сцены, создается до вызова этого конструктора,
			# в остальных случаях получаем из опций от родителя (сцены)
			# свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ
			# 
			@context = options.context unless @context

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
		shift: (value1, value2) -> @move [value1 + @position[0], value2 + @position[1]]

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

	class ContainerObject extends DisplayObject

		# 
		# свойства:
		# 
		#  childrens:Array - массив дочерних объектов
		#  
		# методы:
		# 
		#  get(childName:String):Object/false - поиск среди дочерних элементов по имени элемента
		#  remove(childName:String):Boolean - удаление дочернего элемента по его имени
		#  rename(oldName, newName:String):Boolean - переименование дочернего элемента
		#  index(childName:String):int - возвращает индекс элемента в массиве дочерних по его имени
		#  
		constructor: (options) ->

			super options

			# 
			# массив дочерних элементов,
			# для CanvasEngine это Scene
			# для Scene остальные элементы
			# для остальных элементов - массив пустой
			# свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ
			# 
			@childrens = []

		# 
		# поиск среди дочерних элементов по имени элемента
		# 
		get: (childName) ->

			index = @index childName
			if index == -1 then return false
			return @childrens[index]

		# 
		# удаление дочернего элемента по его имени
		# 
		remove: (childName) ->

			index = @index childName
			if index == -1 then return false
			@childrens.splice index, 1
			return true

		# 
		# переименование дочернего элемента
		# 
		rename: (oldName, newName) ->

			index = @index oldName
			if index == -1 then return false
			@childrens[index].name = newName
			return true

		# 
		# возвращает индекс элемента в массиве дочерних по его имени
		# 
		index: (childName) ->

			result = -1

			@childrens.some (child, index) ->

				flag = child.name == childName
				result = index if flag
				return flag

			return result

	# 
	# Класс для рисования графических примитивов
	# 
	# методы:
	# 
	#  clear() - очистка экрана и команд
	#  beginPath() - начало отрисовки линии
	#  lineCap(value:String) - установить стиль окончания линий
	#  strokeStyle(style:String) - стиль линий
	#  fillStyle(style:String) - стиль заливки
	#  linearGradient(x1, y1, x2, y2:int, colors:Array) - установка градиента
	#  lineWidth(value:int) - толщина линий
	#  setLineDash(value:Arrow) - установка пунктирной линии
	#  lineDashOffset(value:int) - смещение пунктирной линии
	#  moveTo(x, y:int) - перемещение указателя
	#  lineTo(x, y:int) - линия в указанную точку
	#  line(x1, y1, x2, y2:int) - рисуем линию по двум точкам
	#  rect(x, y, width, height, radius:int) - рисуем прямоугольник (опционально скругленный)
	#  polyline(points:Array, needDraw:Boolean) - полилиния
	#  polygon(points:Array) - полигон
	#  fill() - заливка фигуры
	#  stroke() - прорисовка контура
	#  animate() - попытка нарисовать объект
	#  log() - выводим массив комманд в консоль
	# 
	class Graph extends DisplayObject

		constructor: (options) ->

			super options

			# массив команд для рисования
			@_commands = []

		# 
		# Далее идут функции для рисования графических примитивов
		# Все они сохраняют свои данные в _commands
		# 

		# 
		# очистка экрана и команд
		# 
		clear: () -> 

			@_commands = []
			@needAnimation = true

		# 
		# начало отрисовки линии
		# 
		beginPath: () ->

			@_commands.push {

				"command": "beginPath"

			}

		# 
		# установить стиль окончания линий
		# 
		lineCap: (value) ->

			@_commands.push {

				"command": "lineCap"
				"lineCap": value

			}

		# 
		# стиль линий
		# 
		strokeStyle: (style) ->

			@_commands.push {

				"command": "strokeStyle"
				"style": style

			}

		# 
		# стиль заливки
		# 
		fillStyle: (style) ->

			@_commands.push {

				"command": "fillStyle"
				"style": style

			}

		# 
		# устновка градиента
		# colors = Array [ [size, color], .... ], где color:String, size:Number [0..1]
		# 
		linearGradient: (x1, y1, x2, y2, colors) ->

			@_commands.push {

				"command": "gradient"
				"point1": @pixel x1, y1
				"point2": @pixel x2, y2
				"colors": colors

			}

		# 
		# толщина линий
		# 
		lineWidth: (width) ->

			@_commands.push {

				"command": "lineWidth"
				"width": @int width

			}

		# 
		# установка пунктирной линии
		# 
		setLineDash: (dash) ->

			@_commands.push {

				"command": "setDash"
				"dash": dash

			}

		# 
		# смещение пунктирной линии
		# 
		lineDashOffset: (offset) ->

			@_commands.push {

				"command": "dashOffset"
				"offset": @int offset

			}

		# 
		# Перевод указателя в точку
		# 
		moveTo: (toX, toY) ->

			@_commands.push {

				"command": "moveTo"
				"point": @pixel toX, toY

			}

		# 
		# Линия из текущей точки в указанную
		# 
		lineTo: (toX, toY) ->

			@_commands.push {

				"command": "lineTo"
				"point": @pixel toX, toY

			}

			@needAnimation = true

		# 
		# рисуем линию, соединяющую две точки,
		# разница между moveTo + lineTo еще и в том, что line рисует линию,
		# т.е. автоматически делает stroke()
		# 
		line: (fromX, fromY, toX, toY) ->

			@_commands.push {

				"command": "line"
				"from": @pixel fromX, fromY
				"to": @pixel toX, toY

			}

			@needAnimation = true

		# 
		# рисуем прямоугольник, если указан radius, то скругляем углы
		# 
		rect: (fromX, fromY, width, height, radius = 0) ->

			@_commands.push {

				"command": "rect"
				"point": @pixel fromX, fromY
				"size": @pixel width, height
				"radius": @int radius

			}

			@needAnimation = true

		# 
		# линия из множества точек
		# второй параметр говорит, нужно ли ее рисовать,
		# он нужен, чтобы рисовать многоугольники без границы
		# 
		polyline: (points, stroke = true) ->

			@_commands.push {

				"command": "beginPath"

			}

			@moveTo points[0][0], points[0][1]

			points.forEach (point) => @lineTo point[0], point[1]

			if stroke then @stroke()

			@needAnimation = true

		# 
		# полигон
		# 
		polygon: (points) ->

			@polyline points, false
			@lineTo points[0][0], points[0][1]

			@stroke()
			@fill()

		# 
		# Заливка
		# 
		fill: () ->

			@_commands.push {

				"command": "fill"

			}

			@needAnimation = true

		# 
		# Рисуем контур
		# 
		stroke: () ->

			@_commands.push {

				"command": "stroke"

			}

			@needAnimation = true

		animate: () ->

			super()

			# 
			# установим закругленные окончания линий
			# 
			@context.lineCap = "round"

			# 
			# перебираем все команды в массиве команд и выполняем соответствующие действия
			# можно было поменять строковые команды на числа вида 0, 1, 2 .... и т.д.,
			# но зачем?
			# 
			@_commands.forEach (command) =>

				switch command.command

					when "beginPath" then @context.beginPath()

					when "lineCap" then @context.lineCap = command.lineCap

					when "stroke" then @context.stroke()

					when "fill" then @context.fill()

					when "setDash" then @context.setLineDash command.dash

					when "dashOffset" then @context.lineDashOffset = command.offset

					when "moveTo" then @context.moveTo command.point[0] + @_deltaX, command.point[1] + @_deltaY

					when "lineTo" then @context.lineTo command.point[0] + @_deltaX, command.point[1] + @_deltaY

					when "line"

						@context.beginPath()
						@context.moveTo command.from[0] + @_deltaX, command.from[1] + @_deltaY
						@context.lineTo command.to[0] + @_deltaX, command.to[1] + @_deltaY
						@context.stroke()

					when "strokeStyle" then @context.strokeStyle = command.style

					when "fillStyle" then @context.fillStyle = command.style

					when "lineWidth" then @context.lineWidth = command.width

					when "rect"

						@context.beginPath()
						
						# обычный прямоугольник
						if command.radius == 0
						
							@context.rect command.point[0] + @_deltaX, command.point[1] + @_deltaY, command.size[0], command.size[1]

						# прямоугольник со скругленными углами
						else @_drawRoundedRect @context, command.point[0] + @_deltaX, command.point[1] + @_deltaY, command.size[0], command.size[1], command.radius

					when "gradient"

						# создаем градиент по нужным точкам
						gradient = @context.createLinearGradient command.point1[0] + @_deltaX, command.point1[1] + @_deltaY, command.point2[0] + @_deltaX, command.point2[1] + @_deltaY
						# добавляем цвета
						command.colors.forEach (color) ->
							# сначала размер, потом цвет
							gradient.addColorStop color[0], color[1]
						# заливка градиентом
						@context.fillStyle = gradient

		# 
		# В информационных целях
		# выводим массив комманд в консоль
		# 
		log: () -> console.log @_commands

		# 
		# рисуем пряоугольник со скругленными углами
		# 
		_drawRoundedRect: (context, x, y, width, height, radius) ->

			# предварительные вычисления
			pi = Math.PI
			halfpi = pi / 2
			x1 = x + radius
			x2 = x + width - radius
			y1 = y + radius
			y2 = y + height - radius
			# рисуем
			context.moveTo x1, y
			context.lineTo x2, y
			context.arc x2, y1, radius, -halfpi, 0
			context.lineTo x + width, y2
			context.arc x2, y2, radius, 0, halfpi
			context.lineTo x1, y + height
			context.arc x1, y2, radius, halfpi, pi
			context.lineTo x, y1
			context.arc x1, y1, radius, pi, 3 * halfpi

	class Image extends DisplayObject

		# 
		# Класс для загрузки и отображения изображений
		# 
		# свойства:
		# 
		#  onload:Function - ссылка на функцию, которая должна выполниться после загрузки картинки
		#  loaded:Boolean - загружена ли картинка
		#  image:Image - объект картинки
		#  loadedFrom:String - строка с адресом картинки
		#  
		# методы:
		# 
		#  src(url:string): загрузка картинки с указанным адресом
		#  from(image:Image, url:String) - создание из уже существующей и загруженной картинки
		#  animate() - попытка нарисовать объект
		# 
		constructor: (options) ->

			# 
			# создаем класс родителя
			# 
			super options

			# 
			# тип объекта
			# 
			@type = "image"

			# 
			# событие, выполняемое при загрузке картинки
			# 
			@onload = options.onload

			# 
			# Загружена ли картинка,
			# в данный момент нет,
			# а значит рисовать ее не нужно
			# 
			@loaded = false

			# 
			# создаем элемент
			# 
			@image = document.createElement "img"

			# 
			# Событие при загрузке картинки
			# 
			@image.onload = @_imageOnLoad

			# 
			# Здесь будем хранить src картинки как строку.
			# При вызове src картика загружается, а адрес устанавливается в loadedFrom
			# При присвоении loadedFrom картинка не загружается
			# Это просто строка для хранения адреса картинки
			# 
			@loadedFrom = ""

			# 
			# нужно ли загружать картинку
			# 
			if options.src?
				
				@src options.src

			# 
			# или она уже загружена
			# 
			else 

				@from options.from

		# 
		# Метод для загрузки картики
		# 
		src: (value) ->

			@loaded = false
			@loadedFrom = value

			# загружаем
			@image.src = value

		# 
		# Создание картинки из уже созданной и загруженной
		# 	
		# 	image: Image
		# 	src: String // не обязательно
		# 
		from: (from, src) ->

			# 
			# если картинки нет, то нет смысла продолжать
			# 
			return unless from?

			# 
			# а вот и картинка
			# 
			@image = from

			# 
			# Запоминаем src
			# 
			@loadedFrom = src or ""

			# 
			# запоминаем реальные размеры
			# 
			@upsize [@image.width, @image.height]

			# 
			# если нужно меняем размеры
			# иначе потом будем масштабировать
			# 
			@resize @realSize if @size[0] <= 0 or @size[1] <= 0

			# можно рисовать
			@loaded = true
			@needAnimation = true

		animate: () ->

			# 
			# если картинка не загружена, то рисовать ее не будем
			# 
			return unless @loaded

			# 
			# действия по умолчанию для DisplayObject
			# 
			super()

			# 
			# рисуем в реальном размере?
			# 
			if @size[0] == @realSize[0] and @size[1] == @realSize[1]

				@context.drawImage @image, @_deltaX, @_deltaY

			else

				# 
				# тут масштабируем картинку
				# 
				@context.drawImage @image, @_deltaX, @_deltaY, @size[0], @size[1]

		_imageOnLoad: (e) =>

			# 
			# запоминаем реальные размеры
			# 
			@upsize [@image.width, @image.height]

			# 
			# если нужно меняем размеры
			# иначе потом будем масштабировать
			# 
			@resize @realSize if @size[0] <= 0 or @size[1] <= 0

			@loaded = true
			@needAnimation = true

			# 
			# если у картинки есть свойство onload, то вызываем его и
			# сообщаем реальные размеры картинки
			# 
			@onload @realSize if @onload?

	# 
	# Класс для вывода текстовой информации
	# 
	# свойства:
	# 
	#  fontHeight:int - высота текста с текущим шрифтом
	#  textWidth:int - ширина текущего текста
	#  font:String - текущий шрифт
	#  fillStyle:String/Array/Boolean - текущая заливка, градиент или false, если заливка не нужна
	#  strokeStyle:String/Boolean - обводка шрифта или false, если обводка не нужна
	#  strokeWidth:int - ширина обводки
	#  text:String - отображаемый текст
	#  
	# методы:
	# 
	#  setFont(font:String):String - установка шрифта
	#  setFillStyle(style:String/Array):String/Array - установка заливки текста
	#  setStrokeStyle(style:String):String - установка обводки
	#  setStrokeWidth(value:int):int - толщина обводки
	#  write(text:String):String - установка текста
	#  animate() - попытка нарисовать объект
	# 
	class Text extends DisplayObject

		constructor: (options) ->

			super options

			# 
			# высота текста с текущим шрифтом,
			# вычисляется автоматичекски при установке шрифта
			# 
			@fontHeight = 0

			# 
			# ширина текущего текста
			# вычисляется автоматически при установке текста
			# 
			@textWidth = 0

			# 
			# шрифт надписи, строка
			# 
			@setFont options.font

			# 
			# текущая заливка, градиент или false, если заливка не нужна
			# 
			@setFillStyle options.fillStyle

			# 
			# обводка шрифта или false, если обводка не нужна
			# 
			@setStrokeStyle = options.strokeStyle or false

			# 
			# ширина обводки
			# 
			@setStrokeWidth options.strokeWidth

			# 
			# текущий текст надписи
			# 
			@write options.text

		setFont: (value) ->

			@font = value or "12px Arial"

			# 
			# устанавливаем реальную высоту шрифта в пикселях
			# 
			span = document.createElement "span"
			span.appendChild document.createTextNode("height")
			span.style.cssText = "font: " + @font + "; white-space: nowrap; display: inline;"
			document.body.appendChild span
			@fontHeight = span.offsetHeight
			document.body.removeChild span

			@needAnimation = true
			@font

		setFillStyle: (value) ->

			@fillStyle = value or false
			@needAnimation = true
			@fillStyle

		setStrokeStyle: (value) ->

			@strokeStyle = value or false
			@needAnimation = true
			@strokeStyle

		setStrokeWidth: (value) ->

			@strokeWidth = if value? then @int value else 1
			@needAnimation = true
			@strokeWidth

		write: (value) ->

			@text = value or ""

			# 
			# определяем ширину текста
			# используя для этого ссылку на контекст
			# 
			@context.save()
			@context.font = @font
			@textWidth = @context.measureText(@text).width
			@context.restore()

			@needAnimation = true
			@text

		animate: () ->

			super()

			# 
			# установим шрифт контекста
			# 
			@context.font = @font

			# 
			# по умолчанию позиционируем текст по верхнему краю
			# 
			@context.textBaseline = "top"
			
			# 
			# нужна ли заливка
			# 
			if @fillStyle

				# а может зальем текст градиентом?
				if Array.isArray @fillStyle

					# 
					# создаем градиент по нужным точкам
					# 
					gradient = @context.createLinearGradient @_deltaX, @_deltaY, @_deltaX, @_deltaY + @fontHeight

					# 
					# добавляем цвета
					# 
					@fillStyle.forEach (color) ->
						
						# сначала размер, потом цвет
						gradient.addColorStop color[0], color[1]

					# 
					# заливка градиентом
					# 
					@context.fillStyle = gradient

				# 
				# ну или просто цветом
				# 
				else @context.fillStyle = @fillStyle

				# 
				# выводим залитый текст
				# 
				@context.fillText @text, @_deltaX, @_deltaY

			# 
			# что насчет обводки?
			# 
			if @strokeStyle

				@context.strokeStyle = @strokeStyle
				@context.lineWidth = @strokeWidth
				@context.strokeText @text, @_deltaX, @_deltaY

	# 
	# Изображение, которое замостит указанную область
	# 
	# свойства:
	#  
	#  rect:Array - прямоугольник для замастивания
	#  
	# методы:
	# 
	#  setRect(value:Array):Array - установка области
	#  animate() - попытка нарисовать объект 
	# 
	class TilingImage extends Image

		constructor: (options) ->

			super options

			# 
			# область замостивания по умолчанию равна размеру контекста
			# 
			# массив вида [int, int, int, int]
			# 
			@setRect options.rect

		# 
		# Установка области
		# 
		setRect: (value) ->

			@rect = value or [0, 0, @canvas.width, @canvas.height]
			@needAnimation = true
			@rect

		animate: () ->

			return unless @loaded

			# 
			# Начало отрисовки
			# 
			@context.beginPath()

			# 
			# создаем паттерн
			# 
			@context.fillStyle = @context.createPattern @image, "repeat"

			# 
			# рисуем прямоугольник
			# 
			@context.rect @rect[0], @rect[1], @rect[2], @rect[3]

			# 
			# заливаем паттерном
			# 
			@context.fill()

	class Scene extends ContainerObject

		# 
		# Класс сцены, на который добавляются все дочерние объекты
		# Фактически представляет собой canvas
		# 
		# свойства:
		# 
		#  canvas:Element - canvas для рисования, создается автоматически
		#  context:context2d - контекст для рисования, создается автоматически
		#  zIndex:int - индекс, определяющий порядок сцен, чем выше индекс, тем выше сцена над остальными
		#  mask:Array - маска объекта
		#  needAnimation:Boolean - нужно ли анимировать данный объект с точки зрения движка
		#  
		# методы:
		# 
		#  add(data:Object):DisplayObject - добавление дочернего объекта
		#  animate() - попытка нарисовать объект
		#  
		# установка свойств:
		# 
		#  setMask(value:Object):Object - установка маски
		#  setZIndex(value:int):int - установка зед индекса канваса
		#  hide() - скрыть сцену
		#  move(value1, value2:int):Array - изменить позицию канваса
		#  resize(value1, value2:int):Array - изменить размер канваса
		#  setCenter(value1, value2:int):Array - установить новый центр канваса
		#  setAnchor(value1, value2:int):Array - установить якорь канваса
		#  rotate(value:int):int - установить угол поворота канваса
		#  setAlpha(value:Number):Number - установить прозрачность канваса
		# 
		constructor: (options) ->

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
			# контекст
			# свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ
			# 
			@context = @canvas.getContext "2d"

			# 
			# создаем DisplayObject
			# 
			super options

			# 
			# тип объекта
			# 
			@type = "scene"

			# 
			# индекс, определяющий порядок сцен, чем выше индекс, тем выше сцена над остальными
			# целое число >= 0
			# 
			@setZIndex options.zIndex

			# 
			# прямоугольная маска, применимо к Scene
			# если маска дейтсвует, то на сцене будет отображаться только объекты внутри маски
			# массив [int, int, int, int] или false
			# 
			# ВНИМАНИЕ!
			# В браузере firefox есть баг (на 25.04.17), а именно:
			# при попытке нарисовать на канве изображение, используя одновременно
			# маску и тень (mask и shadow в данном случае), получается
			# странная хрень, а точнее маска НЕ работает в данном случае
			# Доказательство и пример здесь: http://codepen.io/cnupm99/pen/wdGKBO
			# 
			@setMask options.mask

			# 
			# нужно ли анимировать данный объект с точки зрения движка
			# не нужно в ручную менять это свойство, для этого есть visible
			# 
			@needAnimation = false

		# 
		# создание и добавление дочерних объектов в список анимации
		# 
		add: (options) ->

			# 
			# нет типа - нечего создавать
			# 
			return unless options.type?

			# 
			# если нужно, задаем значения по умолчанию
			# 
			options.visible = @visible unless options.visible?
			options.shadow = @shadow unless options.shadow?

			# 
			# передаем канвас и контекст для рисования
			# 
			options.canvas = @canvas
			options.context = @context

			# 
			# создание объекта
			# 
			switch options.type

				when "image" then result = new Image options
				when "text" then result = new Text options
				when "graph" then result = new Graph options
				when "tile" then result = new TilingImage options

			# 
			# добавляем в список дочерних объектов
			# 
			@childrens.push result

			# 
			# возвращаем результат
			# 
			return result

		# 
		# Установка прямоугольной маски для рисования
		# 
		setMask: (value) ->

			if (not value?) or (not value) then @mask = false else @mask = value

			@needAnimation = true
			@mask

		# 
		# Установка zIndex
		# 
		setZIndex: (value) ->

			@zIndex = @int value
			@canvas.style.zIndex = @zIndex
			@zIndex

		# 
		# Далее функции, перегружающие свойсва экранного объекта,
		# т.к. нам нужно в этом случае двигать, поворачивать и т.д. сам канвас
		# 

		hide: () ->

			super()
			@context.clearRect 0, 0, @size[0], @size[1]

		move: (value1, value2) ->

			super value1, value2

			# 
			# двигаем канвас по экрану
			# 
			@canvas.style.left = @position[0] + "px"
			@canvas.style.top = @position[1] + "px"
			@position

		resize: (value1, value2) ->

			super value1, value2

			# 
			# меняем размер канваса
			# 
			@canvas.width = @size[0]
			@canvas.height = @size[1]
			@size

		setCenter: (value1, value2) ->

			super value1, value2

			# 
			# сдвигаем начало координат в центр
			# 
			@context.translate @center[0], @center[1]
			@center

		setAnchor: (value1, value2) ->

			super value1, value2

			# 
			# сдвигаем начало координат в центр
			# 
			@context.translate @center[0], @center[1]
			@anchor

		rotate: (value) ->

			super value

			# 
			# поворот всего контекста на угол
			# 
			@context.rotate @_rotation
			@rotation

		setAlpha: (value) ->

			super value

			@context.globalAlpha = @alpha
			@alpha

		# 
		# анимация сцены
		# 
		animate: () ->

			# 
			# если объект не видимый
			# то рисовать его не нужно
			# 
			return unless @visible

			# 
			# очистка контекста
			# 
			@context.clearRect 0, 0, @size[0], @size[1]

			# 
			# установка маски
			# 
			if @mask

				@context.beginPath()
				@context.rect @mask[0], @mask[1], @mask[2], @mask[3]
				@context.clip()

			# 
			# анимация в буфер
			# 
			@childrens.forEach (child) => 

				@context.save()
				child.animate()
				@context.restore()

			# 
			# анимация больше не нужна
			# 
			@needAnimation = false

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

			result = @get @_scene
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
			@_beforeAnimate.forEach (func) -> func()

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

	#
	# Возвращаем результат
	#
	return CanvasEngine