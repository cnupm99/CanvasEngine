"use strict";

define () ->

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

			# родитель
			@_parent = options.parent or document.body
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
			return [@_int(value), @_int(value2]) if value2?

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