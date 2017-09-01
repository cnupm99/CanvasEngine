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
			# меняем тип в опциях для создания картинки
			# 
			options.type = "image"

			# 
			# загрузка картинки
			# 
			if options.from?

				if Array.isArray options.from

					@setFrames options.from
					options.from = @frames[@currentFrame]

			# 
			# загрузка картинки
			# 
			if options.src?

				if Array.isArray options.src

					@setFrames options.src
					options.src = @frames[@currentFrame]

			# 
			# создаем картинку
			# 
			@image = CE.add options

			# 
			# работаем через наборы кадров
			# 
			if options.frameSet?

				@setFrameSet options.frameSet

			# 
			# работаем через количество или ширину кадров
			# 
			if options.frameWidth? or options.frameCount?

				# 
				# вычисляем количество и ширину кадров
				# 
				@frameWidth = options.frameWidth or @image.realSize[0] / options.frameCount
				@frameCount = options.frameCount or @image.realSize[0] / options.frameWidth

				# 
				# меняем размеры вывода картинки под размеры кадра
				# 
				@image.resize [@frameWidth, @image.realSize[1]]

				# 
				# а теперь получаем набор кадров
				# 
				frameSet = []
				for i in [0 ... @frameCount]

					frameSet.push [i * @frameWidth, 0, @frameWidth, @image.realSize[1]]

				# 
				# и работаем через набор кадров
				# 
				@setFrameSet frameSet

			# 
			# если нужно, используем массив интервалов,
			# отдельный интервал для каждого кадра
			# 
			@intervals = options.intervals or false

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

			@frameSet = value
			@maxFrame = @frameSet.length - 1
			@currentFrame = 0 if @currentFrame > @maxFrame or @currentFrame < 0
			@image.setRect @frameSet[@currentFrame]
			@type = "set"

		# 
		# начало воспроизведения анимации
		# 
		play: (frame) ->

			@currentFrame = frame or @currentFrame
			@currentFrame = 0 if @currentFrame > @maxFrame or @currentFrame < 0
			@slowing = @intervals[@currentFrame] if @intervals
			@playing = true

		pause: () -> @playing = false

		stop: () ->

			@playing = false
			@currentFrame = 0

		# 
		# установка массива с картинками
		# 
		setFrames: (frames) ->

			@frames = frames
			@maxFrame = @frames.length - 1
			@currentFrame = 0 if @currentFrame > @maxFrame or @currentFrame < 0
			@type = if typeof(@frames[@currentFrame]) == "string" then "src" else "from"

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

						@loadedFrame = @currentFrame