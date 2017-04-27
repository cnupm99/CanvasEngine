"use strict";

define ["network/Request"], (Request) ->

	# 
	# exit if lang isset
	# 
	return false if window.lang?

	# 
	# если язык загружен, возвращает фразу из секции
	# или секцию целиком
	# 
	lang = (section, phraseId) ->

		return false unless lang._loaded

		if phraseId? then lang._data[section][phraseId] else lang._data[section]

	# 
	# изначально язык не загружен
	# 
	lang._loaded = false

	# 
	# проверка, поддерживается ли данный язык
	# 
	lang._check = (langName) ->

		SUPPORT_LANGS.indexOf(langName) >= 0

	# 
	# возвращает язык браузера
	# 
	lang._getBrowserLang = () ->

		navigator.language or navigator.browserLanguage or navigator.systemLanguage or navigator.userLanguage

	# 
	# возвращает язык ВК
	# 
	lang._getVKLang = () ->

		window.userParams["lang"]

	lang._auto = () ->

		# по умолчанию берем язык из ВК
		langName = lang._getVKLang()

		# проверяем поддержку языка
		if lang._check langName

			lang._langName = langName

		else

			lang._langName = SUPPORT_LANGS[0]

	lang.load = (callBack, langName) ->

		# проверка существования и поддержки языка
		langName = lang._auto() unless langName
		langName = lang._auto() unless lang._check langName

		# загрузка файла языка
		r = new Request()
		r.get LANGS_PATH + langName + ".json", (r) ->

			# парсим файл
			try
				lang._data = JSON.parse r
			catch e
				BO.generate "error", 58
				callBack false

			# загружено и пропарсино
			lang._langName = langName
			lang._loaded = true

			callBack true

	# 
	# now set global lang object and return it
	# 

	window.lang = lang

	return lang