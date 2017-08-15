"use strict";

define () ->

	class FPS

		# 
		# Служебный класс для рисования таблички
		# с отображением
		# FPS - Frame Per Seconds
		# UPS - Update Per Seconds
		# 
		# UPS показывает сколько реально раз происходила перерисовка чего либо
		# 
		constructor: (CE, position = [0, 0]) ->

			return unless CE?
			@CE = CE

			@_scene = CE.add {

				type: "scene"
				name: "FPS"
				zIndex: 9999
				size: [100, 45]
				position: position

			}
			
			# граф для прорисовки
			@_graph = @_scene.add { type: "graph" }

			# массив значений
			@_values = []

			# зеленая надпись
			@_caption = @_scene.add {

				type: "text"
				fillStyle: "#00FF00"
				font: "12px Arial"
				position: [3, 1]

			}

			# красная надпись
			@_caption2 = @_scene.add {

				type: "text"
				fillStyle: "#FFFF00"
				font: "12px Arial"
				position: [53, 1]

			}

			CE.addEvent @_update

			# запускаем
			@start()
			# рисуем
			@_onTimer()

		start: () ->

			@_counter = @_updateCounter = @_FPSValue = 0
			@_interval = setInterval @_onTimer, 1000

		stop: () ->

			clearInterval @_interval
			@_counter = @_updateCounter = @_FPSValue = 0

		_onTimer: () =>

			@_FPSValue = @_counter
			@_counter = 0
			@_updateValue = @_updateCounter
			@_updateCounter = 0
			# записываем значения в массив
			@_values.push [@_FPSValue, @_updateValue]
			# лишние выкидываем
			@_values.shift() if @_values.length == 94

			# начинаем рисовать
			@_graph.clear()
			@_graph.fillStyle "#000"
			@_graph.rect 0, 0, 100, 45
			@_graph.fill()

			for i in [0 ... @_values.length]

				x = 97 - @_values.length + i
				fps = @_values[i][0]
				ups = @_values[i][1]

				@_graph.strokeStyle "#00FF00"
				@_graph.line x, 42, x, 42 - 26 * fps / 60
				@_graph.strokeStyle "#FFFF00"
				@_graph.line x, 42, x, 42 - 26 * ups / 60

			@_caption.setText "FPS: " + @_FPSValue
			@_caption2.setText "UPS: " + @_updateValue

		# эту функцию нужно вызывать в цикле анимации
		# для подсчета значений
		_update: () =>

			@_counter++
			@_updateCounter++ if @CE.needAnimation