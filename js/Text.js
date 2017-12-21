// Generated by CoffeeScript 2.0.2
(function() {
  "use strict";
  define(["DisplayObject"], function(DisplayObject) {
    var Text;
    
    // Класс для вывода текстовой информации

    // свойства:

    //  fontHeight:int - высота шрифта
    //  textWidth:int - ширина текущего текста
    //  textHeight:int - высота текущего текста
    //  realSize:Array - размеры области текущего текста с учетом шрифта и многострочности
    //  font:String - текущий шрифт
    //  fillStyle:String/Array/Boolean - текущая заливка, градиент или false, если заливка не нужна
    //  strokeStyle:String/Boolean - обводка шрифта или false, если обводка не нужна
    //  strokeWidth:int - ширина обводки
    //  underline:Boolean - подчеркнутый текст
    //  underlineOffset:int - смещение линии подчеркивания
    //  text:String - отображаемый текст

    // методы:

    //  setFont(font:String):String - установка шрифта
    //  setFillStyle(style:String/Array):String/Array - установка заливки текста
    //  setStrokeStyle(style:String):String - установка обводки
    //  setStrokeWidth(value:int):int - толщина обводки
    //  setUnderline(value:Boolean, offset:int):Boolean - установка подчеркивания текста
    //  write(text:String):String - установка текста
    //  animate() - попытка нарисовать объект

    return Text = class Text extends DisplayObject {
      constructor(options) {
        super(options);
        
        // высота текста с текущим шрифтом,
        // вычисляется автоматичекски при установке шрифта

        this.fontHeight = 0;
        
        // ширина текущего текста
        // вычисляется автоматически при установке текста

        this.textWidth = 0;
        
        // шрифт надписи, строка

        this.setFont(options.font);
        
        // текущая заливка, градиент или false, если заливка не нужна

        this.setFillStyle(options.fillStyle);
        
        // обводка шрифта или false, если обводка не нужна

        this.setStrokeStyle(options.strokeStyle);
        
        // ширина обводки

        this.setStrokeWidth(options.strokeWidth);
        
        // установка подчеркнутого текста

        this.setUnderline(options.underline, options.underlineOffset);
        
        // текущий текст надписи

        this.write(options.text);
      }

      setFont(value) {
        
        // установка шрифта

        this.font = value || "12px Arial";
        
        // получаем высоту шрифта

        this.fontHeight = this._getFontHeight(this.font);
        this.needAnimation = true;
        return this.font;
      }

      setFillStyle(value) {
        this.fillStyle = value || false;
        this.needAnimation = true;
        return this.fillStyle;
      }

      setStrokeStyle(value) {
        this.strokeStyle = value || false;
        this.needAnimation = true;
        return this.strokeStyle;
      }

      setStrokeWidth(value) {
        this.strokeWidth = value != null ? this.int(value) : 1;
        this.needAnimation = true;
        return this.strokeWidth;
      }

      setUnderline(value, offset) {
        this.underline = value || false;
        this.underlineOffset = offset || 0;
        this.needAnimation = true;
        return this.underline;
      }

      write(value) {
        
        // установка текста

        this.text = value || "";
        
        // получаем реальные размеры области с текстом
        // с учетом многострочности и установленного шрифта

        this.upsize(this._getRealSizes(this.text));
        
        // вспомогательные свойства, нужны для удобства
        // и обратной совметсимости

        this.textWidth = this.realSize[0];
        this.textHeight = this.realSize[1];
        this.needAnimation = true;
        return this.text;
      }

      animate() {
        var fontSize, gradient, lines, textY, underlineStyle;
        
        // если объект не видимый
        // то рисовать его не нужно

        if (!this.visible) {
          this.needAnimation = false;
          return;
        }
        super.animate();
        
        // установим шрифт контекста

        this.context.font = this.font;
        
        // по умолчанию позиционируем текст по верхнему краю

        this.context.textBaseline = "top";
        
        // нужна ли заливка

        if (this.fillStyle) {
          // а может зальем текст градиентом?
          if (Array.isArray(this.fillStyle)) {
            
            // создаем градиент по нужным точкам

            gradient = this.context.createLinearGradient(this._deltaX, this._deltaY, this._deltaX, this._deltaY + this.fontHeight);
            
            // добавляем цвета

            this.fillStyle.forEach(function(color) {
              
              // сначала размер, потом цвет
              return gradient.addColorStop(color[0], color[1]);
            });
            
            // заливка градиентом

            this.context.fillStyle = gradient;
          } else {
            
            // ну или просто цветом

            this.context.fillStyle = this.fillStyle;
          }
        }
        
        // что насчет обводки?

        if (this.strokeStyle) {
          this.context.strokeStyle = this.strokeStyle;
          this.context.lineWidth = this.strokeWidth;
        }
        
        // разбиваем текст на строки, это нужно для вывода многострочного текста

        lines = this.text.split("\n");
        
        // координата для смещения текста по вертикали

        textY = this._deltaY;
        
        // если нужно подчеркивание текста

        if (this.underline) {
          
          // парсим шрифт в надежде найти размер шрифта
          // используем его для рисования подчеркивание
          // это ближе к истене чем использование fontHeight

          fontSize = parseInt(this.font, 10);
          
          // стиль линии подчеркивания

          underlineStyle = this.strokeStyle || this.fillStyle;
        }
        
        // выводим текст построчно

        return lines.forEach((line) => {
          var lineWidth;
          if (this.fillStyle) {
            
            // вывод текста

            this.context.fillText(line, this._deltaX, textY);
          }
          if (this.strokeStyle) {
            this.context.strokeText(line, this._deltaX, textY);
          }
          
          // рисуем подчеркивание

          if (this.underline) {
            
            // длина данной строки текста

            lineWidth = this._getTextWidth(line);
            
            // стиль линии

            this.context.strokeStyle = underlineStyle;
            this.context.lineWidth = this.strokeWidth || 1;
            
            // линия

            this.context.moveTo(this._deltaX, textY + fontSize + this.underlineOffset);
            this.context.lineTo(this._deltaX + lineWidth, textY + fontSize + this.underlineOffset);
            this.context.stroke();
          }
          
          // смещение следующей строки

          return textY += this.fontHeight;
        });
      }

      
      // устанавливаем реальную высоту шрифта в пикселях

      _getFontHeight(font) {
        var fontHeight, span;
        span = document.createElement("span");
        span.appendChild(document.createTextNode("height"));
        span.style.cssText = "font: " + font + "; white-space: nowrap; display: inline;";
        document.body.appendChild(span);
        fontHeight = span.offsetHeight;
        document.body.removeChild(span);
        return fontHeight;
      }

      
      // определяем ширину текста
      // используя для этого ссылку на контекст

      _getTextWidth(text) {
        var textWidth;
        this.context.save();
        this.context.font = this.font;
        textWidth = this.context.measureText(text).width;
        this.context.restore();
        return textWidth;
      }

      
      // получаем реальные размеры области текста

      _getRealSizes(text) {
        var lines, maxWidth;
        
        // начальное значение максимальной ширины строки

        maxWidth = 0;
        
        // разбиваем текст на строки, это нужно для вывода многострочного текста

        lines = this.text.split("\n");
        
        // проверяем ширину каждой строки,
        // если нужно обновляем максимальное значение

        lines.forEach((line) => {
          var width;
          width = this._getTextWidth(line);
          if (width > maxWidth) {
            return maxWidth = width;
          }
        });
        
        // итоговый результат,
        // максимальная ширина,
        // высота равна количеству строк на высоту одной строки

        return [maxWidth, lines.length * this.fontHeight];
      }

    };
  });

}).call(this);
