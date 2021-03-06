// Generated by CoffeeScript 2.0.2
(function() {
  "use strict";
  define(["AbstractObject"], function(AbstractObject) {
    var DisplayObject;
    
    // Абстрактный объект, отображаемый на экране,
    // имеющий для этого все необходимые свойства и методы

    return DisplayObject = class DisplayObject extends AbstractObject {
      
      // свойсва:

      //  name:String - имя объекта для его идентификации
      //  type:String - тип объекта
      //  canvas:Canvas - канвас для рисования
      //  context:Context2d - контекст для рисования

      //  visible:Boolean - видимость объекта, устанавливаемая пользователем
      //  position:Array - позиция объекта
      //  size:Array - размер объекта
      //  realSize:Array - реальный размер объкта
      //  center:Array - относительные координаты точки центра объекта, вокруг которой происходит вращение
      //  anchor:Array - дробное число, показывающее, где должен находиться центр относительно размеров объекта
      //  scale:Array - коэффициенты для масштабирования объектов
      //  rotation:int - число в градусах, на которое объект повернут вокруг центра по часовой стрелке
      //  alpha:Number - прозрачность объекта
      //  shadow:Object - тень объекта

      //  needAnimation: Boolean - сообщает движку, нужно ли анимировать объект

      // методы:

      //  set(value:Object) - установка сразу нескольких свойств
      //  show():Boolean - 
      //  hide():Boolean - 
      //  move(value1, value2:int):Array - изменить позицию объекта
      //  shift(deltaX, deltaY:int):Array - сдвигаем объект на нужное смещение по осям
      //  resize(value1, value2:int):Array - изменить размер объекта
      //  upsize(value1, value2:int):Array - обновить реальные размеры объекта
      //  setCenter(value1, value2: int):Array - установить новый центр объекта
      //  setAnchor(value1, value2: Number):Array - установить новый якорь объекта
      //  zoom(value1, value2:Number):Array - установить масштаб объекта
      //  rotate(value:int):int - установить угол поворота объекта
      //  rotateOn(value:int):int - повернуть объект на угол относительно текщего
      //  setAlpha(value:Number):Number - установить прозрачность объекта
      //  setShadow(value:Object): Object - установить тень объекта

      //  testPoint(pointX, pointY:int):Boolean - проверка, пуста ли данная точка
      //  testRect(pointX, pointY:int):Boolean - проверка, входит ли точка в прямоугольник объекта
      //  animate() - попытка нарисовать объект

      //  getOptions() - возвращаем объект с текущими опциями фигуры

      constructor(options) {
        var stage;
        
        // конструктор базового класса

        super(options);
        
        // имя, задается пользователем, либо пустая строка
        // используется для поиска по имени

        this.name = options.name || "";
        
        // тип объекта, каждый класс пусть присваивает самостоятельно

        this.type = "DisplayObject";
        
        // канвас для рисования
        // в случае сцены, создается новый канвас
        // в остальных случаях получаем из опций от родителя (сцены)
        // свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ

        if (options.canvas != null) {
          this.canvas = options.canvas;
        } else {
          
          // элемент для добавления канваса
          // всегда должен быть
          // свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ

          stage = options.parent || document.body;
          
          // создаем канвас
          // свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ

          this.canvas = document.createElement("canvas");
          this.canvas.style.position = "absolute";
          stage.appendChild(this.canvas);
        }
        
        // контекст для рисования
        // в случае сцены, берется из канваса,
        // в остальных случаях получаем из опций от родителя (сцены)
        // свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ

        this.context = options.context || this.canvas.getContext("2d");
        
        // установка свойств

        this._setProperties(options);
      }

      
      // Установка всех или определенных свойств через объект опций

      set(options) {
        if (options == null) {
          return;
        }
        if (options.visible != null) {
          this.visible = options.visible;
        }
        if (this.visible) {
          this.show();
        } else {
          this.hide();
        }
        if (options.position != null) {
          this.move(options.position);
        }
        if (options.size != null) {
          this.resize(options.size);
        }
        if (options.realSize != null) {
          this.upsize(options.realSize);
        }
        if (options.center != null) {
          this.setCenter(options.center);
        }
        if (options.anchor != null) {
          this.setAnchor(options.anchor);
        }
        if (options.scale != null) {
          this.zoom(options.scale);
        }
        if (options.rotation != null) {
          this.rotate(options.rotation);
        }
        if (options.alpha != null) {
          this.setAlpha(options.alpha);
        }
        if (options.shadow != null) {
          this.setShadow(options.shadow);
        }
        return this.needAnimation = true;
      }

      
      // показать объект

      show() {
        this.visible = true;
        this.needAnimation = true;
        return true;
      }

      
      // скрыть объект

      hide() {
        this.visible = false;
        this.needAnimation = true;
        return false;
      }

      
      // изменить позицию объекта

      move(value1, value2) {
        this.position = this.pixel(value1, value2);
        this.needAnimation = true;
        return this.position;
      }

      
      // сдвигаем объект на нужную величину по осям

      shift(value1, value2 = 0) {
        return this.move([value1 + this.position[0], value2 + this.position[1]]);
      }

      
      // изменить размер объекта

      resize(value1, value2) {
        this.size = this.pixel(value1, value2);
        this.setAnchor(this.anchor);
        this.needAnimation = true;
        return this.size;
      }

      
      // обновить реальные размеры объекта

      upsize(value1, value2) {
        this.realSize = this.pixel(value1, value2);
        this.setAnchor(this.anchor);
        return this.realSize;
      }

      
      // установить новый центр объекта

      setCenter(value1, value2) {
        var anchorX, anchorY, size;
        this.center = this.pixel(value1, value2);
        size = this.size[0] === 0 && this.size[1] === 0 ? this.realSize : this.size;
        anchorX = size[0] === 0 ? 0 : this.center[0] / size[0];
        anchorY = size[1] === 0 ? 0 : this.center[1] / size[1];
        this.anchor = [anchorX, anchorY];
        this.needAnimation = true;
        return this.center;
      }

      
      // установить новый якорь объекта

      setAnchor(value1, value2) {
        var size;
        this.anchor = this.point(value1, value2);
        size = this.size[0] === 0 && this.size[1] === 0 ? this.realSize : this.size;
        this.center = [this.int(size[0] * this.anchor[0]), this.int(size[1] * this.anchor[1])];
        this.needAnimation = true;
        return this.anchor;
      }

      
      // установить масштаб объекта

      zoom(value1, value2) {
        this.scale = value1 != null ? this.point(value1, value2) : [1, 1];
        this.needAnimation = true;
        return this.scale;
      }

      
      // установить угол поворота объекта

      rotate(value) {
        this.rotation = this.int(value);
        if (this.rotation < 0) {
          this.rotation = 360 + this.rotation;
        }
        if (this.rotation >= 360) {
          this.rotation = this.rotation % 360;
        }
        this._rotation = this.rotation * this._PIDIV180;
        this.needAnimation = true;
        return this.rotation;
      }

      
      // повернуть объект на угол относительно текщего

      rotateOn(value) {
        return this.rotate(this.rotation + this.int(value));
      }

      
      // установить прозрачность объекта

      setAlpha(value) {
        this.alpha = value ? this.number(value) : 1;
        if (this.alpha < 0) {
          this.alpha = 0;
        }
        if (this.alpha > 1) {
          this.alpha = 1;
        }
        this.needAnimation = true;
        return this.alpha;
      }

      
      // установить тень объекта

      setShadow(value) {
        if ((value == null) || (!value)) {
          this.shadow = false;
        } else {
          this.shadow = {
            
            // не проверяем значения color и blur, потому что по умолчанию они отличны от 0

            color: value.color || "#000",
            blur: value.blur || 3,
            offsetX: this.int(value.offsetX),
            offsetY: this.int(value.offsetY),
            offset: this.int(value.offset)
          };
        }
        this.needAnimation = true;
        return this.shadow;
      }

      
      // проверяем, пуста ли точка с данными координатами

      // ВНИМАНИЕ!
      // использовать этот метод ЛОКАЛЬНО нужно осторожно, так как
      // в браузерах на основе chrome будет возникать ошибка безопасности
      // (как будто пытаешься загрузить изображение с другого хоста).
      // При загрузке кода на сервер работает во всех браузерах.

      testPoint(pointX, pointY) {
        var imageData, offsetX, offsetY, pixelData, rect;
        
        // получаем координаты канваса в окне

        rect = this.canvas.getBoundingClientRect();
        // получаем координаты точки на канвасе, относительно самого канваса
        // т.е. без учета родителей,
        // считая началом координат левый верхний угол канваса
        offsetX = pointX - rect.left;
        offsetY = pointY - rect.top;
        // данные пикселя
        imageData = this.context.getImageData(offsetX, offsetY, 1, 1);
        // цвет пикселя
        pixelData = imageData.data;
        if (pixelData.every == null) {
          // проверяем нужный метод?
          pixelData.every = Array.prototype.every;
        }
        // проверяем все цвета, если 0, значит мимо
        return !pixelData.every(function(value) {
          return value === 0;
        });
      }

      
      // находится ли точка внутри объекта по его позиции / размерам

      testRect(pointX, pointY) {
        var rect;
        rect = this.canvas.getBoundingClientRect();
        
        // если это НЕ сцена

        if (this.type !== "scene") {
          
          // корректируем позицией и размерами объекта

          rect = {
            left: rect.left + this.position[0],
            top: rect.top + this.position[1],
            right: rect.left + this.position[0] + this.size[0],
            bottom: rect.top + this.position[1] + this.size[1]
          };
        }
        
        // собственно сравнение координат

        return (pointX >= rect.left) && (pointX <= rect.right) && (pointY >= rect.top) && (pointY <= rect.bottom);
      }

      
      // анимация объекта, запускается автоматически,
      // делать вручную это не нужно

      animate() {
        // смещение
        this._deltaX = this.position[0];
        this._deltaY = this.position[1];
        // установка тени
        if (this.shadow) {
          this.context.shadowColor = this.shadow.color;
          this.context.shadowBlur = this.shadow.blur;
          this.context.shadowOffsetX = Math.max(this.shadow.offsetX, this.shadow.offset);
          this.context.shadowOffsetY = Math.max(this.shadow.offsetY, this.shadow.offset);
        }
        if (this.scale[0] !== 1 || this.scale[1] !== 1) {
          this.context.scale(this.scale[0], this.scale[1]);
        }
        if (this.alpha !== 1) {
          this.context.globalAlpha = this.alpha;
        }
        // смещение и поворот холста
        if (this.rotation !== 0) {
          this.context.translate(this.center[0] + this.position[0], this.center[1] + this.position[1]);
          this.context.rotate(this._rotation);
          this._deltaX = -this.center[0];
          this._deltaY = -this.center[1];
        }
        
        // анимация больше не нужна

        return this.needAnimation = false;
      }

      
      // Создание и установка свойств объекта

      _setProperties(options) {
        
        // Ниже идут свойтсва объекта

        // видимость объекта, устанавливаемая пользователем
        // true / false

        this.visible = options.visible != null ? options.visible : true;
        if (this.visible) {
          this.show();
        } else {
          this.hide();
        }
        
        // позиция объекта
        // массив вида [x, y]

        this.move(options.position);
        
        // реальный размер объекта,
        // может отличаться от заданного пользователем, например
        // в случае загрузки картинки

        // пока не рассчитан программно, считается равным [0, 0]

        // массив вида [width, height]

        this.realSize = [0, 0];
        
        // размер объекта
        // массив вида [width, height]

        this.resize(options.size);
        if ((options.center != null) || (options.anchor == null)) {
          
          // координаты точки, являющейся центром объекта,
          // вокруг этой точки производится вращение объекта
          // координаты точки задаются не относительно начала координат,
          // а относительно левого верхнего угла объекта
          // массив вида [x, y], либо объект вида {x: int, y: int}

          this.setCenter(options.center);
        }
        if ((options.anchor != null) && (options.center == null)) {
          
          // Якорь, дробное число, показывающее, где должен находиться цент относительно размеров объекта,
          // т.е. center = size * anchor
          // массив [number, number]

          this.setAnchor(options.anchor);
        }
        
        // Свойство хранит коэффициенты для масштабирования объектов
        // массив вида [x, y]

        this.zoom(options.scale);
        
        // поворот объекта вокруг точки center по часовой стрелке, измеряется в градусах
        // число

        this.rotate(options.rotation);
        
        // прозрачность объекта
        // число от 0 до 1

        this.setAlpha(options.alpha);
        
        // тень объекта
        // объект вида {color: string, blur: int, offsetX: int, offsetY: int, offset: int} или false
        // не нужно указывать одновременно offsetX, offsetY и offset
        // offset указывается вместо offsetX и offsetY, если offsetX == offsetY

        // ВНИМАНИЕ!
        // В браузере firefox есть баг (на 25.04.17), а именно:
        // при попытке нарисовать на канве изображение, используя одновременно
        // маску и тень (mask и shadow в данном случае), получается
        // странная хрень, а точнее маска НЕ работает в данном случае
        // Доказательство и пример здесь: http://codepen.io/cnupm99/pen/wdGKBO

        this.setShadow(options.shadow);
        
        // считаем, что надо нарисовать объект, если не указано иного

        return this.needAnimation = true;
      }

      
      // возвращаем объект с текущими опциями фигуры

      getOptions() {
        var options;
        return options = {
          name: this.name,
          type: this.type,
          visible: this.visible,
          position: [this.position[0], this.position[1]],
          size: [this.size[0], this.size[1]],
          realSize: [this.realSize[0], this.realSize[1]],
          center: [this.center[0], this.center[1]],
          anchor: [this.anchor[0], this.anchor[1]],
          scale: [this.scale[0], this.scale[1]],
          rotation: this.rotation,
          alpha: this.alpha,
          shadow: this.shadow ? {
            blur: this.shadow.blur,
            color: this.shadow.color,
            offset: this.shadow.offset,
            offsetX: this.shadow.offsetX,
            offsetY: this.shadow.offsetY
          } : false
        };
      }

    };
  });

}).call(this);
