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
    //  baseline:String - метод вывода текста, может быть top, middle, bottom
    //  fillStyle:String/Array/Boolean - текущая заливка, градиент или false, если заливка не нужна
    //  strokeStyle:String/Boolean - обводка шрифта или false, если обводка не нужна
    //  strokeWidth:int - ширина обводки
    //  underline:Boolean - подчеркнутый текст
    //  underlineOffset:int - смещение линии подчеркивания
    //  text:String - отображаемый текст

    // методы:

    //  setFont(font:String):String - установка шрифта
    //  setBaseline(baseline:String):String - метод вывода текста
    //  setFillStyle(style:String/Array):String/Array - установка заливки текста
    //  setStrokeStyle(style:String):String - установка обводки
    //  setStrokeWidth(value:int):int - толщина обводки
    //  setUnderline(value:Boolean, offset:int):Boolean - установка подчеркивания текста
    //  write(text:String):String - установка текста
    //  animate() - попытка нарисовать объект

    return Text = class Text extends DisplayObject {
      constructor(options) {
        super(options);
        
        // тип объекта

        this.type = "text";
        
        // высота текста с текущим шрифтом,
        // вычисляется автоматичекски при установке шрифта

        this.fontHeight = 0;
        
        // ширина текущего текста
        // вычисляется автоматически при установке текста

        this.textWidth = 0;
        
        // текущая заливка, градиент или false, если заливка не нужна

        this.setFillStyle(options.fillStyle);
        
        // обводка шрифта или false, если обводка не нужна

        this.setStrokeStyle(options.strokeStyle);
        
        // шрифт надписи, строка

        this.setFont(options.font);
        
        // тип вывода текста, может быть top, middle, bottom

        this.setBaseline(options.baseline);
        
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

      setBaseline(value) {
        if ((value !== "top") && (value !== "middle") && (value !== "bottom")) {
          value = "top";
        }
        this.baseline = value;
        this.needAnimation = true;
        return this.baseline;
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
        this.underlineOffset = offset || this._rect0.bottom;
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
        // и обратной совместимости

        this.textWidth = this.realSize[0];
        this.textHeight = this.realSize[1];
        this.needAnimation = true;
        return this.text;
      }

      animate() {
        var isGradient, lines, textY, underlineStyle;
        
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
        isGradient = Array.isArray(this.fillStyle);
        if (this.fillStyle && !isGradient) {
          
          // нужна ли заливка

          this.context.fillStyle = this.fillStyle;
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
          
          // стиль линии подчеркивания

          underlineStyle = this.strokeStyle || this.fillStyle;
        }
        
        // выводим текст построчно

        return lines.forEach((line) => {
          var dy, gradient, lineWidth;
          
          // а может зальем текст градиентом?

          if (isGradient) {
            
            // создаем градиент по нужным точкам

            gradient = this.context.createLinearGradient(this._deltaX, textY, this._deltaX, textY + this.fontHeight);
            
            // добавляем цвета

            this.fillStyle.forEach(function(color) {
              
              // сначала размер, потом цвет
              return gradient.addColorStop(color[0], color[1]);
            });
            
            // заливка градиентом

            this.context.fillStyle = gradient;
          }
          
          // смещение текста

          switch (this.baseline) {
            case "top":
              dy = -this._rect0.top;
              break;
            case "middle":
              dy = -this._rect0.top - Math.round(this._rect0.height / 2);
              break;
            case "bottom":
              dy = -this._rect0.top - this._rect0.height;
          }
          if (this.fillStyle) {
            
            // вывод текста

            this.context.fillText(line, this._deltaX, textY + dy);
          }
          if (this.strokeStyle) {
            this.context.strokeText(line, this._deltaX, textY + dy);
          }
          
          // рисуем подчеркивание

          if (this.underline) {
            
            // длина данной строки текста

            lineWidth = this._getTextWidth(line);
            
            // стиль линии

            this.context.strokeStyle = underlineStyle;
            this.context.lineWidth = this.strokeWidth || 1;
            
            // смещение линии

            switch (this.baseline) {
              case "top":
                dy = this._rect0.height;
                break;
              case "middle":
                dy = Math.round(this._rect0.height / 2);
                break;
              case "bottom":
                dy = 0;
            }
            
            // линия

            this.context.beginPath();
            this.context.moveTo(this._deltaX, textY + dy + this.underlineOffset);
            this.context.lineTo(this._deltaX + lineWidth, textY + dy + this.underlineOffset);
            this.context.stroke();
          }
          
          // смещение следующей строки

          return textY += this._rect0.fontHeight;
        });
      }

      
      // устанавливаем реальную высоту шрифта в пикселях

      _getFontHeight(font) {
        var bottomPoint, canvas, context, dy, flag, fontHeight, halfWidth, imageData, pixelData, span, topPoint, width0;
        this._rect0 = {};
        
        // рассчитываем значение размера шрифта так, как его видит браузер

        span = document.createElement("span");
        span.appendChild(document.createTextNode("height"));
        span.style.cssText = "font: " + font + "; white-space: nowrap; display: inline;";
        document.body.appendChild(span);
        fontHeight = span.offsetHeight;
        document.body.removeChild(span);
        this._rect0.fontHeight = fontHeight;
        
        // рассчитываем размеры шрифта попиксельно

        canvas = document.createElement("canvas");
        width0 = this._getTextWidth("0");
        canvas.width = width0;
        canvas.height = fontHeight;
        context = canvas.getContext("2d");
        context.textBaseline = "top";
        context.font = font;
        context.fillStyle = "#000";
        context.fillText("0", 0, 0);
        if (this.strokeStyle) {
          context.strokeStyle = "#000";
          context.lineWidth = this.strokeWidth;
          context.strokeText("0", 0, 0);
        }
        topPoint = -1;
        bottomPoint = fontHeight + 1;
        flag = true;
        halfWidth = Math.round(width0 / 2);
        
        // верхняя точка

        while (flag) {
          topPoint++;
          imageData = context.getImageData(halfWidth, topPoint, 1, 1);
          pixelData = imageData.data;
          flag = pixelData.every(function(value) {
            return value === 0;
          });
        }
        
        // нижняя точка

        flag = true;
        while (flag) {
          bottomPoint--;
          imageData = context.getImageData(halfWidth, bottomPoint, 1, 1);
          pixelData = imageData.data;
          flag = pixelData.every(function(value) {
            return value === 0;
          });
        }
        
        // затираем

        context = null;
        canvas = null;
        dy = this.strokeStyle ? this.strokeWidth || 1 : 0;
        console.log(dy);
        this._rect0.top = topPoint - dy;
        this._rect0.bottom = this._rect0.fontHeight - bottomPoint + 2 * dy;
        this._rect0.height = bottomPoint - topPoint + 1;
        return this._rect0.height;
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

        return [maxWidth, lines.length * this._rect0.height + (lines.length - 1) * (this._rect0.top + this._rect0.bottom)];
      }

      
      // возвращаем объект с текущими опциями фигуры

      getOptions() {
        var options;
        
        // базовое

        options = super.getOptions();
        
        // опции текста

        options.fontHeight = this.fontHeight;
        options.textWidth = this.textWidth;
        options.textHeight = this.textHeight;
        options.font = this.font;
        options.fillStyle = this.fillStyle;
        options.strokeStyle = this.strokeStyle;
        options.strokeWidth = this.strokeWidth;
        options.underline = this.underline;
        options.underlineOffset = this.underlineOffset;
        options.text = this.text;
        
        // результат возвращаем

        return options;
      }

    };
  });

}).call(this);
