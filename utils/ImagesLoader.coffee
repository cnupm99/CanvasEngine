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
		# list = {
		# 
		# 	"imageName": {
		# 	
		# 		src: String
		# 	
		# 	},
		# 	
		# 	...
		# 
		# }
		# 
		loadList: (list, callBack) ->

			total = Object.keys(list).length
			loaded = 0

			# перебор свойств объекта
			for name in list

				image = list[name]

				# загружаем каждую по отдельности
				@loadImage image.src, (result) ->

					# если успешно загружено
					loaded++
					# генерируем событие
					BO.generate "imageLoaded", total, loaded, result

					# запоминаем загруженные данные
					list[name].image = result.image
					list[name].sizes = result.sizes
										
					# загрузили все
					if loaded == total

						BO.generate "imagesAllLoaded", total, loaded, list
						# вызываем каллбак
						callBack total, loaded, list if callBack?
				
				, (e) ->

					# ошибка при загрузке
					log "Loading Error: " + e.toString(), "error"

		# загрузка одного изображения
		loadImage: (src, onload, onerror) ->

			image = document.createElement "img"

			image.onload = () ->

				if typeof(onload) == "function"

					onload {

						image: image
						src: src
						sizes: [image.width, image.height]

					}

			image.onerror = onerror

			image.src = @_path + src