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
        Text.__super__.constructor.call(this, options);
        this.fontHeight = 0;
        this.textWidth = 0;
        this.setFont(options.font);
        this.setFillStyle(options.fillStyle);
        this.setStrokeStyle(options.strokeStyle);
        this.setStrokeWidth(options.strokeWidth);
        this.write(options.text);
      }

      Text.prototype.setFont = function(value) {
        this.font = value || "12px Arial";
        this.fontHeight = this._getFontHeight(this.font);
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
        this.strokeWidth = value != null ? this.int(value) : 1;
        this.needAnimation = true;
        return this.strokeWidth;
      };

      Text.prototype.write = function(value) {
        this.text = value || "";
        this.upsize(this._getRealSizes(this.text));
        this.textWidth = this.realSize[0];
        this.textHeight = this.realSize[1];
        this.needAnimation = true;
        return this.text;
      };

      Text.prototype.animate = function() {
        var gradient, lines, textY;
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
        }
        if (this.strokeStyle) {
          this.context.strokeStyle = this.strokeStyle;
          this.context.lineWidth = this.strokeWidth;
        }
        lines = this.text.split("\n");
        textY = this._deltaY;
        return lines.forEach((function(_this) {
          return function(line) {
            if (_this.fillStyle) {
              _this.context.fillText(line, _this._deltaX, textY);
            }
            if (_this.strokeStyle) {
              _this.context.strokeText(line, _this._deltaX, textY);
            }
            return textY += _this.fontHeight;
          };
        })(this));
      };

      Text.prototype._getFontHeight = function(font) {
        var fontHeight, span;
        span = document.createElement("span");
        span.appendChild(document.createTextNode("height"));
        span.style.cssText = "font: " + font + "; white-space: nowrap; display: inline;";
        document.body.appendChild(span);
        fontHeight = span.offsetHeight;
        document.body.removeChild(span);
        return fontHeight;
      };

      Text.prototype._getTextWidth = function(text) {
        var textWidth;
        this.context.save();
        this.context.font = this.font;
        textWidth = this.context.measureText(text).width;
        this.context.restore();
        return textWidth;
      };

      Text.prototype._getRealSizes = function(text) {
        var lines, maxWidth;
        maxWidth = 0;
        lines = this.text.split("\n");
        lines.forEach((function(_this) {
          return function(line) {
            var width;
            width = _this._getTextWidth(line);
            if (width > maxWidth) {
              return maxWidth = width;
            }
          };
        })(this));
        return [maxWidth, lines.length * this.fontHeight];
      };

      return Text;

    })(DisplayObject);
  });

}).call(this);
