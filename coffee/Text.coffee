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

			# 
			# шрифт надписи, строка
			# 
			@setFont options.font

			# 
			# текущая заливка, градиент или false, если заливка не нужна
			# 
			@fillStyle = options.fillStyle or false

			# 
			# обводка шрифта или false, если обводка не нужна
			# 
			@strokeStyle = options.strokeStyle or false

			# 
			# ширина обводки
			# 
			@strokeWidth = if options.strokeWidth? then @int options.strokeWidth else 1

			# 
			# текущий текст надписи
			# 
			@write options.text

		setFont: (value) ->

			font = value or "12px Arial"
			return if font == @font
			@font = font

			# 
			# устанавливаем реальную высоту шрифта в пикселях
			# 
			span = document.createElement "span"
			span.appendChild document.createTextNode("height")
			span.style.cssText = "font: " + @font + "; white-space: nowrap; display: inline;"
			document.body.appendChild span
			@fontHeight = span.offsetHeight
			document.body.removeChild span

			@parent.needAnimation = true
			@font

		setFillStyle: (value) ->

			fillStyle = value or false
			return if fillStyle == @fillStyle
			@fillStyle = fillStyle
			@parent.needAnimation = true
			@fillStyle

		setStrokeStyle: (value) ->

			strokeStyle = value or false
			return if strokeStyle == @strokeStyle
			@strokeStyle = strokeStyle
			@parent.needAnimation = true
			@strokeStyle

		setStrokeWidth: (value) ->

			strokeWidth = if value? then @int value else 1
			return if strokeWidth == @strokeWidth
			@strokeWidth = strokeWidth
			@parent.needAnimation = true
			@strokeWidth

		write: (value) ->

			text = value or ""
			return if text == @text
			@text = text

			# 
			# определяем ширину текста
			# используя для этого ссылку на контекст
			# 
			context = @parent.context
			context.save()
			context.font = @font
			@textWidth = context.measureText(@text).width
			context.restore()

			@parent.needAnimation = true
			@text

		animate: (context) ->

			super context

			# 
			# установим шрифт контекста
			# 
			context.font = @font

			# 
			# по умолчанию позиционируем текст по верхнему краю
			# 
			context.textBaseline = "top"
			
			# 
			# нужна ли заливка
			# 
			if @fillStyle

				# а может зальем текст градиентом?
				if Array.isArray @fillStyle

					# 
					# создаем градиент по нужным точкам
					# 
					gradient = context.createLinearGradient @_deltaX, @_deltaY, @_deltaX, @_deltaY + @fontHeight

					# 
					# добавляем цвета
					# 
					@fillStyle.forEach (color) ->
						
						# сначала размер, потом цвет
						gradient.addColorStop color[0], color[1]

					# 
					# заливка градиентом
					# 
					context.fillStyle = gradient

				# 
				# ну или просто цветом
				# 
				else context.fillStyle = @fillStyle

				# 
				# выводим залитый текст
				# 
				context.fillText @text, @_deltaX, @_deltaY

			# 
			# что насчет обводки?
			# 
			if @strokeStyle

				context.strokeStyle = @strokeStyle
				context.lineWidth = @strokeWidth
				context.strokeText @text, @_deltaX, @_deltaY