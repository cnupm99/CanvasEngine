"use strict";

define ["DisplayObject"], (DisplayObject) ->

	# 
	# Класс для вывода текстовой информации
	# 
	# свойства:
	# 
	#  fontHeight: int - высота текста с текущим шрифтом
	#  textWidth: int - ширина текущего текста
	#  font: String - текущий шрифт
	#  fillStyle: String/Array/Boolean - текущая заливка, градиент или false, если заливка не нужна
	#  strokeStyle: String/Boolean - обводка шрифта или false, если обводка не нужна
	#  strokeWidth: int - ширина обводки
	#  text: String - отображаемый текст
	#  
	# методы:
	# 
	#  setFont()
	#  setFillStyle()
	#  setStrokeStyle()
	#  setStrokeWidth()
	#  setText()
	#  animate() - попытка нарисовать объект
	# 
	class Text extends DisplayObject

		constructor: (options) ->

			super options

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

			_font = _fillStyle = _strokeStyle = _strokeWidth = _text = ""

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
			# текущий текст надписи
			# 
			@setText options.text

		setFont: (value) ->

			@font = value or "12px Arial"

			# 
			# устанавливаем реальную высоту шрифта в пикселях
			# 
			span = document.createElement "span"
			span.appendChild document.createTextNode("height")
			span.style.cssText = "font: " + @font + "; white-space: nowrap; display: inline;"
			document.body.appendChild span
			@fontHeight = span.offsetHeight
			document.body.removeChild span

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

			@strokeWidth = @int(value) or 1
			@needAnimation = true
			@strokeWidth

		setText: (value) ->

			@text = value or ""

			# 
			# определяем ширину текста
			# используя для этого ссылку на контекст
			# 
			@context.save()
			@context.font = @font
			@textWidth = @context.measureText(@text).width
			@context.restore()

			@needAnimation = true
			@text

		animate: () ->

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
				# выводим залитый текст
				# 
				@context.fillText @text, @_deltaX, @_deltaY

			# 
			# что насчет обводки?
			# 
			if @strokeStyle

				@context.strokeStyle = @strokeStyle
				@context.lineWidth = @strokeWidth
				@context.strokeText @text, @_deltaX, @_deltaY

			@context.restore()

			@needAnimation = false