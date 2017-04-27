"use strict";

define () ->

	# 
	# exit if log isset
	# 
	return false if window.log?

	# 
	# all type logs in one func
	# 
	log = (text, type = "log") ->

		switch type

			when "log" then console.log text
			when "info" then console.info text
			when "warn" then console.warn text
			when "error" then console.error text

	# 
	# create options object
	# 
	log._tickOptions = {

		run: false

	}

	# 
	# log app uptime
	# 
	log.uptime = (text = "uptime", type = "log") ->

		log text + ": " + performance.now() + "ms", type

	# 
	# init tick options
	# 
	log.tickBegin = (texts, grooped = true) ->

		return if not Array.isArray texts

		log._tickOptions.grooped = grooped
		log._tickOptions.texts = texts

		log._tickOptions.index = 0

		# 
		# opened new console groop
		# 
		if log._tickOptions.grooped

			console.group log._tickOptions.texts[0]
			log._tickOptions.index = 1;

		log._tickOptions.run = true
		console.time log._tickOptions.texts[log._tickOptions.index]

	# 
	# finish last tick and start next
	# 
	log.tick = () ->

		return unless log._tickOptions.run

		console.timeEnd log._tickOptions.texts[log._tickOptions.index]

		log._tickOptions.index++

		if log._tickOptions.index >= log._tickOptions.texts.length

			log.tickEnd()

		else
			
			console.time log._tickOptions.texts[log._tickOptions.index]

	# 
	# finished tick
	# 
	log.tickEnd = () ->

		log._tickOptions.run = false

		# 
		# close console groop if need`s
		# 
		console.groupEnd log._tickOptions.texts[0] if log._tickOptions.grooped

	# 
	# now set global log object and return it
	# 

	window.log = log

	return log