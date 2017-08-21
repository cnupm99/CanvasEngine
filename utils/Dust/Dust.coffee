"use strict";

define () ->

	class Dust

		constructor: (ce) ->

			# движок
			@_ce = ce

			# набор сетов, изначально пустой
			@_assets = []

			# свойство показывает, добавлена ли функция в цикл анимации
			@_enabled = false

		# 
		# добавление сета
		# 
		add: (options) ->

			asset = {}

			# сцена для рисования,
			# если ее нет, рисовать негде
			asset.scene = options.scene
			return false unless asset.scene

			# установка опций
			@_setOptions asset, options

			# массив спрайтов
			asset.sprites = []

			# создаем спрайты
			for i in [0 ... asset.count]

				_object = {}
				_object = {

					# текущий размер спрайта
					scale: @_percentRand asset.beginScale, asset.scaleRand
					# скорость движения спрайта
					speed: @_percentRand asset.speed, asset.speedRand
					# скорость и направление вращения спрайта
					rotationSpeed: if @_coin() then @_percentRand asset.rotationSpeed, asset.rotationRand else - @_percentRand asset.rotationSpeed, asset.rotationRand
					# пройденный путь
					radius: 0

				}

				# направление полета
				delta = @_rand(0, 360) / 180 * Math.PI
				# смещение по горизонтали
				_object.deltaX = Math.cos(delta) * _object.speed
				# смещение по вертикали
				_object.deltaY = Math.sin(delta) * _object.speed
				# скорость изменения размера
				_object.scaleSpeed = (asset.endScale - _object.scale) / asset.endRadius * _object.speed
				# скорость изменения прозрачности
				_object.alphaSpeed = 1 / (asset.hideRadius - asset.endRadius) * _object.speed

				# рисуем спрайт
				_object.sprite = asset.scene.add {

					type: "image"
					from: options.from
					position: asset.position
					rotation: @_rand 0, 360
					anchor: [0.5, 0.5]
					size: [_object.scale * asset.from.width, _object.scale * asset.from.height]
					name: "" + Math.random()

				}

				# сохраняем спрайт в сете
				asset.sprites.push _object

			# сохраняем сет в списке сетов
			@_assets.push asset

			# если надо добавляем событие в цикл анимации
			if @_assets.length > 0 and not @_enabled

				@_ce.addEvent @_update
				@_enabled = true

		# 
		# пересчет и обновление сетов
		# 
		_update: () =>

			# если сетов нет, удаляем событие из цикла анимации
			if @_assets.length == 0

				@_ce.removeEvent @_update
				@_enabled = false

			# перебор сетов
			@_assets.forEach (asset, assetIndex) =>

				asset.step++
				return if asset.step % asset.slow != 0

				# перебор спрайтов
				asset.sprites.forEach (_object, _objectIndex) =>

					# спрайт летит
					_object.sprite.shift _object.deltaX, _object.deltaY
					# дейтвие гравитации
					_object.sprite.shift 0, asset.gravitation
					# гравитация усиливается
					asset.gravitation += 0.005
					# спрайт увеличивается
					_object.scale += _object.scaleSpeed
					_object.sprite.resize [_object.scale * asset.from.width, _object.scale * asset.from.height]
					# спрайт крутится
					_object.sprite.rotateOn _object.rotationSpeed
					# учтем пройденный путь
					_object.radius += _object.speed

					# вылетели за радиус, начинаем затенять
					if _object.radius > asset.endRadius

						_object.sprite.setAlpha _object.alphaSpeed

					# вылетели дальше
					if _object.radius > asset.hideRadius

						# удаляем картинку
						asset.scene.remove _object.sprite.name
						# удаляем объект
						asset.sprites.splice _objectIndex, 1

						# если объектов больше нет, удаляем сет
						if asset.sprites.length == 0

							@_assets.splice assetIndex, 1
							# обновляем сцену
							asset.scene.needAnimation = true

		# кинуть монетку
		_coin: () -> @_rand(0, 100) >= 50

		# случайная величина от и до
		_rand: (from, to) -> from + (to - from) * Math.random()

		# взять процент от величины
		_perc: (value, percent) -> value / 100 * percent

		# получить величину, с рандомным значением на определенный процент
		_percentRand: (value, percent) -> 

			percentValue = @_perc value, percent
			@_rand value - percentValue, value + percentValue

		# 
		# установка опций сета
		# 
		_setOptions: (asset, options) ->

			# позиция на сцене
			asset.position = options.position or [0, 0]

			# количество звезд
			asset.count = options.count or 20

			# спрайт картинки
			asset.from = options.from
			return false unless asset.from

			# начальный размер спрайтов
			asset.beginScale = options.beginScale or 0.1
			# конеченый размер спрайтов
			asset.endScale = options.endScale or 1
			# разброс размера в процентах
			asset.scaleRand = options.scaleRand or 50

			# радиус разлетания
			asset.endRadius = options.endRadius or 250
			# радиус исчезновения
			asset.hideRadius = options.hideRadius or 300
			asset.hideRadius = asset.endRadius + 20 if asset.hideRadius <= asset.endRadius

			# скорость разлетания
			asset.speed = options.speed or 5
			# разброс скорости в процентах
			asset.speedRand = options.speedRand or 50
			# гравитация
			asset.gravitation = options.gravitation or 1

			# скорость поворота спрайтов
			asset.rotationSpeed = options.rotationSpeed or 10
			# разброс скорости поворота в процентах
			asset.rotationRand = options.rotationRand or 50

			# замедление анимации
			asset.slow = options.slow or 1
			asset.step = 0;