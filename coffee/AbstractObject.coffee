"use strict";

define () ->

	# 
	# Абстрактный объект, не имеющий отображения на экране
	# но вмещающий в себя основные свойства и методы
	# других объектов
	# 
	class AbstractObject

		# 
		# свойства:
		# 
		#  parent: Object/Element - родитель объекта
		#  childrens: Array - массив дочерних объектов
		#  needAnimation: Boolean - нужно ли анимировать данный объект с точки зрения движка
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
		#  get(childName): Object/false - поиск среди дочерних элементов по имени элемента
		#  remove(childName): Boolean - удаление дочернего элемента по его имени
		#  rename(oldName, newName): Boolean - переименование дочернего элемента
		#  index(childName): int - возвращает индекс элемента в массиве дочерних по его имени
		#  shift(deltaX, deltaY):Array - сдвигаем объект на нужное смещение по осям
		#  point(value1, value2): Array - приведение выражений к виду [x, y]
		#  pixel(value1, value2): Array - округляет результат pixel
		#  int(value): int - приведение к целому числу
		#  number(value): Number - приведение к числу
		#  deg2rad(value): Number - перевод из градусов в радианы
		#  
		# методы для установки свойств:
		# 
		#  set(Object) - задает все или некоторые свойства объекта через объект опций
		#  setVisible()
		#  setPosition()
		#  setSize()
		#  setRealSize()
		#  setCenter()
		#  setAnchor()
		#  setScale()
		#  setRotation()
		#  setAlpha()
		#  setMask()
		#  setShadow()
		#   

		constructor: (options) ->

			# 
			# если ничего не передано в качестве опций, создаем пустой объект
			# чтобы можно было обратиться к его свойствам
			# 
			options = {} unless options?

			# 
			# родитель объекта, он должен быть всегда
			# для CanvasEngine это Element
			# для Scene это CancasEngine
			# для других объектов это Scene
			# свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ
			# 
			@parent = options.parent or document.body

			# 
			# массив дочерних элементов,
			# для CanvasEngine это Scene
			# для Scene остальные элементы
			# для остальных элементов - массив пустой
			# свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ
			# 
			@childrens = []

			# 
			# нужно ли анимировать данный объект с точки зрения движка
			# не нужно в ручную менять это свойство, для этого есть visible
			# 
			@needAnimation = true

			# 
			# установка свойств
			# 
			@_setProperties options			

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
		# сдвигаем объект на нужную величину по осям
		# 
		shift: (deltaX = 0, deltaY = 0) ->

			@setPosition [deltaX + @position[0], deltaY + @position[1]]

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
		# Установка всех или определенных свойств через объект опций
		# 
		set: (options) ->

			return unless options?

			@setVisible options.visible if options.visible?
			@setPosition options.position if options.position?
			@setSize options.size if options.size?
			@setRealSize options.realSize if options.realSize?
			@setCenter options.center if options.center?
			@setAnchor options.anchor if options.anchor?
			@setScale options.scale if options.scale?
			@setRotation options.rotation if options.rotation?
			@setAlpha options.alpha if options.alpha?
			@setMask options.mask if options.mask?
			@setShadow options.shadow if options.shadow?

		# 
		# Далее идут функции, выполняемые после установки свойств объекта.
		# Это нужно для того, чтобы в дочерних классах можно было перезаписать эту функцию,
		# т.е. сделать перегрузку свойства
		# 

		setVisible: (value) -> 

			@visible = if value? then value else true
			@needAnimation = @visible

		setPosition: (value) ->

			@position = @pixel value
			@needAnimation = true
			@position

		setSize: (value) ->

			@size = @pixel value
			@setAnchor @anchor
			@needAnimation = true
			@size

		setRealSize: (value) ->

			@realSize = @pixel value
			@setAnchor @anchor
			@realSize

		setCenter: (value) ->

			@center = @pixel value

			size = if @size[0] == 0 and @size[1] == 0 then @realSize else @size
			anchorX = if size[0] == 0 then 0 else @center[0] / size[0]
			anchorY = if size[1] == 0 then 0 else @center[1] / size[1]
			@anchor = [anchorX, anchorY]

			@needAnimation = true
			@center

		setAnchor: (value) ->

			@anchor = @point value
			
			size = if @size[0] == 0 and @size[1] == 0 then @realSize else @size
			@center = [@int(size[0] * @anchor[0]), @int(size[1] * @anchor[1])]

			@needAnimation = true
			@anchor

		setScale: (value) ->

			@scale = if value then @point value else [1, 1]
			@needAnimation = true
			@scale

		setRotation: (value) ->

			@rotation = @number value
			@rotation = 360 + @rotation if @rotation < 0
			@rotation = @rotation % 360 if @rotation >= 360
			@needAnimation = true
			@rotation

		setAlpha: (value) ->

			@alpha = if value then @number value else 1
			@alpha = 0 if @alpha < 0
			@alpha = 1 if @alpha > 1

			@needAnimation = true
			@alpha

		setMask: (value) ->

			if (not value?) or (not value) then @mask = false else @mask = value

			@needAnimation = true
			@mask

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
		# Создание и установка свойств объекта
		# 
		_setProperties: (options) ->

			# 
			# Ниже идут свойтсва объекта.
			# НЕ НУЖНО МЕНЯТЬ ИХ ВРУЧНУЮ, для этого есть соответствующая функция
			# вида setPosition, setSize и т.д.
			# 

			# 
			# видимость объекта, устанавливаемая пользователем
			# true / false
			# 
			@setVisible options.visible

			# 
			# позиция объекта
			# массив вида [x, y], либо объект вида {x: int, y: int}
			# 
			@setPosition options.position

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
			@setSize options.size

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
			@setScale options.scale

			# 
			# поворот объекта вокруг точки center по часовой стрелке, измеряется в градусах
			# число
			# 
			@setRotation options.rotation

			# 
			# прозрачность объекта
			# число от 0 до 1
			# 
			@setAlpha options.alpha

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
		# константа, для ускорения рассчетов
		# используется в rad
		# 
		_PIDIV180: Math.PI / 180