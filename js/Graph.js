// Generated by CoffeeScript 1.10.0
(function() {
  "use strict";
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(["DisplayObject"], function(DisplayObject) {
    var Graph;
    return Graph = (function(superClass) {
      extend(Graph, superClass);

      function Graph(options) {
        Graph.__super__.constructor.call(this, options);
        this._commands = [];
      }

      Graph.prototype.clear = function() {
        this._commands = [];
        return this.needAnimation = true;
      };

      Graph.prototype.beginPath = function() {
        return this._commands.push({
          "command": "beginPath"
        });
      };

      Graph.prototype.lineCap = function(value) {
        return this._commands.push({
          "command": "lineCap",
          "lineCap": value
        });
      };

      Graph.prototype.strokeStyle = function(style) {
        return this._commands.push({
          "command": "strokeStyle",
          "style": style
        });
      };

      Graph.prototype.fillStyle = function(style) {
        return this._commands.push({
          "command": "fillStyle",
          "style": style
        });
      };

      Graph.prototype.linearGradient = function(x1, y1, x2, y2, colors) {
        return this._commands.push({
          "command": "gradient",
          "point1": this.pixel(x1, y1),
          "point2": this.pixel(x2, y2),
          "colors": colors
        });
      };

      Graph.prototype.lineWidth = function(width) {
        return this._commands.push({
          "command": "lineWidth",
          "width": this.int(width)
        });
      };

      Graph.prototype.setLineDash = function(dash) {
        return this._commands.push({
          "command": "setDash",
          "dash": dash
        });
      };

      Graph.prototype.lineDashOffset = function(offset) {
        return this._commands.push({
          "command": "dashOffset",
          "offset": this.int(offset)
        });
      };

      Graph.prototype.moveTo = function(toX, toY) {
        return this._commands.push({
          "command": "moveTo",
          "point": this.pixel(toX, toY)
        });
      };

      Graph.prototype.lineTo = function(toX, toY) {
        this._commands.push({
          "command": "lineTo",
          "point": this.pixel(toX, toY)
        });
        return this.needAnimation = true;
      };

      Graph.prototype.line = function(fromX, fromY, toX, toY) {
        this._commands.push({
          "command": "line",
          "from": this.pixel(fromX, fromY),
          "to": this.pixel(toX, toY)
        });
        return this.needAnimation = true;
      };

      Graph.prototype.rect = function(fromX, fromY, width, height, radius) {
        if (radius == null) {
          radius = 0;
        }
        this._commands.push({
          "command": "rect",
          "point": this.pixel(fromX, fromY),
          "size": this.pixel(width, height),
          "radius": this.int(radius)
        });
        return this.needAnimation = true;
      };

      Graph.prototype.polyline = function(points, stroke) {
        if (stroke == null) {
          stroke = true;
        }
        this._commands.push({
          "command": "beginPath"
        });
        this.moveTo(points[0][0], points[0][1]);
        points.forEach((function(_this) {
          return function(point) {
            return _this.lineTo(point[0], point[1]);
          };
        })(this));
        if (stroke) {
          this.stroke();
        }
        return this.needAnimation = true;
      };

      Graph.prototype.polygon = function(points) {
        this.polyline(points, false);
        this.lineTo(points[0][0], points[0][1]);
        this.stroke();
        return this.fill();
      };

      Graph.prototype.fill = function() {
        this._commands.push({
          "command": "fill"
        });
        return this.needAnimation = true;
      };

      Graph.prototype.stroke = function() {
        this._commands.push({
          "command": "stroke"
        });
        return this.needAnimation = true;
      };

      Graph.prototype.animate = function() {
        Graph.__super__.animate.call(this);
        this.context.lineCap = "round";
        return this._commands.forEach((function(_this) {
          return function(command) {
            var gradient;
            switch (command.command) {
              case "beginPath":
                return _this.context.beginPath();
              case "lineCap":
                return _this.context.lineCap = command.lineCap;
              case "stroke":
                return _this.context.stroke();
              case "fill":
                return _this.context.fill();
              case "setDash":
                return _this.context.setLineDash(command.dash);
              case "dashOffset":
                return _this.context.lineDashOffset = command.offset;
              case "moveTo":
                return _this.context.moveTo(command.point[0] + _this._deltaX, command.point[1] + _this._deltaY);
              case "lineTo":
                return _this.context.lineTo(command.point[0] + _this._deltaX, command.point[1] + _this._deltaY);
              case "line":
                _this.context.beginPath();
                _this.context.moveTo(command.from[0] + _this._deltaX, command.from[1] + _this._deltaY);
                _this.context.lineTo(command.to[0] + _this._deltaX, command.to[1] + _this._deltaY);
                return _this.context.stroke();
              case "strokeStyle":
                return _this.context.strokeStyle = command.style;
              case "fillStyle":
                return _this.context.fillStyle = command.style;
              case "lineWidth":
                return _this.context.lineWidth = command.width;
              case "rect":
                _this.context.beginPath();
                if (command.radius === 0) {
                  return _this.context.rect(command.point[0] + _this._deltaX, command.point[1] + _this._deltaY, command.size[0], command.size[1]);
                } else {
                  return _this._drawRoundedRect(_this.context, command.point[0] + _this._deltaX, command.point[1] + _this._deltaY, command.size[0], command.size[1], command.radius);
                }
                break;
              case "gradient":
                gradient = _this.context.createLinearGradient(command.point1[0] + _this._deltaX, command.point1[1] + _this._deltaY, command.point2[0] + _this._deltaX, command.point2[1] + _this._deltaY);
                command.colors.forEach(function(color) {
                  return gradient.addColorStop(color[0], color[1]);
                });
                return _this.context.fillStyle = gradient;
            }
          };
        })(this));
      };

      Graph.prototype.log = function() {
        return console.log(this._commands);
      };

      Graph.prototype._drawRoundedRect = function(context, x, y, width, height, radius) {
        var halfpi, pi, x1, x2, y1, y2;
        pi = Math.PI;
        halfpi = pi / 2;
        x1 = x + radius;
        x2 = x + width - radius;
        y1 = y + radius;
        y2 = y + height - radius;
        context.moveTo(x1, y);
        context.lineTo(x2, y);
        context.arc(x2, y1, radius, -halfpi, 0);
        context.lineTo(x + width, y2);
        context.arc(x2, y2, radius, 0, halfpi);
        context.lineTo(x1, y + height);
        context.arc(x1, y2, radius, halfpi, pi);
        context.lineTo(x, y1);
        return context.arc(x1, y1, radius, pi, 3 * halfpi);
      };

      return Graph;

    })(DisplayObject);
  });

}).call(this);
