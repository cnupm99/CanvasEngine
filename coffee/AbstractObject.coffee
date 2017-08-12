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
		#  int(value): int - приведение к целому числу
		#  number(value): Number - приведение к числу
		#  deg2rad(value): Number - перевод из градусов в радианы
		#   

		constructor: (options) ->

			# 
			# если ничего не передано в качестве опций, создаем пустой объект
			# чтобы можно было обратиться к его свойствам
			# 
			options = {} unless options

			# 
			# родитель объекта, он должен быть всегда
			# для CanvasEngine это Element
			# для Scene это CancasEngine
			# для других объектов это Scene
			# свойство только для чтения
			# 
			Object.defineProperty @, "parent", {

				value: options.parent or document.body
				writable: false
				configurable: false

			}

			# 
			# массив дочерних элементов,
			# для CanvasEngine это Scene
			# для Scene остальные элементы
			# для остальных элементов - массив пустой
			# 
			@childrens = []

			# 
			# нужно ли анимировать данный объект с точки зрения движка
			# не нужно в ручную менять это свойство, для этого есть следующее...
			# 
			@needAnimation = true

			# 
			# Устанавливаем свойства
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

			@position = [deltaX + @position[0], deltaY + @position[1]]

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
		# приведение выражения к целому числу
		# 
		int: (value) -> Math.round @number(value)

		# 
		# приведение выражения к числу
		# 
		number: (value) -> if value? then +value else 0

		# 
		# переводим градусы в радианы
		# 
		deg2rad: (value) -> @number(value) * Math.PI / 180

		# 
		# Создание и установка свойств объекта
		# 
		_setProperties: (options) ->

			_visible = _position = _size = _realSize = _center = _anchor = _scale = _rotation = _alpha = _mask = _shadow = 0

			# 
			# видимость объекта, устанавливаемая пользователем
			# true / false
			# 
			Object.defineProperty @, "visible", {

				get: () -> _visible
				set: (value) -> 

					_visible = if value? then value else true
					@_setVisible()

			}

			# 
			# позиция объекта
			# массив вида [x, y], либо объект вида {x: int, y: int}
			# 
			Object.defineProperty @, "position", {

				get: () -> _position
				set: (value) -> 

					_position = @point value
					@_setPosition()

			}

			# 
			# размер объекта
			# массив вида [width, height], либо объект вида {width: int, height: int}
			# 
			Object.defineProperty @, "size", {

				get: () -> _size
				set: (value) -> 

					_size = @point value
					@anchor = _anchor
					@_setSize()

			}

			# 
			# реальный размер объекта,
			# может отличаться от заданного пользователем, например
			# в случае загрузки картинки
			# 
			# пока не рассчитан программно, считается равным [0, 0]
			# 
			# массив вида [width, height], либо объект вида {width: int, height: int}
			# 
			Object.defineProperty @, "realSize", {

				get: () -> _realSize
				set: (value) -> 

					_realSize = @point value
					@anchor = _anchor
					@_setRealSize()

			}

			# 
			# координаты точки, являющейся центром объекта,
			# вокруг этой точки производится вращение объекта
			# координаты точки задаются не относительно начала координат,
			# а относительно левого верхнего угла объекта
			# массив вида [x, y], либо объект вида {x: int, y: int}
			# 
			Object.defineProperty @, "center", {

				get: () -> _center
				set: (value) -> 

					_center = @point value

					size = getSize()
					anchorX = if size[0] == 0 then 0 else _center[0] / size[0]
					anchorY = if size[1] == 0 then 0 else _center[1] / size[1]
					_anchor = [anchorX, anchorY]

					@_setCenter()

			}

			# 
			# Думаем, откуда брать размеры
			# если размеры не заданы пользователем, то пробуем взять реальные размеры
			# 
			getSize = () =>

				size = if _size[0] == 0 and _size[1] == 0 then _realSize else _size

			# 
			# Якорь, дробное число, показывающее, где должен находиться цент относительно размеров объекта,
			# т.е. center = size * anchor
			# вообще массив, содержащий числа от 0 до 1, но может иметь и другие значения
			# 
			Object.defineProperty @, "anchor", {

				get: () -> _anchor

				set: (value) ->

					_anchor = @point value
					size = getSize()

					_center = [@int(size[0] * _anchor[0]), @int(size[1] * _anchor[1])]
					@_setCenter()

			}

			# 
			# Свойство хранит коэффициенты для масштабирования объектов
			# массив вида [x, y]
			# 
			Object.defineProperty @, "scale", {

				get: () -> _scale
				set: (value) -> 

					_scale = @point value
					@_setScale()

			}

			# 
			# поворот объекта вокруг точки center по часовой стрелке, измеряется в градусах
			# число
			# 
			Object.defineProperty @, "rotation", {

				get: () -> _rotation
				set: (value) -> 

					_rotation = @number value
					_rotation = 360 + _rotation if _rotation < 0
					_rotation = _rotation % 360 if _rotation >= 360
					@_setRotation()

			}

			# 
			# прозрачность объекта
			# число от 0 до 1
			# 
			Object.defineProperty @, "alpha", {

				get: () -> _alpha
				set: (value) -> 

					_alpha = @number value
					@_setAlpha()

			}

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
			Object.defineProperty @, "mask", {

				get: () -> _mask
				set: (value) -> 

					if (not value?) or (not value)

						_mask = false
						@_setMask()
						return

					_mask = value
					@_setMask()

			}

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
			Object.defineProperty @, "shadow", {

				get: () -> _shadow
				set: (value) -> 

					if (not value?) or (not value)

						_shadow = false
						@_setShadow()
						return

					_shadow = {

						# 
						# не проверяем значения color и blur, потому что по умолчанию они отличны от 0
						# 
						color: value.color or "#000"
						blur: value.blur or 3

						offsetX: @int value.offsetX
						offsetY: @int value.offsetY
						offset: @int value.offset

					}

					@_setShadow()

			}

			# 
			# Установка начальных значений
			# 
			@visible = if options.visible? then options.visible else true
			@position = options.position
			@size = options.size
			@realSize = [0, 0]
			@center = options.center
			@anchor = options.anchor
			@scale = options.scale or [1, 1]
			@rotation = options.rotation
			@alpha = if options.alpha? then @number options.alpha else 1
			@mask = options.mask or false
			@shadow = options.shadow or false

		# 
		# Далее идут функции, выполняемые после установки свойств объекта.
		# Это нужно для того, чтобы в дочерних классах можно было перезаписать эту функцию,
		# т.е. сделать перегрузку свойства
		# 

		_setVisible: () -> 

			# 
			# сообщаем движку, нужно ли анимировать объект
			# 
			@needAnimation = @visible

		_setPosition: () ->

			@needAnimation = true
			@position

		_setSize: () ->

			@needAnimation = true
			@size

		_setRealSize: () ->

			@realSize

		_setCenter: () ->

			@needAnimation = true
			@center

		_setScale: () ->

			@needAnimation = true
			@scale

		_setRotation: () ->

			@needAnimation = true
			@rotation

		_setAlpha: () ->

			# 
			# ограничения
			# 
			@alpha = 0 if @alpha < 0
			@alpha = 1 if @alpha > 1

			@needAnimation = true
			@alpha

		_setMask: () ->

			@needAnimation = true
			@mask

		_setShadow: () ->

			@needAnimation = true
			@shadow