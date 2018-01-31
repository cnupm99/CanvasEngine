"use strict";

define ["DisplayObject"], (DisplayObject) ->

	# 
	# Класс для вывода текстовой информации
	# 
	# свойства:
	# 
	#  fontHeight:int - высота шрифта
	#  textWidth:int - ширина текущего текста
	#  textHeight:int - высота текущего текста
	#  realSize:Array - размеры области текущего текста с учетом шрифта и многострочности
	#  font:String - текущий шрифт
	#  fillStyle:String/Array/Boolean - текущая заливка, градиент или false, если заливка не нужна
	#  strokeStyle:String/Boolean - обводка шрифта или false, если обводка не нужна
	#  strokeWidth:int - ширина обводки
	#  underline:Boolean - подчеркнутый текст
	#  underlineOffset:int - смещение линии подчеркивания
	#  text:String - отображаемый текст
	#  
	# методы:
	# 
	#  setFont(font:String):String - установка шрифта
	#  setFillStyle(style:String/Array):String/Array - установка заливки текста
	#  setStrokeStyle(style:String):String - установка обводки
	#  setStrokeWidth(value:int):int - толщина обводки
	#  setUnderline(value:Boolean, offset:int):Boolean - установка подчеркивания текста
	#  write(text:String):String - установка текста
	#  animate() - попытка нарисовать объект
	# 
	class Text extends DisplayObject

		constructor: (options) ->

			super options

			# 
			# тип объекта
			# 
			@type = "text"

			# 
			# высота текста с текущим шрифтом,
			# вычисляется автоматичекски при установке шрифта
			# 
			@fontHeight = 0

			# 
			# ширина текущего текста
			# вычисляется автоматически при установке текста
			# 
			@textWidth = 0

			# 
			# шрифт надписи, строка
			# 
			@setFont options.font

			# 
			# текущая заливка, градиент или false, если заливка не нужна
			# 
			@setFillStyle options.fillStyle

			# 
			# обводка шрифта или false, если обводка не нужна
			# 
			@setStrokeStyle options.strokeStyle

			# 
			# ширина обводки
			# 
			@setStrokeWidth options.strokeWidth

			# 
			# установка подчеркнутого текста
			# 
			@setUnderline options.underline, options.underlineOffset

			# 
			# текущий текст надписи
			# 
			@write options.text

		setFont: (value) ->

			# 
			# установка шрифта
			# 
			@font = value or "12px Arial"

			# 
			# получаем высоту шрифта
			# 
			@fontHeight = @_getFontHeight @font

			@needAnimation = true
			@font

		setFillStyle: (value) ->

			@fillStyle = value or false
			@needAnimation = true
			@fillStyle

		setStrokeStyle: (value) ->

			@strokeStyle = value or false
			@needAnimation = true
			@strokeStyle

		setStrokeWidth: (value) ->

			@strokeWidth = if value? then @int value else 1
			@needAnimation = true
			@strokeWidth

		setUnderline: (value, offset) ->

			@underline = value or false
			@underlineOffset = offset or 0
			@needAnimation = true
			@underline

		write: (value) ->

			# 
			# установка текста
			# 
			@text = value or ""

			# 
			# получаем реальные размеры области с текстом
			# с учетом многострочности и установленного шрифта
			# 
			@upsize @_getRealSizes(@text)

			# 
			# вспомогательные свойства, нужны для удобства
			# и обратной совместимости
			# 
			@textWidth = @realSize[0]
			@textHeight = @realSize[1]

			@needAnimation = true
			@text

		animate: () ->

			# 
			# если объект не видимый
			# то рисовать его не нужно
			# 
			if not @visible

				@needAnimation = false
				return

			super()

			# 
			# установим шрифт контекста
			# 
			@context.font = @font

			# 
			# по умолчанию позиционируем текст по верхнему краю
			# 
			@context.textBaseline = "top"

			# 
			# нужна ли заливка
			# 
			if @fillStyle

				# а может зальем текст градиентом?
				if Array.isArray @fillStyle

					# 
					# создаем градиент по нужным точкам
					# 
					gradient = @context.createLinearGradient @_deltaX, @_deltaY, @_deltaX, @_deltaY + @fontHeight

					# 
					# добавляем цвета
					# 
					@fillStyle.forEach (color) ->
						
						# сначала размер, потом цвет
						gradient.addColorStop color[0], color[1]

					# 
					# заливка градиентом
					# 
					@context.fillStyle = gradient

				# 
				# ну или просто цветом
				# 
				else @context.fillStyle = @fillStyle

			# 
			# что насчет обводки?
			# 
			if @strokeStyle

				@context.strokeStyle = @strokeStyle
				@context.lineWidth = @strokeWidth

			# 
			# разбиваем текст на строки, это нужно для вывода многострочного текста
			# 
			lines = @text.split "\n"
			# 
			# координата для смещения текста по вертикали
			# 
			textY = @_deltaY

			# 
			# если нужно подчеркивание текста
			# 
			if @underline

				# 
				# парсим шрифт в надежде найти размер шрифта
				# используем его для рисования подчеркивания
				# это ближе к истене чем использование fontHeight
				# 
				fontSize = parseInt @font, 10
				# 
				# стиль линии подчеркивания
				# 
				underlineStyle = @strokeStyle or @fillStyle

			# 
			# выводим текст построчно
			# 
			lines.forEach (line) =>
				
				# 
				# вывод текста
				# 
				@context.fillText line, @_deltaX, textY if @fillStyle
				@context.strokeText line, @_deltaX, textY if @strokeStyle

				# 
				# рисуем подчеркивание
				# 
				if @underline

					# 
					# длина данной строки текста
					# 
					lineWidth = @_getTextWidth line
					# 
					# стиль линии
					# 
					@context.strokeStyle = underlineStyle
					@context.lineWidth = @strokeWidth or 1
					# 
					# линия
					# 
					@context.beginPath()
					@context.moveTo @_deltaX, textY + fontSize + @underlineOffset
					@context.lineTo @_deltaX + lineWidth, textY + fontSize + @underlineOffset
					@context.stroke()

				# 
				# смещение следующей строки
				# 
				textY += @fontHeight

		# 
		# устанавливаем реальную высоту шрифта в пикселях
		# 
		_getFontHeight: (font) ->

			span = document.createElement "span"
			span.appendChild document.createTextNode("height")
			span.style.cssText = "font: " + font + "; white-space: nowrap; display: inline;"
			document.body.appendChild span
			fontHeight = span.offsetHeight
			document.body.removeChild span
			fontHeight

		# 
		# определяем ширину текста
		# используя для этого ссылку на контекст
		#
		_getTextWidth: (text) ->

			@context.save()
			@context.font = @font
			textWidth = @context.measureText(text).width
			@context.restore()
			textWidth

		# 
		# получаем реальные размеры области текста
		# 
		_getRealSizes: (text) ->

			# 
			# начальное значение максимальной ширины строки
			# 
			maxWidth = 0

			# 
			# разбиваем текст на строки, это нужно для вывода многострочного текста
			# 
			lines = @text.split "\n"

			# 
			# проверяем ширину каждой строки,
			# если нужно обновляем максимальное значение
			# 
			lines.forEach (line) =>

				width = @_getTextWidth line
				maxWidth = width if width > maxWidth

			# 
			# итоговый результат,
			# максимальная ширина,
			# высота равна количеству строк на высоту одной строки
			# 
			[maxWidth, lines.length * @fontHeight]

		# 
		# возвращаем объект с текущими опциями фигуры
		# 
		getOptions: () ->

			# 
			# базовое
			# 
			options = super()

			# 
			# опции текста
			# 
			options.fontHeight = @fontHeight
			options.textWidth = @textWidth
			options.textHeight = @textHeight
			options.font = @font
			options.fillStyle = @fillStyle
			options.strokeStyle = @strokeStyle
			options.strokeWidth = @strokeWidth
			options.underline = @underline
			options.underlineOffset = @underlineOffset
			options.text = @text

			# 
			# результат возвращаем
			# 
			options