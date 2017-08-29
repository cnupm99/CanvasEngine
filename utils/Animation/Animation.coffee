"use strict";

define () ->

	# 
	# Анимация, рисующая несколько картинок, сменяющих друг друга.
	# 
	# Варианты создания:
	# 
	# 	1. from:Array - массив картинок, сменяющих друг друга
	# 
	# свойства:
	#  
	#  rect:Array - прямоугольник для замастивания
	#  
	# методы:
	# 
	#  setRect(value:Array):Array - установка области
	#  animate() - попытка нарисовать объект 
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

			options.type = "image"

			if options.from?

				if Array.isArray options.from

					@setFrames options.from
					options.from = @frames[@currentFrame]

			if options.src?

				if Array.isArray options.src

					@setFrames options.src
					options.src = @frames[@currentFrame]

			@image = CE.add options

			CE.addEvent @update

			# 
			# автовоспроизведение
			# 
			@play() if @autoPlay

		play: (frame) ->

			@currentFrame = frame or @currentFrame
			@currentFrame = 0 if @currentFrame > @maxFrame or @currentFrame < 0
			@playing = true

		pause: () -> @playing = false

		stop: () ->

			@playing = false
			@currentFrame = 0

		setFrames: (frames) ->

			@frames = frames
			@maxFrame = @frames.length - 1
			@currentFrame = 0 if @currentFrame > @maxFrame or @currentFrame < 0

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

					@currentFrame++
					@_counter = 0

					if @currentFrame > @maxFrame

						if @loop

							@currentFrame = 0

						else

							@currentFrame = -1
							@playing = false

					if @playing and @loadedFrame != @currentFrame

						img = @frames[@currentFrame]

						if typeof(img) == "string"

							@image.src img

						else

							@image.from img

						@loadedFrame = @currentFrame