"use strict";

define () ->

	class Request

		constructor: () ->

		# 
		# загрузка файла с помощью get запроса
		# 
		get: (fileName, callBack) ->

			# событие для запуска таймера
			BO.generate "serverQueryStart"

			x = @_xhr()

			x.open "GET", SERVER_URL + fileName + "?r=" + Math.random(), true

			x.onreadystatechange = () ->
			
				if x.readyState == 4
					
					if x.status == 200
					
						# событие для остановки таймера
						BO.generate "serverQueryFinish"

						callBack x.responseText
					
					else
						
						BO.generate "error", 52
						callBack false

			x.send()

		# 
		# отправить запрос к php серверу с данными data
		# 
		post: (data, callBack) ->

			# событие для запуска таймера
			BO.generate "serverQueryStart"

			# прибавляем пробел, иначе не воспринимает как строку
			# и не отправляет данные
			# на сервере очищаем сообщение от лишних пробелов
			# такой вот хак
			fd = new FormData()
			fd.append "body", " " + data.body
			fd.append "hash", " " + data.hash

			x = @_xhr()

			x.open "POST", SERVER_APP, true

			x.onreadystatechange = () ->
			
				if x.readyState == 4
					
					if x.status == 200
					
						# событие для остановки таймера
						BO.generate "serverQueryFinish"

						callBack x.responseText
					
					else
						
						BO.generate "error", 53
						callBack false

			x.send(fd)

		# 
		# создать новое подключение
		# 
		_xhr: () ->

			try
				x = new ActiveXObject "Msxml2.XMLHTTP"
			catch e
				
				try
					x = new ActiveXObject "Microsoft.XMLHTTP"
				catch E
					x = false
			
			if not x and typeof XMLHttpRequest != 'undefined'
				
				x = new XMLHttpRequest()

			BO.generate "error", 51 unless x

			return x