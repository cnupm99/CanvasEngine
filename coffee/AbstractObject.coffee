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