// Generated by CoffeeScript 2.0.2
(function() {
  "use strict";
  define(["DisplayObject"], function(DisplayObject) {
    var Graph;
    
    // Класс для рисования графических примитивов

    // методы:

    //  clear() - очистка экрана и команд
    //  beginPath() - начало отрисовки линии
    //  lineCap(value:String) - установить стиль окончания линий
    //  strokeStyle(style:String) - стиль линий
    //  fillStyle(style:String) - стиль заливки
    //  linearGradient(x1, y1, x2, y2:int, colors:Array) - установка градиента
    //  lineWidth(value:int) - толщина линий
    //  setLineDash(value:Array) - установка пунктирной линии
    //  lineDashOffset(value:int) - смещение пунктирной линии
    //  moveTo(x, y:int) - перемещение указателя
    //  lineTo(x, y:int) - линия в указанную точку
    //  line(x1, y1, x2, y2:int) - рисуем линию по двум точкам
    //  rect(x, y, width, height, radius:int) - рисуем прямоугольник (опционально скругленный)
    //  circle(x, y, radius:int) - рисуем круг
    //  arc(x, y, radius:int, beginAngle, endAngle:number, antiClockWise:Boolean) - нарисовать дугу
    //  polyline(points:Array, needDraw:Boolean) - полилиния
    //  polygon(points:Array) - полигон
    //  fill() - заливка фигуры
    //  stroke() - прорисовка контура
    //  animate() - попытка нарисовать объект
    //  log() - выводим массив комманд в консоль

    return Graph = class Graph extends DisplayObject {
      constructor(options) {
        super(options);
        
        // тип объекта

        this.type = "graph";
        // массив команд для рисования
        this._commands = [];
      }

      
      // Далее идут функции для рисования графических примитивов
      // Все они сохраняют свои данные в _commands

      // очистка экрана и команд

      clear() {
        this._commands = [];
        return this.needAnimation = true;
      }

      
      // начало отрисовки линии

      beginPath() {
        return this._commands.push({
          "command": "beginPath"
        });
      }

      
      // установить стиль окончания линий

      lineCap(value) {
        return this._commands.push({
          "command": "lineCap",
          "lineCap": value
        });
      }

      
      // стиль линий

      strokeStyle(style) {
        return this._commands.push({
          "command": "strokeStyle",
          "style": style
        });
      }

      
      // стиль заливки

      fillStyle(style) {
        return this._commands.push({
          "command": "fillStyle",
          "style": style
        });
      }

      
      // устновка градиента
      // colors = Array [ [size, color], .... ], где color:String, size:Number [0..1]

      linearGradient(x1, y1, x2, y2, colors) {
        return this._commands.push({
          "command": "gradient",
          "point1": this.pixel(x1, y1),
          "point2": this.pixel(x2, y2),
          "colors": colors
        });
      }

      
      // толщина линий

      lineWidth(width) {
        return this._commands.push({
          "command": "lineWidth",
          "width": this.int(width)
        });
      }

      
      // установка пунктирной линии

      setLineDash(dash) {
        return this._commands.push({
          "command": "setDash",
          "dash": dash
        });
      }

      
      // смещение пунктирной линии

      lineDashOffset(offset) {
        return this._commands.push({
          "command": "dashOffset",
          "offset": this.int(offset)
        });
      }

      
      // Перевод указателя в точку

      moveTo(toX, toY) {
        return this._commands.push({
          "command": "moveTo",
          "point": this.pixel(toX, toY)
        });
      }

      
      // Линия из текущей точки в указанную

      lineTo(toX, toY) {
        this._commands.push({
          "command": "lineTo",
          "point": this.pixel(toX, toY)
        });
        return this.needAnimation = true;
      }

      
      // рисуем линию, соединяющую две точки,
      // разница между moveTo + lineTo еще и в том, что line рисует линию,
      // т.е. автоматически делает stroke()

      line(fromX, fromY, toX, toY) {
        this._commands.push({
          "command": "line",
          "from": this.pixel(fromX, fromY),
          "to": this.pixel(toX, toY)
        });
        return this.needAnimation = true;
      }

      
      // рисуем прямоугольник, если указан radius, то скругляем углы

      rect(fromX, fromY, width, height, radius = 0) {
        this._commands.push({
          "command": "rect",
          "point": this.pixel(fromX, fromY),
          "size": this.pixel(width, height),
          "radius": this.int(radius)
        });
        return this.needAnimation = true;
      }

      
      // рисуем круг

      circle(centerX, centerY, radius) {
        this._commands.push({
          "command": "circle",
          "center": this.pixel(centerX, centerY),
          "radius": this.int(radius)
        });
        return this.needAnimation = true;
      }

      
      // рисуем дугу

      arc(centerX, centerY, radius, beginAngle, endAngle, antiClockWise) {
        this._commands.push({
          "command": "arc",
          "center": this.pixel(centerX, centerY),
          "radius": this.int(radius),
          "beginAngle": this.deg2rad(beginAngle),
          "endAngle": this.deg2rad(endAngle),
          "antiClockWise": antiClockWise || false
        });
        return this.needAnimation = true;
      }

      
      // линия из множества точек
      // второй параметр говорит, нужно ли ее рисовать,
      // он нужен, чтобы рисовать многоугольники без границы

      polyline(points, stroke = true) {
        this._commands.push({
          "command": "beginPath"
        });
        this.moveTo(points[0][0], points[0][1]);
        points.forEach((point) => {
          return this.lineTo(point[0], point[1]);
        });
        if (stroke) {
          this.stroke();
        }
        return this.needAnimation = true;
      }

      
      // полигон

      polygon(points) {
        this.polyline(points, false);
        this.lineTo(points[0][0], points[0][1]);
        this.stroke();
        return this.fill();
      }

      
      // Заливка

      fill() {
        this._commands.push({
          "command": "fill"
        });
        return this.needAnimation = true;
      }

      
      // Рисуем контур

      stroke() {
        this._commands.push({
          "command": "stroke"
        });
        return this.needAnimation = true;
      }

      animate() {
        
        // если объект не видимый
        // то рисовать его не нужно

        if (!this.visible) {
          this.needAnimation = false;
          return;
        }
        super.animate();
        
        // установим закругленные окончания линий

        this.context.lineCap = "round";
        
        // перебираем все команды в массиве команд и выполняем соответствующие действия
        // можно было поменять строковые команды на числа вида 0, 1, 2 .... и т.д.,
        // но зачем?

        return this._commands.forEach((command) => {
          var gradient;
          switch (command.command) {
            case "beginPath":
              return this.context.beginPath();
            case "lineCap":
              return this.context.lineCap = command.lineCap;
            case "stroke":
              return this.context.stroke();
            case "fill":
              return this.context.fill();
            case "setDash":
              return this.context.setLineDash(command.dash);
            case "dashOffset":
              return this.context.lineDashOffset = command.offset;
            case "moveTo":
              return this.context.moveTo(command.point[0] + this._deltaX, command.point[1] + this._deltaY);
            case "lineTo":
              return this.context.lineTo(command.point[0] + this._deltaX, command.point[1] + this._deltaY);
            case "line":
              this.context.beginPath();
              this.context.moveTo(command.from[0] + this._deltaX, command.from[1] + this._deltaY);
              this.context.lineTo(command.to[0] + this._deltaX, command.to[1] + this._deltaY);
              return this.context.stroke();
            case "strokeStyle":
              return this.context.strokeStyle = command.style;
            case "fillStyle":
              return this.context.fillStyle = command.style;
            case "lineWidth":
              return this.context.lineWidth = command.width;
            case "rect":
              this.context.beginPath();
              
              // обычный прямоугольник
              if (command.radius === 0) {
                return this.context.rect(command.point[0] + this._deltaX, command.point[1] + this._deltaY, command.size[0], command.size[1]);
              } else {
                // прямоугольник со скругленными углами
                return this._drawRoundedRect(this.context, command.point[0] + this._deltaX, command.point[1] + this._deltaY, command.size[0], command.size[1], command.radius);
              }
              break;
            case "circle":
              this.context.beginPath();
              return this.context.arc(command.center[0] + this._deltaX, command.center[1] + this._deltaY, command.radius, 0, 2 * Math.PI, false);
            case "arc":
              this.context.beginPath();
              return this.context.arc(command.center[0] + this._deltaX, command.center[1] + this._deltaY, command.radius, command.beginAngle, command.endAngle, command.antiClockWise);
            case "gradient":
              // создаем градиент по нужным точкам
              gradient = this.context.createLinearGradient(command.point1[0] + this._deltaX, command.point1[1] + this._deltaY, command.point2[0] + this._deltaX, command.point2[1] + this._deltaY);
              // добавляем цвета
              command.colors.forEach(function(color) {
                // сначала размер, потом цвет
                return gradient.addColorStop(color[0], color[1]);
              });
              // заливка градиентом
              return this.context.fillStyle = gradient;
          }
        });
      }

      
      // В информационных целях
      // выводим массив комманд в консоль

      log() {
        return console.log(this._commands);
      }

      
      // рисуем пряоугольник со скругленными углами

      _drawRoundedRect(context, x, y, width, height, radius) {
        var halfpi, pi, x1, x2, y1, y2;
        // предварительные вычисления
        pi = Math.PI;
        halfpi = pi / 2;
        x1 = x + radius;
        x2 = x + width - radius;
        y1 = y + radius;
        y2 = y + height - radius;
        // рисуем
        context.moveTo(x1, y);
        context.lineTo(x2, y);
        context.arc(x2, y1, radius, -halfpi, 0);
        context.lineTo(x + width, y2);
        context.arc(x2, y2, radius, 0, halfpi);
        context.lineTo(x1, y + height);
        context.arc(x1, y2, radius, halfpi, pi);
        context.lineTo(x, y1);
        return context.arc(x1, y1, radius, pi, 3 * halfpi);
      }

    };
  });

}).call(this);
