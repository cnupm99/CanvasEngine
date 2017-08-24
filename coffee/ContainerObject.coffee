"use strict";

define ["DisplayObject"], (DisplayObject) ->

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