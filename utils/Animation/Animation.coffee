"use strict";

define () ->

	# 
	# Анимация, рисующая несколько картинок, сменяющих друг друга.
	# 
	# Варианты создания:
	# 
	# 	1. from:Array - массив картинок, сменяющих друг друга
	# 	2. src:Array - НЕ рекомендуется из-за мигания при загрузке картинок
	# 	3. frameSet:Array - массив прямоугольных координат для вырезания кадров из картинки
	# 	4. frameCount:int или frameWidth:int - количество или ширина кадров для вырезания их из картинки
	# 
	class Animation

		constructor: (CE, options) ->

			# 
			# установка опций анимации
			# 
			@_setOptions options

			# 
			# работаем через from
			# 
			options.from = @_setFrom options if options.from?

			# 
			# работаем через src
			# 
			options.src = @_setSrc options if options.src?

			# 
			# создаем картинку
			# 
			@_createImage options

			# 
			# работаем через наборы кадров
			# 
			@setFrameSet options.frameSet if options.frameSet?

			# 
			# работаем через количество или ширину кадров
			# 
			@_setFrameCount options if options.frameWidth? or options.frameCount?

			# 
			# добавляем функцию обновления анимации
			# 
			CE.addEvent @update

			# 
			# автовоспроизведение
			# 
			@play() if @autoPlay

		# 
		# установка набора кадров
		# 
		setFrameSet: (value) ->

			# 
			# массив координат для вырезания кадров
			# 
			@frameSet = value
			# 
			# количество кадров в анимации
			# 
			@maxFrame = @frameSet.length - 1
			# 
			# текущий кадр 
			# 
			@currentFrame = 0 if @currentFrame > @maxFrame or @currentFrame < 0
			# 
			# устновка кадра
			# 
			@image.setRect @frameSet[@currentFrame]
			# 
			# установка типа анимации
			# 
			@type = "set"

		# 
		# установка массива с картинками
		# 
		setFrames: (frames) ->

			# 
			# массив с картинками
			# 
			@frames = frames
			# 
			# количество кадров
			# 
			@maxFrame = @frames.length - 1
			# 
			# текущий кадр
			# 
			@currentFrame = 0 if @currentFrame > @maxFrame or @currentFrame < 0
			# 
			# выбор типа анимации взависимости от типа
			# переданных параметров:
			# картинки либо ссылки
			# 
			@type = if typeof(@frames[@currentFrame]) == "string" then "src" else "from"

		# 
		# начало воспроизведения анимации
		# 
		play: (frame) ->

			# 
			# установка текущего кадра
			# 
			@currentFrame = frame or @currentFrame
			# 
			# ограничение кадров
			# 
			@currentFrame = 0 if @currentFrame > @maxFrame or @currentFrame < 0
			# 
			# текущий интервал между кадрами
			# 
			@slowing = @intervals[@currentFrame] if @intervals
			# 
			# начинаем проигрывание
			# 
			@playing = true

		# 
		# пауза в анимации
		# 
		pause: () -> @playing = false

		# 
		# остановить анимацию
		# 
		stop: () ->

			@playing = false
			@currentFrame = 0

		# 
		# собственно обработка анимации
		# 
		update: () =>

			# 
			# идет ли проигрывание анимации
			# 
			if @playing

				# 
				# прибавляем счетчик
				# 
				@_counter++

				# 
				# нужно ли загружать следующий кадр
				# 
				if @slowing == 1 or @_counter % @slowing == 0

					# 
					# следующий кадр
					# 
					@currentFrame++
					@_counter = 0

					# 
					# обработка превышения количества кадров
					# 
					if @currentFrame > @maxFrame

						# зациклено
						if @loop

							@currentFrame = 0

						# остановлено
						else

							@currentFrame = -1
							@playing = false

					# 
					# новый интервал для данного кадра
					# 
					@slowing = @intervals[@currentFrame] if @intervals

					# 
					# если все еще проигрываем
					# и новый кадр не загружен
					# 
					if @playing and @loadedFrame != @currentFrame

						# 
						# в зависимости от типа загружаем новый кадр
						# 
						switch @type

							when "src" then @image.src @frames[@currentFrame]
							when "from" then @image.from @frames[@currentFrame]
							when "set" then @image.setRect @frameSet[@currentFrame]

						# 
						# теперь загруженный кадр равен текущему
						# 
						@loadedFrame = @currentFrame

		_setOptions: (options) ->

			# 
			# номер отображаемого кадра
			# 
			@currentFrame = options.currentFrame or 0

			# 
			# номер последнего загруженного кадра
			# 
			@loadedFrame = -1

			# 
			# максимальное количество кадров в анимации
			# 
			@maxFrame = options.maxFrame or 0

			# 
			# замедление анимации
			# 
			@slowing = options.slowing or 1

			# 
			# счетчик для замедления анимации
			# 
			@_counter = 0

			# 
			# нужно ли проигрывать анимацию по кругу
			# 
			@loop = if options.loop? then options.loop else true

			# 
			# начинать ли воспроизведение автоматически после загрузки
			# 
			@autoPlay = if options.autoPlay? then options.autoPlay else true

			# 
			# идет ли анимация в данный момент
			# 
			@playing = false

			# 
			# если нужно, используем массив интервалов,
			# отдельный интервал для каждого кадра
			# 
			@intervals = options.intervals or false

		_createImage: (options) ->

			# 
			# меняем тип в опциях для создания картинки
			# 
			options.type = "image"

			# 
			# сцена для анимации
			# 
			scene = options.scene
			return unless scene?

			# 
			# создаем картинку
			# 
			@image = scene.add options

		# 
		# если работаем через from
		# 
		_setFrom: (options) ->

			if Array.isArray options.from

				# 
				# массив картинок
				# 
				@setFrames options.from
				# 
				# возвращаем новый from
				# 
				@frames[@currentFrame]

			# 
			# если не массив, то значение остается прежним
			# 
			else options.from

		# 
		# если работаем через src
		# 
		_setSrc: (options) ->

			if Array.isArray options.src

				# 
				# массив ссылок
				# 
				@setFrames options.src
				# 
				# возвращаем новый src
				# 
				@frames[@currentFrame]

			# 
			# если не массив, то значение остается прежним
			# 
			else options.src

		# 
		# если работаем через количество или размер кадров
		# 
		_setFrameCount: (options) ->

			# 
			# вычисляем количество и ширину кадров
			# 
			frameWidth = options.frameWidth or @image.realSize[0] / options.frameCount
			frameCount = options.frameCount or @image.realSize[0] / options.frameWidth

			# 
			# меняем размеры вывода картинки под размеры кадра
			# 
			@image.resize [frameWidth, @image.realSize[1]]

			# 
			# а теперь получаем набор кадров
			# 
			frameSet = []
			for i in [0 ... frameCount]

				frameSet.push [i * frameWidth, 0, frameWidth, @image.realSize[1]]

			# 
			# и работаем через набор кадров
			# 
			@setFrameSet frameSet