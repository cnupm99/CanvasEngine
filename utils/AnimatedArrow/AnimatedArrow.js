// Generated by CoffeeScript 1.10.0
(function() {
  "use strict";
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(function() {
    var AnimatedArrow;
    return AnimatedArrow = (function() {
      function AnimatedArrow(ce, options) {
        this.update = bind(this.update, this);
        this._scene = options.scene;
        if (!options.scene) {
          return;
        }
        this._graph = this._scene.add({
          type: "graph"
        });
        this._arrow = this._scene.add({
          type: "graph"
        });
        this._blockSize = options.blockSize || 50;
        this._spaceSize = options.spaceSize || 30;
        this._width = options.width || 100;
        this._style = options.style || "rgb(255, 0, 0)";
        this._offset = this._blockSize + this._spaceSize;
        this._speed = options.speed || 1;
        this._arrowWidth = Math.round(this._blockSize);
        this._arrowHeight = Math.round(this._width);
        this._from = options.from || [0, 0];
        this._to = options.to || [500, 500];
        this.setPoints(this._from, this._to);
        ce.addEvent(this.update);
      }

      AnimatedArrow.prototype.setPoints = function(point1, point2) {
        var dx, dy, newlength;
        this._from = this._scene.pixel(point1);
        this._to = this._scene.pixel(point2);
        this._arrowTo = this._scene.pixel(point2);
        dx = this._from[0] - this._to[0];
        dy = this._from[1] - this._to[1];
        this._length = Math.sqrt(dx * dx + dy * dy);
        newlength = this._length - this._blockSize + 2;
        if (this._length === 0) {
          this._length = 0.00001;
        }
        this._to[0] = this._from[0] - newlength * dx / this._length;
        this._to[1] = this._from[1] - newlength * dy / this._length;
        if (dx === 0) {
          dx = 0.00001;
        }
        this._angle = Math.atan(dy / dx);
        if (dx > 0) {
          this._angle += Math.PI;
        }
        this._angle /= this._scene._PIDIV180;
        return this._redraw();
      };

      AnimatedArrow.prototype.setTo = function(point) {
        return this.setPoints(this._from, point);
      };

      AnimatedArrow.prototype.setFrom = function(point) {
        return this.setPoints(point, this._arrowTo);
      };

      AnimatedArrow.prototype.update = function() {
        this._offset -= this._speed;
        if (this._offset < 0) {
          this._offset = this._blockSize + this._spaceSize;
        }
        return this._redrawLine();
      };

      AnimatedArrow.prototype._redrawLine = function() {
        this._graph.clear();
        if (this._length < this._blockSize + this._spaceSize) {
          return;
        }
        this._graph.strokeStyle(this._style);
        this._graph.lineWidth(this._width);
        this._graph.lineCap("butt");
        this._graph.setLineDash([this._blockSize, this._spaceSize]);
        this._graph.lineDashOffset(this._offset);
        this._graph.beginPath();
        this._graph.moveTo(this._from);
        this._graph.lineTo(this._to);
        return this._graph.stroke();
      };

      AnimatedArrow.prototype._redraw = function() {
        this._redrawLine();
        this._arrow.setCenter(this._arrowTo);
        this._arrow.rotate(this._angle);
        this._arrow.clear();
        this._arrow.lineWidth(1);
        this._arrow.fillStyle(this._style);
        this._arrow.beginPath();
        this._arrow.moveTo(this._arrowTo[0] - this._arrowWidth, this._arrowTo[1] - this._arrowHeight);
        this._arrow.lineTo(this._arrowTo[0], this._arrowTo[1]);
        this._arrow.lineTo(this._arrowTo[0] - this._arrowWidth, this._arrowTo[1] + this._arrowHeight);
        this._arrow.lineTo(this._arrowTo[0] - this._arrowWidth, this._arrowTo[1] - this._arrowHeight);
        return this._arrow.fill();
      };

      return AnimatedArrow;

    })();
  });

}).call(this);
