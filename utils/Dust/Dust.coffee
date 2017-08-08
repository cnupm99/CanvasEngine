"use strict";

define () ->

	class Dust

		constructor: (scene) ->

			# сцена для рисования,
			# если ее нет, рисовать негде
			@_scene = options.scene
			return false unless @_scene

		add: (options) ->

			@_setOptions options

			@_sprites = []

			realSizes = @_from.sizes
			sizes = [@_perc(realSizes[0], _object.scale), @_perc(realSizes[1], _object.scale)]

			for i in [0 .. @_count]

				_object = {

					position: @_position
					scale: @_percentRand @_beginScale, @_scaleRand
					speed: @_percentRand @_speed, @_speedRand
					rotationSpeed: if @_coin() then @_percentRand @_rotationSpeed, @_rotationRand else @_percentRand -@_rotationSpeed, @_rotationRand
					rotation: @_rand 0, 360

				}

				_object.sprite = @_scene.add {

						type: "image"
						from: @_from
						position: @_position
						rotation: _object.rotation
						sizes: sizes

					}

				@_sprites.push _object

		_coin: () -> @_rand(0, 100) >= 50

		_rand: (from, to) -> from + (to - from) * Math.random()

		_perc: (value, percent) -> value / 100 * percent

		_percentRand: (value, percent) -> 

			percentValue = @_perc value, percent
			@_rand value - percentValue, value + percentValue

		_setOptions: (options) ->

			@_position = options.position or [0, 0]

			@_count = options.count or 10

			@_from = options.from
			return false unless @_from

			@_beginScale = options.beginScale or 0.01
			@_endScale = options.endScale or 1
			@_scaleRand = options.scaleRand or 50

			@_endRadius = options.endRadius or 100
			@_hideRadius = options.hideRadius or 120
			@_hideRadius = @_endRadius + 20 if @_hideRadius <= @_endRadius

			@_speed = options.speed or 10
			@_speedRand = options.speedRand or 20
			@_gravitation = options.gravitation or 2

			@_rotationSpeed = options.rotationSpeed or 30
			@_rotationRand = options.rotationRand or 50