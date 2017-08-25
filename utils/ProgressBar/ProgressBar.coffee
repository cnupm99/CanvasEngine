"use strict";

define () ->

	class ProgressBar

		constructor: (options) ->

			# сцена для рисования,
			# если ее нет, рисовать негде
			scene = options.scene
			return false unless scene

			# опции размера, позиции и рисования
			@_sizeOptions options
			# установка цветовых опций
			@_colorOptions options
			# установка опций текста
			@_textOptions options
			
			# установка значений
			@_minValue = options.minValue or 0
			@_maxValue = options.maxValue or 100
			@_progress = if options.progress? then options.progress else false
			
			# начальное отображение
			if @_progress

				@progress @_progress

			else

				@_value = options.value or 0
				@value @_value

		_sizeOptions: (options) ->

			# позиция
			@_position = options.position or [0, 0]
			# размеры
			@_size = options.size or [300, 50]
			# расстояние между внешней рамкой и линией прогресса
			@_padding = options.padding or 3
			# радиус скругления углов, если 0 или null,
			# то скругления не будет
			@_radius = if options.radius? then options.radius else 5

			# если требуется картинка под фон, то создадим ее
			if options.backgroundImage

				@_image = options.scene.add {

					type: "image"
					src: options.backgroundImage
					position: @_position

				}

			# создаем класс для рисования
			@_graph = options.scene.add {

				type: "graph"
				position: @_position

			}

		_textOptions: (options) ->

			# нужно ли выводить подпись
			@_showCaption = if options.showCaption? then options.showCaption else false
			# нужно ли выводить значение прогресса
			@_showProgress = if options.showProgress? then options.showProgress else true
			# нужно ли показывать максимальное значение после текущего,
			# например так: 123 / 500
			# используется только при установке value
			@_showTotal = if options.showTotal? then options.showTotal else true
			# подпись
			@_caption = options.caption or "Progress: "
			# нужна ли обводка текста
			strokeCaption = if options.strokeCaption? then options.strokeCaption else true
			# если выводить текст нужно, создаем класс для этого
			if @_showCaption or @_showProgress

				@_text = options.scene.add {

					type: "text"
					font: options.font or "24px Arial"
					fillStyle: @_colors.caption
					strokeStyle: if strokeCaption then @_colors.captionStroke else false
					position: @_position

				}

		_colorOptions: (options) ->

			colors = options.colors or {}

			@_singleColor = if options.singleColor? then options.singleColor else false
			
			@_colors = {

				# цвет фона
				backgroundColor: colors.backgroundColor or ["#C3BD73", "#DCD9A2"]
				# цвет тени фона
				backgroundShadowColor: colors.backgroundShadowColor or "#FFF"
				# цвет обводки фона
				strokeColor: colors.strokeColor or "#000"

				# этот цвет используется в случае singleColor = true
				progress: colors.progress or ["#f27011", "#E36102"]
				# цвета линии прогресса для разных значений прогресса
				progress25: colors.progress25 or ["#f27011", "#E36102"]
				progress50: colors.progress50 or ["#f2b01e", "#E3A10F"]
				progress75: colors.progress75 or ["#f2d31b", "#E3C40C"]
				progress100: colors.progress100 or ["#86e01e", "#67C000"]
				# цвет тени линии прогресса
				progressShadowColor: colors.progressShadowColor or "#000"

				# цвет надписи
				caption: colors.caption or "#B22222"
				# цвет обводки надписи
				captionStroke: colors.captionStroke or "#A11111"

			}

		# устанавливаем новые значения
		setValues: (min, max) ->

			return false if min >= max

			@_minValue = min
			@_maxValue = max
			@_animate()

		# установка прогресса
		progress: (progress) ->

			@_progress = progress
			@_value = progress * @_maxValue / 100
			@_drawProgress = true
			@_animate()

		# установка значения
		value: (value) ->

			@_value = value
			@_progress = Math.floor(value * 100 / @_maxValue)
			@_drawProgress = false
			@_animate()

		# текущий прогресс
		getProgress: () -> @_progress
		# текущее значение
		getValue: () -> @_value

		# прорисовка
		_animate: () ->

			# очистка графики
			@_graph.clear()
			# рисуем фон
			@_animateBackground()
			# рисуем линию прогесса
			@_animateProgress()
			# обновляем текст
			@_animateText()

		_animateBackground: () ->

			# если в качестве фона используется картинка, то
			# прорисовка фона не нужна
			return if @_image?

			# тень
			@_graph.setShadow {

				color: @_colors.backgroundShadowColor
				blur: 3
				offset: 0

			}
			# градиент
			@_graph.linearGradient 0, 0, 0, @_size[1], [

				[0, @_colors.backgroundColor[0]]
				[0.5, @_colors.backgroundColor[1]]
				[1, @_colors.backgroundColor[0]]

			]
			# линии
			@_graph.strokeStyle @_colors.strokeColor
			@_graph.lineWidth 1

			# рисуем
			@_graph.rect 0, 0, @_size[0], @_size[1], @_radius
			@_graph.fill()
			@_graph.stroke()

		_animateProgress: () ->

			# выбор цвета
			if @_singleColor then color = @_colors.progress
			else if @_progress <= 25 then color = @_colors.progress25
			else if @_progress <= 50 then color = @_colors.progress50
			else if @_progress <= 75 then color = @_colors.progress75
			else color = @_colors.progress100

			# размер линии
			size = Math.floor((@_size[0] - @_padding * 2) * @_value / @_maxValue)

			# тень
			@_graph.setShadow {

				color: @_colors.progressShadowColor
				blur: 3
				offset: 0

			}
			# градиент
			@_graph.linearGradient @_padding, @_padding, @_padding, @_size[1] - @_padding, [

				[0, color[0]]
				[1, color[1]]
				# вариант градиента со средним затемнением
				# [0.5, color[1]]
				# [1, color[0]]

			]

			# рисуем
			@_graph.rect @_padding, @_padding, size, @_size[1] - @_padding * 2, @_radius
			@_graph.fill()

		_animateText: () ->

			# нужен ли текст
			if @_text?

				# формируем текст
				text = ""
				text += @_caption if @_showCaption

				if @_showProgress

					if @_drawProgress

						text += @_progress + "%"

					else

						text += @_value
						# если нужно, выводим максимальное значение
						text += " / " + @_maxValue if @_showTotal

				# установка текста
				@_text.write text
				# установка позиции
				@_text.move [@_position[0] + (@_size[0] - @_text.textWidth) / 2, @_position[1] + (@_size[1] - @_text.fontHeight) / 2]