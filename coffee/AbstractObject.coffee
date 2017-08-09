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
		#  center: Array - относительные координаты точки центра объекта, вокруг которой происходит вращение
		#  rotation: Number - число в градусах, на которое объект повернут вокруг центра по часовой стрелке
		#  alpha: [0..1] - прозрачность объекта
		#  mask: Object - маска объекта
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
			# 
			@parent = options.parent or document.body

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
			# видимость объекта, устанавливаемая пользователем
			# true / false
			# 
			_visible = if options.visible? then options.visible else true
			Object.defineProperty @, "visible", {

				get: () -> _visible
				set: (value) -> 

					_visible = if value? then value else true

					# 
					# сообщаем движку, нужно ли анимировать объект
					# 
					@needAnimation = _visible

			}

			# 
			# позиция объекта
			# массив вида [x, y], либо объект вида {x: int, y: int}
			# 
			_position = @point options.position
			Object.defineProperty @, "position", {

				get: () -> _position
				set: (value) -> 

					_position = @point value
					@needAnimation = true
					_position

			}

			# 
			# размер объекта
			# массив вида [width, height], либо объект вида {width: int, height: int}
			# 
			_size = @point options.size
			Object.defineProperty @, "size", {

				get: () -> _size
				set: (value) -> 

					_size = @point value
					@needAnimation = true
					_size

			}

			# 
			# координаты точки, являющейся центром объекта,
			# вокруг этой точки производится вращение объекта
			# координаты точки задаются не относительно начала координат,
			# а относительно левого верхнего угла объекта
			# массив вида [x, y], либо объект вида {x: int, y: int}
			# 
			_center = @point options.center
			Object.defineProperty @, "center", {

				get: () -> _center
				set: (value) -> 

					_center = @point value
					@needAnimation = true
					_center

			}

			# 
			# поворот объекта вокруг точки center по часовой стрелке, измеряется в градусах
			# число
			# 
			_rotation = @number options.rotation
			Object.defineProperty @, "rotation", {

				get: () -> _rotation
				set: (value) -> 

					_rotation = @number value
					@needAnimation = true
					_rotation

			}

			# 
			# прозрачность объекта
			# число от 0 до 1
			# 
			_alpha = @number options.alpha
			Object.defineProperty @, "alpha", {

				get: () -> _alpha
				set: (value) -> 

					_alpha = @number value
					
					# 
					# ограничения
					# 
					_alpha = 0 if _alpha < 0
					_alpha = 1 if _alpha > 1

					@needAnimation = true
					_alpha

			}

			# 
			# прямоугольная маска, применимо к Scene
			# если маска дейтсвует, то на сцене будет отображаться только объекты внутри маски
			# объект вида {x: int, y: int, width: int, height: int} или false
			# 
			# ВНИМАНИЕ!
			# В браузере firefox есть баг (на 25.04.17), а именно:
			# при попытке нарисовать на канве изображение, используя одновременно
			# маску и тень (mask и shadow в данном случае), получается
			# странная хрень, а точнее маска НЕ работает в данном случае
			# Доказательство и пример здесь: http://codepen.io/cnupm99/pen/wdGKBO
			# 
			_mask = options.mask or false
			Object.defineProperty @, "mask", {

				get: () -> _mask
				set: (value) -> 

					if (not value?) or (not value)

						_mask = false
						return

					_mask = {

						x: @int value.x
						y: @int value.y
						width: @int value.width
						height: @int value.height 

					}

					@needAnimation = true
					_mask

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
			_shadow = options.shadow or false
			Object.defineProperty @, "shadow", {

				get: () -> _shadow
				set: (value) -> 

					if (not value?) or (not value)

						_shadow = false
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

					@needAnimation = true

			}

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
			return [@int(value1), @int(value2)] if value2?

			# если передан массив
			if Array.isArray value1

				# возвращаем первые два элемента
				return [@int(value1[0]), @int(value1[1])]

			# может быть это объект?
			else

				# если есть свойства x и y
				return [@int(value1.x), @int(value1.y)] if value1.x? and value1.y?
				# если есть свойства width и height
				return [@int(value1.width), @int(value1.height)] if value1.width? and value1.height?
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