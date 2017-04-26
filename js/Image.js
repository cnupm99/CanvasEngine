// Generated by CoffeeScript 1.10.0
(function() {
  "use strict";
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(["DisplayObject"], function(DisplayObject) {
    var Image;
    return Image = (function(superClass) {
      extend(Image, superClass);

      function Image(options) {
        Image.__super__.constructor.call(this, options);
        this._realSizes = [100, 100];
        this.needAnimation = false;
        this._image = document.createElement("img");
        this.setSrc(options.src);
      }

      Image.prototype.setSrc = function(src) {
        this._loaded = false;
        this._image.onload = (function(_this) {
          return function() {
            _this._realSizes = [_this._image.width, _this._image.height];
            if ((_this._sizes[0] <= 0) || (_this._sizes[1] <= 0)) {
              _this._sizes = _this._realSizes;
            }
            _this.needAnimation = true;
            return _this._loaded = true;
          };
        })(this);
        return this._image.src = src;
      };

      Image.prototype.animate = function(context) {
        if (!this._loaded) {
          return;
        }
        Image.__super__.animate.call(this, context);
        if ((this._sizes[0] === this._realSizes[0]) && (this._sizes[1] === this._realSizes[1])) {
          context.drawImage(this._image, this._deltaX, this._deltaY);
        } else {
          context.drawImage(this._image, this._deltaX, this._deltaY, this._sizes[0], this._sizes[1]);
        }
        context.restore();
        return this.needAnimation = false;
      };

      return Image;

    })(DisplayObject);
  });

}).call(this);
