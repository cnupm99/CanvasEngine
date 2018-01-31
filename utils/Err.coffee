"use strict";

# 
# загружаем BO для уверенности, что он доступен
# 
define ["utils/BO"], (BO) ->

	# 
	# массив возможных ошибок
	# делаем приватным, доступ через замыкание
	# 
	# ошибки с id 0 - 100 - служебные
	# 101 - 999 - серверные
	# 1000 - 2000 - клиентские
	# 
	_errors = [

		{
			id: 0
			source: "Empty"
			message: "Ошибки отсутствуют"
			place: "Empty"
			critical: false
		}
		{
			id: 10
			source: "unknown"
			message: "неизвестная ошибка"
			place: "unknown"
			critical: true
		}
		{
			id: 101
			source: "antispam.php"
			message: "Сообщение помечено как спам"
			place: "server"
			critical: true
		}
		{
			id: 102
			source: "network.php"
			message: "Хеш не совпадает с вычисленным"
			place: "server"
			critical: true
		}	
		{
			id: 103
			source: "network.php"
			message: "Ошибка авторизации"
			place: "server"
			critical: true
		}
		{
			id: 104
			source: "antispam.php"
			message: "Бан по id"
			place: "server"
			critical: true
		}
		{
			id: 105
			source: "requests.php"
			message: "Ошибка авторизации в БД"
			place: "server"
			critical: true
		}
		{
			id: 106
			source: "requests.php"
			message: "Ошибка при запросе к БД"
			place: "server"
			critical: true
		}
		{
			id: 107
			source: "network.php"
			message: "Ошибка в кодирование / декодировании запроса"
			place: "server"
			critical: true
		}
		{
			id: 108
			source: "network.php"
			message: "Неизвестная команда серверу"
			place: "server"
			critical: true
		}
		{
			id: 109
			source: "antispam.php"
			message: "Недопустимый символ в сообщении от клиента"
			place: "server"
			critical: true
		}
		{ 
			id: 1001
			source: "Request.js"
			message: "ошибка при создании XMLHttpRequest"
			place: "client"
			critical: true
		}
		{
			id: 1002
			source: "Request.js"
			message: "ошибка при выполнении get запроса"
			place: "client"
			critical: true
		}
		{
			id: 1003
			source: "Request.js"
			message: "ошибка при выполнении post запроса"
			place: "client"
			critical: true
		}
		{
			id: 1004
			source: "Network.js",
			message: "hash в сообщении от сервера не совпадает с вычисленным"
			place: "client"
			critical: true
		}
		{
			id: 1005
			source: "Network.js"
			message: "сервер прислал ответ в неверном формате json"
			place: "client"
			critical: true
		}
		{
			id: 1006
			source: "Network.js"
			message: "невозможно декодировать сообщение от сервера"
			place: "client"
			critical: true
		}
		{
			id: 1007
			source: "Network.js"
			message: "ошибка при попытке закодировать сообщение"
			place: "client"
			critical: true
		}
		{
			id: 1008
			source: "lang.js"
			message: "ошибка при расшифровке языкового файла"
			place: "client"
			critical: true
		}
		{
			id: 1009
			source: "Loader.js"
			message: "ошибка при расшифровке файла ресурсов"
			place: "client"
			critical: true
		}
		{
			id: 1010
			source: "Network.js"
			message: "ошибка при загрузке изображения"
			place: "client"
			critical: true
		}
		{
			id: 1011
			source: "Loader.js"
			message: "ошибка при расшифровке файла уровней"
			place: "client"
			critical: true
		}
		{
			id: 1012
			source: "ImagesLoader.js"
			message: "ошибка при загрузке изображения"
			place: "client"
			critical: true
		}
		{
			id: 1013
			source: "lang.js"
			message: "файл языка не загружен"
			place: "client"
			critical: true
		}
		{
			id: 1014
			source: "lang.js"
			message: "не существующая фраза / секция"
			place: "client"
			critical: false
		}

	]

	# 
	# добавляем прослушку событий
	# обязательно передавать вместе с этим событие id ошибки
	# опционально - errorSource
	# 
	BO.on "ERROR", (errorId, errorSource) ->

		error = null

		# 
		# ищем описание ошибки по ее id
		# 
		_errors.some (_error) ->

			flag = errorId == _error.id
			error = _error if flag
			return flag

		# 
		# если ошибка с таким id не найдена,
		# генерируем неизвестную ошибку
		# 
		unless error?

			error = _errors[0]
			error.source = errorSource if errorSource?

		# 
		# сообщение об ошибке в консоли
		# 
		log error.message + " in " + error.source, "error"

		# 
		# генерируем событие с обработанной ошибкой
		# для отображения окна с описанием ошибки
		# 
		BO.generate "SHOW_ERROR", error