// Generated by CoffeeScript 1.10.0
(function() {
  "use strict";
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(["base"], function(base) {
    var DisplayObject;
    return DisplayObject = (function(superClass) {
      extend(DisplayObject, superClass);

      function DisplayObject(options) {
        DisplayObject.__super__.constructor.call(this, options);
        this.name = options.name;
        this._shadow = false;
        this._visible = options.visible != null ? options.visible : true;
        this._context = options.parent.context;
        this._parentPosition = options.parent.position;
        this.needAnimation = this._visible;
      }

      DisplayObject.prototype.testPoint = function(pointX, pointY) {
        var imageData, offsetX, offsetY, pixelData;
        offsetX = pointX - this._parentPosition[0];
        offsetY = pointY - this._parentPosition[1];
        imageData = this._context.getImageData(offsetX, offsetY, 1, 1);
        pixelData = imageData.data;
        if (pixelData.every == null) {
          pixelData.every = Array.prototype.every;
        }
        return !pixelData.every(function(value) {
          return value === 0;
        });
      };

      DisplayObject.prototype.testRect = function(pointX, pointY) {
        var rect;
        rect = {
          left: this._position[0] + this._parentPosition[0],
          top: this._position[1] + this._parentPosition[1]
        };
        rect.right = rect.left + this._sizes[0];
        rect.bottom = rect.top + this._sizes[1];
        return (pointX >= rect.left) && (pointX <= rect.right) && (pointY >= rect.top) && (pointY <= rect.bottom);
      };

      DisplayObject.prototype.getPosition = function() {
        return this._position;
      };

      DisplayObject.prototype.getCenter = function() {
        return this._center;
      };

      DisplayObject.prototype.shift = function(_deltaX, _deltaY) {
        if (_deltaX == null) {
          _deltaX = 0;
        }
        if (_deltaY == null) {
          _deltaY = 0;
        }
        return this.setPosition([_deltaX + this._position[0], _deltaY + this._position[1]]);
      };

      DisplayObject.prototype.setVisible = function(value) {
        this._visible = value != null ? value : true;
        return this.needAnimation = this._visible;
      };

      DisplayObject.prototype.setTransform = function(options) {
        this.setSizes(options.sizes);
        this.setPosition(options.position);
        this.setCenter(options.center);
        this.setRotation(options.rotation);
        return this.setAlpha(options.alpha);
      };

      DisplayObject.prototype.setSizes = function(sizes) {
        if (sizes != null) {
          this._sizes = this._point(sizes);
        }
        return this.needAnimation = true;
      };

      DisplayObject.prototype.setPosition = function(position) {
        if (position != null) {
          this._position = this._point(position);
        }
        return this.needAnimation = true;
      };

      DisplayObject.prototype.setCenter = function(center) {
        if (center != null) {
          this._center = this._point(center);
        }
        return this.needAnimation = true;
      };

      DisplayObject.prototype.setRotation = function(rotation) {
        if (rotation != null) {
          this._rotation = this._value(rotation);
        }
        return this.needAnimation = true;
      };

      DisplayObject.prototype.setAlpha = function(alpha) {
        if (alpha != null) {
          this._alpha = this._value(alpha);
        }
        return this.needAnimation = true;
      };

      DisplayObject.prototype.setShadow = function(options) {
        if (options != null) {
          this._shadow = {
            color: options.color || "#000",
            blur: options.blur || 3,
            offsetX: options.offsetX || 0,
            offsetY: options.offsetY || 0,
            offset: options.offset || 0
          };
        } else {
          this._shadow = false;
        }
        return this.needAnimation = true;
      };

      DisplayObject.prototype.animate = function(context) {
        if (!this._visible) {
          this.needAnimation = false;
          return;
        }
        context.save();
        this._deltaX = this._position[0];
        this._deltaY = this._position[1];
        if (this._shadow) {
          context.shadowColor = this._shadow.color;
          context.shadowBlur = this._shadow.blur;
          context.shadowOffsetX = Math.max(this._shadow.offsetX, this._shadow.offset);
          context.shadowOffsetY = Math.max(this._shadow.offsetY, this._shadow.offset);
        }
        if (this._rotation !== 0) {
          context.translate(this._center[0] + this._position[0], this._center[1] + this._position[1]);
          context.rotate(this._rotation * Math.PI / 180);
          this._deltaX = -this._center[0];
          this._deltaY = -this._center[1];
        }
        return this.needAnimation = false;
      };

      return DisplayObject;

    })(base);
  });

}).call(this);
