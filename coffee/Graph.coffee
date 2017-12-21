"use strict";

define ["DisplayObject"], (DisplayObject) ->

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
	#  setLineDash(value:Array) - установка пунктирной линии
	#  lineDashOffset(value:int) - смещение пунктирной линии
	#  moveTo(x, y:int) - перемещение указателя
	#  lineTo(x, y:int) - линия в указанную точку
	#  line(x1, y1, x2, y2:int) - рисуем линию по двум точкам
	#  rect(x, y, width, height, radius:int) - рисуем прямоугольник (опционально скругленный)
	#  circle(x, y, radius:int) - рисуем круг
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

			# 
			# тип объекта
			# 
			@type = "graph"

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
		# рисуем круг
		# 
		circle: (centerX, centerY, radius) ->

			@_commands.push {

				"command": "circle"
				"center": @pixel centerX, centerY
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

			# 
			# если объект не видимый
			# то рисовать его не нужно
			# 
			if not @visible

				@needAnimation = false
				return
			
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

					when "circle"

						@context.beginPath()

						@context.arc command.center[0] + @_deltaX, command.center[1] + @_deltaY, command.radius, 0, 2 * Math.PI, false						

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