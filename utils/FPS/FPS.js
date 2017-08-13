// Generated by CoffeeScript 1.10.0
(function() {
  "use strict";
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(function() {
    var FPS;
    return FPS = (function() {
      function FPS(CE, position) {
        if (position == null) {
          position = [0, 0];
        }
        this._update = bind(this._update, this);
        this._onTimer = bind(this._onTimer, this);
        if (CE == null) {
          return;
        }
        this.CE = CE;
        this._scene = CE.add({
          type: "scene",
          name: "FPS",
          zIndex: 9999,
          size: [100, 45],
          position: position
        });
        this._graph = this._scene.add({
          type: "graph"
        });
        this._values = [];
        this._caption = this._scene.add({
          type: "text",
          fillStyle: "#00FF00",
          font: "12px Arial",
          position: [3, 1]
        });
        this._caption2 = this._scene.add({
          type: "text",
          fillStyle: "#FFFF00",
          font: "12px Arial",
          position: [53, 1]
        });
        CE.addEvent(this._update);
        this.start();
        this._onTimer();
      }

      FPS.prototype.start = function() {
        this._counter = this._updateCounter = this._FPSValue = 0;
        return this._interval = setInterval(this._onTimer, 1000);
      };

      FPS.prototype.stop = function() {
        clearInterval(this._interval);
        return this._counter = this._updateCounter = this._FPSValue = 0;
      };

      FPS.prototype._onTimer = function() {
        var fps, i, j, ref, ups, x;
        this._FPSValue = this._counter;
        this._counter = 0;
        this._updateValue = this._updateCounter;
        this._updateCounter = 0;
        this._values.push([this._FPSValue, this._updateValue]);
        if (this._values.length === 94) {
          this._values.shift();
        }
        this._graph.clear();
        this._graph.fillStyle("#000");
        this._graph.rect(0, 0, 100, 45);
        this._graph.fill();
        for (i = j = 0, ref = this._values.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
          x = 97 - this._values.length + i;
          fps = this._values[i][0];
          ups = this._values[i][1];
          this._graph.strokeStyle("#00FF00");
          this._graph.line(x, 42, x, 42 - 26 * fps / 60);
          this._graph.strokeStyle("#FFFF00");
          this._graph.line(x, 42, x, 42 - 26 * ups / 60);
        }
        this._caption.setText("FPS: " + this._FPSValue);
        return this._caption2.setText("UPS: " + this._updateValue);
      };

      FPS.prototype._update = function() {
        this._counter++;
        if (this.CE.needAnimation) {
          return this._updateCounter++;
        }
      };

      return FPS;

    })();
  });

}).call(this);
