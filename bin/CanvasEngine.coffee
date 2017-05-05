# 
# 
# CanvasEngine
# 
# 

"use strict";

define () ->

	#
	#
	# base class
	#
	#

	# 
	# базовые свойства и методы для всех классов
	# 
	class base

		# 
		# options = {
		# 
		# 	parent: DomElement
		# 	rotation: number
		# 	alpha: number
		# 	
		# 	sizes: Array / Object
		# 	position: Array / Object
		# 	center: Array / Object
		# 
		# }
		# 

		constructor: (options) ->

			# поворот
			@_rotation = options.rotation or 0
			# прозрачность
			@_alpha = options.alpha or 1
			# размеры
			@_sizes = @_point options.sizes
			# позиция
			@_position = @_point options.position
			# центр
			@_center = @_point options.center

		# 
		# приведение к виду [x, y]
		# 
		# 	все точки хранятся и передаются в виде массивов [x, y]
		# 	чтобы сократить время и объем записей
		# 	множества точек
		# 	
		_point: (value, value2) ->

			# значение не существует
			return [0, 0] if (not value?)

			# передано два параметра, считаем их числами и возвращаем массив
			return [@_int(value), @_int(value2)] if value2?

			# если передан массив
			if Array.isArray value

				# возвращаем первые два элемента
				return [@_int(value[0]), @_int(value[1])]

			# может быть это объект?
			else

				# если есть свойства x и y
				return [@_int(value.x), @_int(value.y)] if value.x? and value.y?
				# если есть свойства width и height
				return [@_int(value.width), @_int(value.height)] if value.width? and value.height?
				# по умолчанию
				return [0, 0]

		# приведение к целому
		_int: (value) -> Math.round @_value(value)

		# приведение к числу
		_value: (value) -> if value? then +value else 0

	#
	#
	# DisplayObject class
	#
	#

	class DisplayObject extends base

		# 
		# Базовые методы и свойства экранных объектов
		# 
		constructor: (options) ->

			super options

			# имя
			@name = options.name
			# тень
			@_shadow = false

			# нужна ли анимация
			@needAnimation = true

		# установка опций
		setTransform: (options) ->

			@setSizes options.sizes
			@setPosition options.position
			@setCenter options.center
			@setRotation options.rotation
			@setAlpha options.alpha

		# размер
		setSizes: (sizes) ->

			@_sizes = @_point sizes if sizes?

			@needAnimation = true

		# позиция
		setPosition: (position) ->

			@_position = @_point position if position?

			@needAnimation = true

		# центр, вокруг которого происходит вращение
		setCenter: (center) ->

			@_center = @_point center if center?

			@needAnimation = true

		# поворот
		setRotation: (rotation) ->

			@_rotation = @_value rotation if rotation?

			@needAnimation = true

		# прозрачность
		setAlpha: (alpha) ->

			@_alpha = @_value alpha if alpha?

			@needAnimation = true

		# тень
		# # ВНИМАНИЕ!
		# В браузере firefox есть баг (на 25.04.17), а именно:
		# при попытке нарисовать на канве изображение, используя одновременно
		# маску и тень (setMask and setShadow в данном случае), получается
		# странная хрень, а точнее маска НЕ работает в данном случае.
		# Доказательство и пример здесь: http://codepen.io/cnupm99/pen/wdGKBO
		setShadow: (options) ->

			if options?

				@_shadow = {

					color: options.color or "#000"
					blur: options.blur or 3
					offsetX: options.offsetX or 0
					offsetY: options.offsetY or 0
					offset: options.offset or 0

				}

			else

				@_shadow = false

			@needAnimation = true

		# анимация
		animate: (context) ->

			# сохранить контекст
			context.save()

			# смещение
			@_deltaX = @_position[0]
			@_deltaY = @_position[1]

			# установка тени
			if @_shadow

				context.shadowColor = @_shadow.color
				context.shadowBlur = @_shadow.blur
				context.shadowOffsetX = Math.max @_shadow.offsetX, @_shadow.offset
				context.shadowOffsetY = Math.max @_shadow.offsetY, @_shadow.offset

			# смещение и поворот холста
			if @_rotation != 0

				context.translate @_center[0] + @_position[0], @_center[1] + @_position[1]
				context.rotate @_rotation * Math.PI / 180
				@_deltaX = -@_center[0]
				@_deltaY = -@_center[1]

			# анимация больше не нужна
			@needAnimation = false

	#
	#
	# Graph class
	#
	#

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

		animate: (context) ->

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

	#
	#
	# Text class
	#
	#
	
	class Text extends DisplayObject

		constructor: (options) ->

			super options

			# контекст, нужен для определения ширины текста
			@_context = options.context
			# шрифт
			@setFont options.font
			# текст
			@setText(options.text or "")
			# заливка
			@fillStyle options.fillStyle
			# обводка
			@_strokeStyle = options.strokeStyle or false
			# толщина обводки
			@_strokeWidth = options.strokeWidth or 1

			@needAnimation = true

		setText: (text) ->

			@_text = text

			# определяем ширину текста
			# используя для этого ссылку на контекст
			@_context.save()
			@_context.font = @_font
			@width = @_context.measureText(@_text).width
			@_context.restore()

			@needAnimation = true

		# если указать массив, то можно забацать градиент
		# [[size, color], ... ]
		fillStyle: (style) ->

			@_fillStyle = style or false
			@needAnimation = true

		strokeStyle: (style) ->

			@_strokeStyle = style or false
			@needAnimation = true

		setFont: (font) ->

			@_font = font or "12px Arial"

			# устанавливаем реальную высоту шрифта в пикселях
			span = document.createElement "span"
			span.appendChild document.createTextNode("height")
			span.style.cssText = "font: " + @_font + "; white-space: nowrap; display: inline;"
			document.body.appendChild span
			@fontHeight = span.offsetHeight
			document.body.removeChild span

			@needAnimation = true

		animate: (context) ->

			super context

			context.font = @_font
			# по умолчанию позиционируем текст по верхнему краю
			context.textBaseline = "top"
			
			if @_fillStyle

				# а может зальем текст градиентом?
				if Array.isArray @_fillStyle

					# создаем градиент по нужным точкам
					gradient = context.createLinearGradient @_deltaX, @_deltaY, @_deltaX, @_deltaY + @fontHeight
					# добавляем цвета
					@_fillStyle.forEach (color) ->
						# сначала размер, потом цвет
						gradient.addColorStop color[0], color[1]
					# заливка градиентом
					context.fillStyle = gradient

				else context.fillStyle = @_fillStyle

				context.fillText @_text, @_deltaX, @_deltaY

			if @_strokeStyle

				context.strokeStyle = @_strokeStyle
				context.lineWidth = @_strokeWidth
				context.strokeText @_text, @_deltaX, @_deltaY

			context.restore()

			@needAnimation = false

	#
	#
	# Image class
	#
	#

	class Image extends DisplayObject

		# 
		# Изображение
		# 
		constructor: (options) ->

			super options

			# событие, выполняемое при загрузке картинки
			@onload = options.onload

			# загрузка или создание картинки
			if options.src?

				# создаем элемент
				@_image = document.createElement "img"
				# картинка не загружена
				@needAnimation = false
				@_loaded = false
				# загружаем картинку
				@setSrc options.src

			else

				# 
				# options.from = {
				# 
				# 	image: Image
				# 	src: String
				# 	sizes: [Number, Number]
				# 	
				# }
				# 

				# картинка уже есть
				@_image = options.from.image
				# получаем ее путь
				@_src = options.from.src
				# размеры
				@_realSizes = options.from.sizes
				# можно рисовать
				@_loaded = true
				@needAnimation = true

		# загрузка картинки
		setSrc: (src) ->

			# не загружена
			@_loaded = false

			@_image.onload = () => 

				# запоминаем реальные размеры
				@_realSizes = [@_image.width, @_image.height]

				# если нужно меняем размеры
				# иначе потом будем масштабировать
				@_sizes = @_realSizes if (@_sizes[0] <= 0) or (@_sizes[1] <= 0)

				@needAnimation = true

				@_loaded = true

				# если у картинки есть свойство onload, то вызываем его и
				# сообщаем реальные размеры картинки
				@onload @_realSizes if @onload?

			@_image.src = src

		# возвращаем размер
		getSizes: () -> @_sizes
		# реальный размер картинки
		getRealSizes: () -> @_realSizes

		animate: (context) ->

			return unless @_loaded

			super context

			# в реальном размере
			if (@_sizes[0] == @_realSizes[0]) and (@_sizes[1] == @_realSizes[1])

				context.drawImage @_image, @_deltaX, @_deltaY

			else

				# в масштабе
				context.drawImage @_image, @_deltaX, @_deltaY, @_sizes[0], @_sizes[1]

			context.restore()

			@needAnimation = false

	#
	#
	# TilingImage class
	#
	#

	class TilingImage extends Image

		# 
		# Изображение, которое замостит указанную область
		# 
		constructor: (options) ->

			super options

			@_rect = options.rect

		# установка области
		setRect: (rect) ->

			@_rect = rect
			@needAnimation = true

		animate: (context) ->

			return unless @_loaded

			super context

			# создаем паттерн
			context.fillStyle = context.createPattern @_image, "repeat"
			# рисуем прямоугольник
			context.rect @_rect[0], @_rect[1], @_rect[2], @_rect[3]
			# заливаем паттерном
			context.fill()

			context.restore()

			@needAnimation = false

	#
	#
	# Scene class
	#
	#

	class Scene extends base

		# 
		# Сцена
		# 
		constructor: (options) ->

			super options

			# имя
			@name = options.name

			# имя сцены FPS является зарезервированным
			# не желательно использовать это имя для своих сцен
			# во избежание проблем

			# канвас
			@canvas = document.createElement "canvas"
			@canvas.style.position = "absolute"
			# z индекс
			@setZ options.zIndex

			# контекст
			@context = @canvas.getContext "2d"
			
			# установка опций
			@setTransform options
			# маска отключена
			@_mask = false
			# анимация пока не нужна
			@_needAnimation = false
			# список объектов для анимации
			@_objects = []

		# установка z-индекса
		setZ: (value) ->

			@_zIndex = @_int value
			@canvas.style.zIndex = @_zIndex

		# получить z-индекс
		getZ: () -> @_zIndex

		# добавление объектов в список анимации
		add: (options) ->

			return unless options.type?

			switch options.type

				when "image" then result = new Image options
				when "text"

					# передаем контекст внуть класса,
					# нужно для определения ширины текста
					options.context = @context
					result = new Text options

				when "graph" then result = new Graph options
				when "tile" 

					# область замостивания по умолчанию равна размеру контекста
					options.rect = [0, 0, @_sizes[0], @_sizes[1]] unless options.rect?
					result = new TilingImage options

			@_objects.push result

			return result

		# поиск объекта по его имени
		get: (objectName) ->

			answer = false

			# перебор всех объектов, пока не встретим нужный
			@_objects.some (_object) -> 

				flag = _object.name == objectName
				answer = _object if flag
				return flag

			return answer

		# удаляем объект по его имени
		remove: (objectName) ->

			index = -1

			# перебор всех объектов, пока не встретим нужный
			@_objects.some (_object, i) -> 

				flag = _object.name == objectName
				index = i if flag
				return flag

			if index > -1

				@_objects.splice index, 1
				return true

			return false

		# добавляем внешний объект в список отображения
		addChild: (_object) ->

			@_objects.push _object
			@_needAnimation = true

		# удалить внешний объект из списка отображения
		removeChild: (_object) ->

			index = -1

			# перебор всех объектов, пока не встретим нужный
			@_objects.some (_object2, i) -> 

				flag = _object2 == _object
				index = i if flag
				return flag

			if index > -1

				@_objects.splice index, 1
				return true

			return false

		# нужна ли анимация
		needAnimation: () ->

			@_needAnimation or @_objects.some (_object) -> _object.needAnimation

		# проверяем, пуста ли точка с данными координатами
		# ВНИМАНИЕ!
		# использовать этот метод ЛОКАЛЬНО нужно осторожно, так как
		# в браузерах на основе chrome будет возникать ошибка безопасности
		# (как будто пытаешься загрузить изображение с другого хоста).
		# В firefox работает и локально без проблем.
		# При загрузке кода на сервер работает во всех браузерах.
		testPoint: (pointX, pointY) ->

			# данные пикселя
			imageData = @context.getImageData pointX, pointY, 1, 1
			# цвет пикселя
			pixelData = imageData.data

			# проверяем нужный метод?
			pixelData.every = Array.prototype.every if not pixelData.every?

			# проверяем все цвета, если 0, значит мимо
			return not pixelData.every (value) -> value == 0

		# установка прямоугольной маски
		# ВНИМАНИЕ!
		# В браузере firefox есть баг (на 25.04.17), а именно:
		# при попытке нарисовать на канве изображение, используя одновременно
		# маску и тень (setMask and setShadow в данном случае), получается
		# странная хрень, а точнее маска НЕ работает в данном случае.
		# Доказательство и пример здесь: http://codepen.io/cnupm99/pen/wdGKBO
		setMask: (x, y, width, height) ->

			if arguments.length < 4

				# если меньше четырех аргументов,
				# просто удаляем маску
				@_mask = false

			else

				@_mask = {

					x: @_int x
					y: @_int y
					width: @_int width
					height: @_int height

				}

			@_needAnimation = true

		# установка опций
		setTransform: (options) ->

			@setSizes options.sizes
			@setPosition options.position
			@setCenter options.center
			@setRotation options.rotation
			@setAlpha options.alpha

		# размер
		setSizes: (sizes) ->

			@_sizes = @_point sizes if sizes?

			@canvas.width = @_sizes[0]
			@canvas.height = @_sizes[1]

			@_needAnimation = true

		# позиция
		setPosition: (position) ->

			@_position = @_point position if position?

			@canvas.style.left = @_position[0]
			@canvas.style.top = @_position[1]

			@_needAnimation = true

		# центр
		setCenter: (center) ->

			@_center = @_point center if center?

			@context.translate @_center[0], @_center[1]

			@_needAnimation = true

		# поворот
		setRotation: (rotation) ->

			@_rotation = @_value rotation if rotation?

			@context.rotation = @_rotation * Math.PI / 180

			@_needAnimation = true

		# прозрачность
		setAlpha: (alpha) ->

			@_alpha = @_value alpha if alpha?

			@context.globalAlpha = @_alpha
			@_needAnimation = true

		# анимация сцены
		animate: () ->

			# очистка контекста
			@context.clearRect 0, 0, @canvas.width, @canvas.height

			# установка маски
			if @_mask

				@context.beginPath()
				@context.rect @_mask.x, @_mask.y, @_mask.width, @_mask.height
				@context.clip()

			# анимация
			@_objects.forEach (_object) => _object.animate @context

			# анимация больше не нужна
			@_needAnimation = false

	#
	#
	# Scenes class
	#
	#

	# 
	# Управление сценами
	# 
	# Все сцены добавляются на глобальное поле stage
	# Сцена не может содержать в себе другую сцену
	# 
	class Scenes

		constructor: (stage) ->

			# массив сцен
			@_scenes = []
			# глобальный объект / родитель сцен
			@_stage = stage
			# имя активной сцены
			@_activeSceneName = ""

		# создание сцены
		create: (options) ->

			# имя сцены FPS является зарезервированным
			# не желательно использовать это имя для своих сцен
			# во избежание проблем

			# получаем имя сцены
			sceneName = options.name or "default"
			# пробуем найти, нет ли уже такой сцены
			scene = @get sceneName
			# если нет
			unless scene
				# создаем
				scene = new Scene options
				@_stage.appendChild scene.canvas
				@_scenes.push scene

			# если нужно, устанавливаем сцену активной
			setActive = if options.setActive? then options.setActive else true
			@_activeSceneName = sceneName if setActive

			return scene

		# получаем имя активной сцены
		active: () -> @_activeSceneName

		# устанавливаем активную сцену по имени
		@.prototype.active.set = (sceneName) ->

			# ищем сцену
			scene = @get sceneName
			# если она существует, устанавливаем ее имя в активное
			@_activeSceneName = sceneName if scene
			# возвращаем результат
			return scene

		# возвращаем активную сцену
		@.prototype.active.get = () -> @get @_activeSceneName

		# ищем сцену по имени
		get: (sceneName) ->

			answer = false

			# перебор всех сцен, пока не встретим нужную
			@_scenes.some (scene) -> 

				flag = scene.name == sceneName
				answer = scene if flag
				return flag

			return answer

		# удаление сцены по имени
		remove: (sceneName) ->

			# ищем индекс сцены
			index = @_index sceneName
			# если такая сцена есть
			if index > -1

				# удаляем канвас с экрана
				@_parent.removeChild @_scenes[index].canvas
				# удаляем сцену из массива сцен
				@_scenes.splice index, 1
				return true

			return false

		# переименовать сцену
		rename: (sceneName, newName) ->

			# ищем сцену с нужным именем
			scene = @get sceneName

			# если она существует, меняем ей имя
			scene.name = newName if scene

			return scene

		# поднимаем сцену на верх отображения
		onTop: (sceneName) ->

			maxZ = 0
			result = false

			@_scenes.forEach (scene) ->

				maxZ = scene.getZ() if scene.getZ() > maxZ
				result = scene if sceneName == scene.name

			result.setZ maxZ + 1 if result

			return result

		# нужна ли анимация хоть одной сцены
		needAnimation: () ->

			@_scenes.some (scene) -> scene.needAnimation()

		# анимация всех сцен, если нужно
		animate: () ->

			@_scenes.forEach (scene) -> scene.animate() if scene.needAnimation()

		# получить индекс сцены по ее имени
		_index: (sceneName) ->

			index = -1

			# перебор всех сцен, пока не встретим нужную
			@_scenes.some (scene) -> 

				flag = scene.name == sceneName
				index = scene if flag
				return flag

			return index

	#
	#
	# FPS class
	#
	#

	class FPS

		# 
		# Служебный класс для рисования таблички
		# с отображением
		# FPS - Frame Per Seconds
		# UPS - Update Per Seconds
		# 
		# UPS показывает сколько реально раз происходила перерисовка чего либо
		# 
		constructor: (options) ->

			@_scene = options.scene
			
			# граф для прорисовки
			@_graph = @_scene.add { type: "graph" }

			# массив значений
			@_values = []

			# зеленая надпись
			@_caption = @_scene.add {

				type: "text"
				fillStyle: "#00FF00"
				font: "10px Arial"
				position: [3, 1]

			}

			# красная надпись
			@_caption2 = @_scene.add {

				type: "text"
				fillStyle: "#FF0000"
				font: "10px Arial"
				position: [48, 1]

			}

			# запускаем
			@start()
			# рисуем
			@_onTimer()

		start: () ->

			@_counter = @_updateCounter = @_FPSValue = 0
			@_interval = setInterval @_onTimer, 1000

		stop: () ->

			clearInterval @_interval
			@_counter = @_updateCounter = @_FPSValue = 0

		_onTimer: () =>

			@_FPSValue = @_counter
			@_counter = 0
			@_updateValue = @_updateCounter
			@_updateCounter = 0
			# записываем значения в массив
			@_values.push [@_FPSValue, @_updateValue]
			# лишние выкидываем
			@_values.shift() if @_values.length == 84

			# начинаем рисовать
			@_graph.clear()
			@_graph.fillStyle "#000"
			@_graph.rect 0, 0, 90, 40
			@_graph.fill()

			for i in [0 ... @_values.length]

				x = 87 - @_values.length + i
				fps = @_values[i][0]
				ups = @_values[i][1]

				@_graph.strokeStyle "#00FF00"
				@_graph.line x, 37, x, 37 - 23 * fps / 60
				@_graph.strokeStyle "#FF0000"
				@_graph.line x, 37, x, 37 - 23 * ups / 60

			@_caption.setText "FPS: " + @_FPSValue
			@_caption2.setText "UPS: " + @_updateValue

		# эту функцию нужно вызывать в цикле анимации
		# для подсчета значений
		update: (needAnimation) ->

			@_counter++
			@_updateCounter++ if needAnimation

	#
	#
	# CanvasEngine class
	#
	#

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
			# родитель
			@_parent = options.parent or document.body
			# менеджер сцен
			@scenes = new Scenes(@_parent)
			# массив функций для выполнения в цикле перед анимацией
			@_beforeAnimate = []

			# нужно ли показывать фпс
			@_showFPS = if options.showFPS? then options.showFPS else true
			# создаем счетчик, если нужно
			if @_showFPS

				# сцена для фпс
				scene = @scenes.create {

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
		stop: () -> cancelAnimationFrame @_render

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

				@scenes.create options

			else

				# на какую сцену добавить объект?
				sceneName = options.scene or @scenes.active() or "default"
				# если такой сцены нет, то создадим ее
				scene = @scenes.create {

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
			needAnimation = @scenes.needAnimation()

			# если анимация нужна, делаем ее
			@scenes.animate() if needAnimation

			# обновляем фпс
			@_FPS.update needAnimation if @_showFPS

			# продолжаем анимацию
			@_render = requestAnimationFrame @_animate

	# 
	# возвращаем значение
	# 

	return CanvasEngine