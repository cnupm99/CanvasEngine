"use strict";

define ["base"], (base) ->

	class Scene extends base

		constructor: (options) ->

			super options

			@name = options.name

			@view = document.createElement "canvas"

			