"use strict";

define () ->

	unless window.global?

		# 
		# функция для задания глобальных констант
		# 
		window.global = (constName, constValue) ->

			window[constName] = constValue

	# 
	# далее идет конфигурация приложения
	# 

	# выводить ли подробные логи (отладка)
	global "SHOW_LOGS", true

	

	# возвращаем на всякий случай
	return true