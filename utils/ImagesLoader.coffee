"use strict";

define () ->

	# 
	# Класс для предзагрузки изображений
	# 
	class ImagesLoader

		constructor: (path = "") ->

			@setPath path

		# путь для папки с изображениями
		setPath: (path) -> @_path = path

		# 
		# загрузка списка файлов изображений
		# и получение их данных
		# для формирования нового списка
		# 
		# list = [
		# 
		# 	{
		# 	
		# 		name: String
		# 		src: String
		# 	
		# 	},
		# 	
		# 	...
		# 
		# ]
		# 
		loadList: (list, callBack) ->

			total = list.length
			loaded = 0
			newList = {}

			# перебор свойств объекта
			list.forEach (image) =>

				# загружаем каждую по отдельности
				@loadImage image.src, (result) ->

					# если успешно загружено
					loaded++
					# генерируем событие
					BO.generate "imageLoaded", total, loaded, result

					# запоминаем загруженные данные
					newList[image.name] = {}
					newList[image.name].image = result.image
					newList[image.name].sizes = result.sizes
					newList[image.name].src = image.src
										
					# загрузили все
					if loaded == total

						BO.generate "imagesAllLoaded", total, loaded, newList
						# вызываем каллбак
						callBack total, loaded, newList if callBack?
				
				, (e) ->

					# ошибка при загрузке
					log e, "error"

		# загрузка одного изображения
		loadImage: (src, onload, onerror) ->

			image = document.createElement "img"

			image.onload = () =>

				if typeof(onload) == "function"

					onload {

						image: image
						src: @_path + src
						sizes: [image.width, image.height]

					}

			image.onerror = onerror

			image.src = @_path + src