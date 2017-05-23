"use strict";

define ["DisplayObject"], (DisplayObject) ->

	class Graph extends DisplayObject

		constructor: (options) ->

			super options

			# массив команд для рисования
			@_commands = []

			@needAnimation = false

		# рисуем линию, соединяющую две точки
		line: (fromX, fromY, toX, toY) ->

			from = @_point fromX, fromY
			to = @_point toX, toY

			@_commands.push {

				"command": "line"
				"from": from
				"to": to

			}

			@needAnimation = true

		# очистка экрана и команд
		clear: () -> 

			@_commands = []
			@needAnimation = true

		# стиль линий
		strokeStyle: (style) ->

			@_commands.push {

				"command": "strokeStyle"
				"style": style

			}

		# стиль заливки
		fillStyle: (style) ->

			@_commands.push {

				"command": "fillStyle"
				"style": style

			}

		# устновка градиента
		# colors = Array [ [size, color], .... ], где color:String, size:Number [0..1]
		linearGradient: (x1, y1, x2, y2, colors) ->

			@_commands.push {

				"command": "gradient"
				"point1": @_point x1, y1
				"point2": @_point x2, y2
				"colors": colors

			}

		# рисуем прямоугольник, если указан radius, то скругляем углы
		rect: (fromX, fromY, width, height, radius = 0) ->

			point = @_point fromX, fromY
			sizes = @_point width, height

			@_commands.push {

				"command": "rect"
				"point": point
				"sizes": sizes
				"radius": radius

			}

			@needAnimation = true

		moveTo: (toX, toY) ->

			point = @_point toX, toY

			@_commands.push {

				"command": "moveTo"
				"point": point

			}

		lineTo: (toX, toY) ->

			point = @_point toX, toY

			@_commands.push {

				"command": "lineTo"
				"point": point

			}

			@needAnimation = true

		fill: () ->

			@_commands.push {

				"command": "fill"

			}

			@needAnimation = true

		stroke: () ->

			@_commands.push {

				"command": "stroke"

			}

			@needAnimation = true

		# линия из множества точек
		# второй параметр говорит, нужно ли ее рисовать,
		# он нужен, чтобы рисовать многоугольники без границы
		polyline: (points, stroke = true) ->

			@_commands.push {

				"command": "beginPath"

			}

			@moveTo points[0][0], points[0][1]

			points.forEach (point) => @lineTo point[0], point[1]

			if stroke

				@_commands.push {

					"command": "stroke"

				}

			@needAnimation = true

		# полигон
		polygon: (points) ->

			@polyline points, false
			@lineTo points[0][0], points[0][1]

			@_commands.push {

				"command": "stroke"

			}
			@_commands.push {

				"command": "fill"

			}

			@needAnimation = true

		# толщина линий
		lineWidth: (width) ->

			width = @_int width

			@_commands.push {

				"command": "lineWidth"
				"width": width

			}

		# установка пунктирной линии
		setLineDash: (dash) ->

			@_commands.push {

				"command": "setDash"
				"dash": dash

			}

		# смещение пунктирной линии
		lineDashOffset: (offset) ->

			offset = @_int offset

			@_commands.push {

				"command": "dashOffset"
				"offset": offset

			}

		# рисуем пряоугольник со скругленными углами
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

		animate: (context = @_context) ->

			super context

			# установим закругленные окончания линий
			context.lineCap = "round"

			# перебираем все команды в массиве команд и выполняем соответствующие действия
			# можно было поменять строковые команды на числа вида 0, 1, 2 .... и т.д.,
			# но зачем?
			@_commands.forEach (command) =>

				switch command.command

					when "beginPath" then context.beginPath()

					when "stroke" then context.stroke()

					when "fill" then context.fill()

					when "setDash" then context.setLineDash command.dash

					when "dashOffset" then context.lineDashOffset = command.offset

					when "moveTo" then context.moveTo command.point[0] + @_deltaX, command.point[1] + @_deltaY

					when "lineTo" then context.lineTo command.point[0] + @_deltaX, command.point[1] + @_deltaY

					when "line"

						context.beginPath()
						context.moveTo command.from[0] + @_deltaX, command.from[1] + @_deltaY
						context.lineTo command.to[0] + @_deltaX, command.to[1] + @_deltaY
						context.stroke()

					when "strokeStyle" then context.strokeStyle = command.style

					when "fillStyle" then context.fillStyle = command.style

					when "lineWidth" then context.lineWidth = command.width

					when "rect"

						context.beginPath()
						
						# обычный прямоугольник
						if command.radius == 0
						
							context.rect command.point[0] + @_deltaX, command.point[1] + @_deltaY, command.sizes[0], command.sizes[1]

						# прямоугольник со скругленными углами
						else @_drawRoundedRect context, command.point[0] + @_deltaX, command.point[1] + @_deltaY, command.sizes[0], command.sizes[1], command.radius

					when "gradient"

						# создаем градиент по нужным точкам
						gradient = context.createLinearGradient command.point1[0] + @_deltaX, command.point1[1] + @_deltaY, command.point2[0] + @_deltaX, command.point2[1] + @_deltaY
						# добавляем цвета
						command.colors.forEach (color) ->
							# сначала размер, потом цвет
							gradient.addColorStop color[0], color[1]
						# заливка градиентом
						context.fillStyle = gradient

			context.restore()

			@needAnimation = false