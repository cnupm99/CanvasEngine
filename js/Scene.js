// Generated by CoffeeScript 2.0.2
(function() {
  "use strict";
  define(["ContainerObject", "Image", "Text", "Graph", "TilingImage"], function(ContainerObject, Image, Text, Graph, TilingImage) {
    var Scene;
    return Scene = class Scene extends ContainerObject {
      
      // Класс сцены, на который добавляются все дочерние объекты
      // Фактически представляет собой canvas

      // свойства:

      //  canvas:Element - canvas для рисования, создается автоматически
      //  context:context2d - контекст для рисования, создается автоматически
      //  zIndex:int - индекс, определяющий порядок сцен, чем выше индекс, тем выше сцена над остальными
      //  mask:Array - маска объекта
      //  needAnimation:Boolean - нужно ли анимировать данный объект с точки зрения движка

      // методы:

      //  add(data:Object):DisplayObject - добавление дочернего объекта
      //  clone(anotherObject:DisplayObject):DisplayObject - клонирование графического объекта
      //  clear() - полная очистка сцены
      //  animate() - попытка нарисовать объект

      // установка свойств:

      //  setMask(value:Object):Object - установка маски
      //  setZIndex(value:int):int - установка зед индекса канваса
      //  hide() - скрыть сцену
      //  move(value1, value2:int):Array - изменить позицию канваса
      //  shiftAll(value1, value2:int) - сдвигаем все дочерные объекты
      //  resize(value1, value2:int):Array - изменить размер канваса
      //  setCenter(value1, value2:int):Array - установить новый центр канваса
      //  setAnchor(value1, value2:int):Array - установить якорь канваса
      //  rotate(value:int):int - установить угол поворота канваса
      //  setAlpha(value:Number):Number - установить прозрачность канваса

      constructor(options) {
        
        // создаем DisplayObject

        super(options);
        
        // тип объекта

        this.type = "scene";
        
        // индекс, определяющий порядок сцен, чем выше индекс, тем выше сцена над остальными
        // целое число >= 0

        this.setZIndex(options.zIndex);
        
        // прямоугольная маска, применимо к Scene
        // если маска дейтсвует, то на сцене будет отображаться только объекты внутри маски
        // массив [int, int, int, int] или false

        // ВНИМАНИЕ!
        // В браузере firefox есть баг (на 25.04.17), а именно:
        // при попытке нарисовать на канве изображение, используя одновременно
        // маску и тень (mask и shadow в данном случае), получается
        // странная хрень, а точнее маска НЕ работает в данном случае
        // Доказательство и пример здесь: http://codepen.io/cnupm99/pen/wdGKBO

        this.setMask(options.mask);
        
        // нужно ли анимировать данный объект с точки зрения движка
        // не нужно в ручную менять это свойство, для этого есть visible

        this.needAnimation = false;
      }

      
      // создание и добавление дочерних объектов в список анимации

      add(options) {
        var result;
        
        // нет типа - нечего создавать

        if (options.type == null) {
          return;
        }
        if (options.visible == null) {
          
          // если нужно, задаем значения по умолчанию

          options.visible = this.visible;
        }
        if (options.shadow == null) {
          options.shadow = this.shadow;
        }
        
        // передаем канвас и контекст для рисования

        options.canvas = this.canvas;
        options.context = this.context;
        
        // создание объекта

        switch (options.type) {
          case "image":
            result = new Image(options);
            break;
          case "text":
            result = new Text(options);
            break;
          case "graph":
            result = new Graph(options);
            break;
          case "tile":
            result = new TilingImage(options);
        }
        
        // добавляем в список дочерних объектов

        this.childrens.push(result);
        
        // возвращаем результат

        return result;
      }

      
      // клонирование графического объекта

      clone(anotherObject) {
        return this.add(anotherObject.getOptions());
      }

      
      // очистка сцены

      clear() {
        
        // удаляем все дочерние элементы

        this.childrens = [];
        
        // перерисовка

        return this.needAnimation = true;
      }

      
      // Установка прямоугольной маски для рисования

      setMask(value) {
        if ((value == null) || (!value)) {
          this.mask = false;
        } else {
          this.mask = value;
        }
        this.needAnimation = true;
        return this.mask;
      }

      
      // Установка zIndex

      setZIndex(value) {
        this.zIndex = this.int(value);
        this.canvas.style.zIndex = this.zIndex;
        return this.zIndex;
      }

      
      // Далее функции, перегружающие свойсва экранного объекта,
      // т.к. нам нужно в этом случае двигать, поворачивать и т.д. сам канвас

      hide() {
        super.hide();
        return this.context.clearRect(0, 0, this.size[0], this.size[1]);
      }

      move(value1, value2) {
        super.move(value1, value2);
        
        // двигаем канвас по экрану

        this.canvas.style.left = this.position[0] + "px";
        this.canvas.style.top = this.position[1] + "px";
        return this.position;
      }

      
      // сдвигаем все дочерние объекты

      shiftAll(value1, value2 = 0) {
        return this.childrens.forEach(function(child) {
          return child.shift(value1, value2);
        });
      }

      resize(value1, value2) {
        super.resize(value1, value2);
        
        // меняем размер канваса

        this.canvas.width = this.size[0];
        this.canvas.height = this.size[1];
        return this.size;
      }

      setCenter(value1, value2) {
        super.setCenter(value1, value2);
        
        // сдвигаем начало координат в центр

        this.context.translate(this.center[0], this.center[1]);
        return this.center;
      }

      setAnchor(value1, value2) {
        super.setAnchor(value1, value2);
        
        // сдвигаем начало координат в центр

        this.context.translate(this.center[0], this.center[1]);
        return this.anchor;
      }

      rotate(value) {
        super.rotate(value);
        
        // поворот всего контекста на угол

        this.context.rotate(this._rotation);
        return this.rotation;
      }

      setAlpha(value) {
        super.setAlpha(value);
        this.context.globalAlpha = this.alpha;
        return this.alpha;
      }

      
      // анимация сцены

      animate() {
        
        // если объект не видимый
        // то рисовать его не нужно

        if (!this.visible) {
          this.needAnimation = false;
          return;
        }
        
        // очистка контекста

        this.context.clearRect(0, 0, this.size[0], this.size[1]);
        
        // установка маски

        if (this.mask) {
          this.context.beginPath();
          this.context.rect(this.mask[0], this.mask[1], this.mask[2], this.mask[3]);
          this.context.clip();
        }
        
        // анимация в буфер

        this.childrens.forEach((child) => {
          this.context.save();
          child.animate();
          return this.context.restore();
        });
        
        // анимация больше не нужна

        return this.needAnimation = false;
      }

    };
  });

}).call(this);
