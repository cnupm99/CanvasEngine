// Generated by CoffeeScript 1.10.0
(function() {
  "use strict";
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(["DisplayObject", "Image", "Text", "Graph", "TilingImage"], function(DisplayObject, Image, Text, Graph, TilingImage) {
    var Scene;
    return Scene = (function(superClass) {
      extend(Scene, superClass);

      function Scene(options) {
        this.stage = options.stage || document.body;
        this.canvas = document.createElement("canvas");
        this.canvas.style.position = "absolute";
        this.stage.appendChild(this.canvas);
        this.context = this.canvas.getContext("2d");
        Scene.__super__.constructor.call(this, options);
        this.type = "scene";
        Object.defineProperty(this, "zIndex", {
          get: function() {
            return _zIndex;
          },
          set: function(value) {
            var _zIndex;
            _zIndex = this.int(value);
            this.canvas.style.zIndex = _zIndex;
            return _zIndex;
          }
        });
        this.zIndex = this.int(options.zIndex);
        this.needAnimation = false;
      }

      Scene.prototype.add = function(options) {
        var result;
        if (options.type == null) {
          return;
        }
        if (options.visible == null) {
          options.visible = this.visible;
        }
        if (options.position == null) {
          options.position = this.position;
        }
        if (options.size == null) {
          options.size = this.sizes;
        }
        if (options.center == null) {
          options.center = this.center;
        }
        if (options.rotation == null) {
          options.rotation = this.rotation;
        }
        if (options.alpha == null) {
          options.alpha = this.alpha;
        }
        if (options.mask == null) {
          options.mask = this.mask;
        }
        if (options.shadow == null) {
          options.shadow = this.shadow;
        }
        options.parent = this;
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
        this.childrens.push(result);
        return result;
      };

      Scene.prototype.animate = function() {
        this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
        if (this.mask) {
          this.context.beginPath();
          this.context.rect(this.mask.x, this.mask.y, this.mask.width, this.mask.height);
          this.context.clip();
        }
        this.childrens.forEach(function(child) {
          return child.animate();
        });
        return this.needAnimation = false;
      };

      Scene.prototype._setPosition = function() {
        Scene.__super__._setPosition.call(this);
        this.canvas.style.left = this.position[0] + "px";
        this.canvas.style.top = this.position[1] + "px";
        return this.position;
      };

      Scene.prototype._setSize = function() {
        Scene.__super__._setSize.call(this);
        this.canvas.width = this.size[0];
        this.canvas.height = this.size[1];
        return this.size;
      };

      Scene.prototype._setCenter = function() {
        Scene.__super__._setCenter.call(this);
        this.context.translate(this.center[0], this.center[1]);
        return this.center;
      };

      Scene.prototype._setRotation = function() {
        Scene.__super__._setRotation.call(this);
        this.context.rotate(this.deg2rad(this.rotation));
        return this.rotation;
      };

      Scene.prototype._setAlpha = function() {
        Scene.__super__._setAlpha.call(this);
        this.context.globalAlpha = this.alpha;
        return this.alpha;
      };

      return Scene;

    })(DisplayObject);
  });

}).call(this);
