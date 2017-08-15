// Generated by CoffeeScript 1.10.0
(function() {
  "use strict";
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(["DisplayObject"], function(DisplayObject) {
    var Text;
    return Text = (function(superClass) {
      extend(Text, superClass);

      function Text(options) {
        var _fillStyle, _font, _strokeStyle, _strokeWidth, _text;
        Text.__super__.constructor.call(this, options);
        this.fontHeight = 0;
        this.textWidth = 0;
        _font = _fillStyle = _strokeStyle = _strokeWidth = _text = "";
        this.setFont(options.font);
        this.setFillStyle(options.fillStyle);
        this.setStrokeStyle(options.strokeStyle);
        this.setStrokeWidth(options.strokeWidth);
        this.setText(options.text);
      }

      Text.prototype.setFont = function(value) {
        var span;
        this.font = value || "12px Arial";
        span = document.createElement("span");
        span.appendChild(document.createTextNode("height"));
        span.style.cssText = "font: " + this.font + "; white-space: nowrap; display: inline;";
        document.body.appendChild(span);
        this.fontHeight = span.offsetHeight;
        document.body.removeChild(span);
        this.needAnimation = true;
        return this.font;
      };

      Text.prototype.setFillStyle = function(value) {
        this.fillStyle = value || false;
        this.needAnimation = true;
        return this.fillStyle;
      };

      Text.prototype.setStrokeStyle = function(value) {
        this.strokeStyle = value || false;
        this.needAnimation = true;
        return this.strokeStyle;
      };

      Text.prototype.setStrokeWidth = function(value) {
        this.strokeWidth = this.int(value) || 1;
        this.needAnimation = true;
        return this.strokeWidth;
      };

      Text.prototype.setText = function(value) {
        this.text = value || "";
        this.context.save();
        this.context.font = this.font;
        this.textWidth = this.context.measureText(this.text).width;
        this.context.restore();
        this.needAnimation = true;
        return this.text;
      };

      Text.prototype.animate = function() {
        var gradient;
        Text.__super__.animate.call(this);
        this.context.font = this.font;
        this.context.textBaseline = "top";
        if (this.fillStyle) {
          if (Array.isArray(this.fillStyle)) {
            gradient = this.context.createLinearGradient(this._deltaX, this._deltaY, this._deltaX, this._deltaY + this.fontHeight);
            this.fillStyle.forEach(function(color) {
              return gradient.addColorStop(color[0], color[1]);
            });
            this.context.fillStyle = gradient;
          } else {
            this.context.fillStyle = this.fillStyle;
          }
          this.context.fillText(this.text, this._deltaX, this._deltaY);
        }
        if (this.strokeStyle) {
          this.context.strokeStyle = this.strokeStyle;
          this.context.lineWidth = this.strokeWidth;
          this.context.strokeText(this.text, this._deltaX, this._deltaY);
        }
        this.context.restore();
        return this.needAnimation = false;
      };

      return Text;

    })(DisplayObject);
  });

}).call(this);
