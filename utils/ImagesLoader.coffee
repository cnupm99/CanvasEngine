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

		# загрузка массива с путями до изображений 
		loadList: (list, callBack) ->

			total = list.length
			loaded = 0

			list.forEach (src) =>

				# загружаем каждую по отдельности
				@loadImage src, () ->

					# если успешно загружено
					loaded++
					# генерируем событие
					BO.generate "imageLoaded", total, loaded
					# загрузили все
					BO.generate "imagesAllLoaded", total, loaded if loaded == total
					# вызываем каллбак
					callBack total, loaded if callBack?
				
				, (e) ->

					# ошибка при загрузке
					log "Loading Error: " + e.toString(), "error"

		# загрузка одного изображения
		loadImage: (src, onload, onerror) ->

			image = document.createElement "img"

			image.onload = onload

			image.onerror = onerror

			image.src = @_path + src