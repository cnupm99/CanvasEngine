"use strict";

define () ->

	# 
	# exit if BO isset
	# 
	return false if window.BO?

	# 
	# create
	# 
	BO = {}

	BO._eventHandlers = {}

	# 
	# add listener handler to eventName event
	# 
	BO.on = (eventName, handler) ->

		@_eventHandlers[eventName] = [] unless @_eventHandlers[eventName]

		@_eventHandlers[eventName].push handler

	# 
	# remove listener
	# 
	BO.off = (eventName, handler) ->

		return unless @_eventHandlers[eventName]

		@_eventHandlers[eventName].forEach (item, i) => @_eventHandlers[eventName].splice i, 1 if item == handler

		delete @_eventHandlers[eventName] if @_eventHandlers[eventName].length == 0

	# 
	# generate event
	# 
	BO.generate = (eventName, args...) ->

		return unless @_eventHandlers[eventName]

		@_eventHandlers[eventName].forEach (item) -> 

			item.apply(@, [].slice.call(args, 0))

	# 
	# create global object and return it
	# 

	window.BO = BO

	return BO