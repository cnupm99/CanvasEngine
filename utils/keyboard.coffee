"use strict";

define () ->

	# нужен только один экземпляр
	return false if window.keyboard?

	# создаем объект
	keyboard = {}

	# массив нажатых кнопок
	keyboard._keys = []

	# коды некоторых важных кнопок
	keyboard._codes =  {

		"SHIFT": 16
		"ALT": 18
		"CTRL": 17

	}

	# нажата ли кнопка shift
	keyboard.shift = () ->

		keyboard.key keyboard._codes.SHIFT

	# нажата ли кнопка с определенным кодом
	keyboard.key = (keyCode) ->

		keyboard._keys.indexOf(keyCode) >= 0

	# когда кнопка нажимается, добавляем ее код в массив
	keyboard._onKeyDown = (e) ->

		keyboard._keys.push e.keyCode if not keyboard.key e.keyCode

	# когда кнопка отжимается, удаляем ее код из массива
	keyboard._onKeyUp = (e) ->

		index = keyboard._keys.indexOf e.keyCode
		keyboard._keys.splice index, 1

	# вешаем события нажатия кнопок
	window.addEventListener "keydown", keyboard._onKeyDown
	window.addEventListener "keyup", keyboard._onKeyUp

	# добавляем глобальную переменную
	global "keyboard", keyboard