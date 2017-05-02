// Generated by CoffeeScript 1.10.0
(function() {
  "use strict";
  define(function() {
    var ProgressBar;
    return ProgressBar = (function() {
      function ProgressBar(options) {
        var colors;
        this._scene = options.scene;
        if (!this._scene) {
          return false;
        }
        this._scene.addChild(this);
        this._minValue = options.minValue || 0;
        this._maxValue = options.maxValue || 100;
        this._progress = options.progress || 0;
        this._value = options.value || 0;
        if (this._progress > 0) {
          this.progress(this._progress);
        } else if (this._value > 0) {
          this.value(this._value);
        }
        colors = options.colors || {};
        this._colors = {
          backgroundColor: colors.backgroundColor || ["#C3BD73", "#DCD9A2"],
          backgroundShadowColor: colors.backgroundShadowColor || "#FFF",
          progress25: colors.progress25 || ["#f27011", "#E36102"],
          progress50: colors.progress50 || ["#f2b01e", "#E3A10F"],
          progress75: colors.progress75 || ["#f2d31b", "#E3C40C"],
          progress100: colors.progress100 || ["#86e01e", "#67C000"],
          progressShadowColor: colors.progressShadowColor || "#000",
          caption: colors.caption || "#B22222",
          captionStroke: colors.captionStroke || "#A11111"
        };
        this._position = options.position || [0, 0];
        this._sizes = options.sizes || [300, 50];
        this._padding = options.padding || 3;
        this._rounded = options.rounded != null ? options.rounded : true;
        this._radius = options.radius || 5;
        this._showCaption = options.showCaption != null ? options.showCaption : false;
        this._caption = options.caption || "Progress: ";
        this._font = options.font || "24px Arial";
        this._fontHeight = this._getFontHeight();
        this._strokeCaption = options.strokeCaption != null ? options.strokeCaption : true;
        this._showProgress = options.showProgress != null ? options.showProgress : true;
        this.needAnimation = true;
      }

      ProgressBar.prototype.setValues = function(min, max) {
        if (min >= max) {
          return false;
        }
        this._minValue = min;
        this._maxValue = max;
        return this.needAnimation = true;
      };

      ProgressBar.prototype.progress = function(progress) {
        this._progress = progress;
        this._value = progress * this._maxValue / 100;
        this._drawProgress = true;
        return this.needAnimation = true;
      };

      ProgressBar.prototype.value = function(value) {
        this._value = value;
        this._progress = Math.floor(value * 100 / this._maxValue);
        this._drawProgress = false;
        return this.needAnimation = true;
      };

      ProgressBar.prototype.getProgress = function() {
        return this._progress;
      };

      ProgressBar.prototype.getValue = function() {
        return this._value;
      };

      ProgressBar.prototype._getFontHeight = function() {
        var height, span;
        span = document.createElement("span");
        span.appendChild(document.createTextNode("height"));
        span.style.cssText = "font: " + this._font + "; white-space: nowrap; display: inline;";
        document.body.appendChild(span);
        height = span.offsetHeight;
        document.body.removeChild(span);
        return height;
      };

      ProgressBar.prototype._drawRoundedRect = function(context, x, y, width, height, radius) {
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

      ProgressBar.prototype._setGradient = function(context, color1, color2) {
        var gradient;
        gradient = context.createLinearGradient(this._padding, this._padding, this._padding, this._sizes[1] - this._padding * 2);
        gradient.addColorStop(0, color2);
        gradient.addColorStop(0.5, color1);
        gradient.addColorStop(1, color2);
        return context.fillStyle = gradient;
      };

      ProgressBar.prototype.animate = function(context) {
        var color, size, text, width;
        context.save();
        context.translate(this._position[0], this._position[1]);
        context.shadowColor = this._colors.backgroundShadowColor;
        context.shadowBlur = 3;
        context.shadowOffsetX = 0;
        context.shadowOffsetY = 0;
        this._setGradient(context, this._colors.backgroundColor[0], this._colors.backgroundColor[1]);
        context.beginPath();
        if (this._rounded) {
          this._drawRoundedRect(context, 0, 0, this._sizes[0], this._sizes[1], this._radius);
        } else {
          context.rect(0, 0, this._sizes[0], this._sizes[1]);
        }
        context.strokeStyle = "#000";
        context.stroke();
        context.fill();
        if (this._progress <= 25) {
          color = this._colors.progress25;
        } else if (this._progress <= 50) {
          color = this._colors.progress50;
        } else if (this._progress <= 75) {
          color = this._colors.progress75;
        } else {
          color = this._colors.progress100;
        }
        size = Math.floor((this._sizes[0] - this._padding * 2) * this._value / this._maxValue);
        this._setGradient(context, color[0], color[1]);
        context.shadowColor = this._colors.progressShadowColor;
        context.beginPath();
        if (this._rounded) {
          this._drawRoundedRect(context, this._padding, this._padding, size, this._sizes[1] - this._padding * 2, this._radius);
        } else {
          context.rect(this._padding, this._padding, size, this._sizes[1] - this._padding * 2);
        }
        context.fill();
        context.shadowColor = "rgba(0, 0, 0, 0)";
        text = "";
        if (this._showCaption) {
          text += this._caption;
        }
        if (this._showProgress) {
          text += this._drawProgress ? this._progress + "%" : this._value;
        }
        if (text.length > 0) {
          context.fillStyle = this._colors.caption;
          context.font = this._font;
          width = context.measureText(text).width;
          context.textBaseline = "top";
          context.fillText(text, (this._sizes[0] - width) / 2, (this._sizes[1] - this._fontHeight) / 2);
          if (this._strokeCaption) {
            context.lineWidth = 1;
            context.strokeStyle = this._colors.captionStroke;
            context.strokeText(text, (this._sizes[0] - width) / 2, (this._sizes[1] - this._fontHeight) / 2);
          }
        }
        this.needAnimation = false;
        return context.restore();
      };

      return ProgressBar;

    })();
  });

}).call(this);
