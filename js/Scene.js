// Generated by CoffeeScript 1.10.0
(function() {
  "use strict";
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(["ContainerObject", "Image", "Text", "Graph", "TilingImage"], function(ContainerObject, Image, Text, Graph, TilingImage) {
    var Scene;
    return Scene = (function(superClass) {
      extend(Scene, superClass);

      function Scene(options) {
        var stage;
        stage = options.parent || document.body;
        this.canvas = document.createElement("canvas");
        this.canvas.style.position = "absolute";
        stage.appendChild(this.canvas);
        this.context = this.canvas.getContext("2d");
        Scene.__super__.constructor.call(this, options);
        this.type = "scene";
        this.setZIndex(options.zIndex);
        this.setMask(options.mask);
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
        if (options.shadow == null) {
          options.shadow = this.shadow;
        }
        options.canvas = this.canvas;
        options.context = this.context;
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

      Scene.prototype.setMask = function(value) {
        if ((value == null) || (!value)) {
          this.mask = false;
        } else {
          this.mask = value;
        }
        this.needAnimation = true;
        return this.mask;
      };

      Scene.prototype.setZIndex = function(value) {
        this.zIndex = this.int(value);
        this.canvas.style.zIndex = this.zIndex;
        return this.zIndex;
      };

      Scene.prototype.hide = function() {
        Scene.__super__.hide.call(this);
        return this.context.clearRect(0, 0, this.size[0], this.size[1]);
      };

      Scene.prototype.move = function(value1, value2) {
        Scene.__super__.move.call(this, value1, value2);
        this.canvas.style.left = this.position[0] + "px";
        this.canvas.style.top = this.position[1] + "px";
        return this.position;
      };

      Scene.prototype.resize = function(value1, value2) {
        Scene.__super__.resize.call(this, value1, value2);
        this.canvas.width = this.size[0];
        this.canvas.height = this.size[1];
        return this.size;
      };

      Scene.prototype.setCenter = function(value1, value2) {
        Scene.__super__.setCenter.call(this, value1, value2);
        this.context.translate(this.center[0], this.center[1]);
        return this.center;
      };

      Scene.prototype.setAnchor = function(value1, value2) {
        Scene.__super__.setAnchor.call(this, value1, value2);
        this.context.translate(this.center[0], this.center[1]);
        return this.anchor;
      };

      Scene.prototype.rotate = function(value) {
        Scene.__super__.rotate.call(this, value);
        this.context.rotate(this._rotation);
        return this.rotation;
      };

      Scene.prototype.setAlpha = function(value) {
        Scene.__super__.setAlpha.call(this, value);
        this.context.globalAlpha = this.alpha;
        return this.alpha;
      };

      Scene.prototype.animate = function() {
        if (!this.visible) {
          return;
        }
        this.context.clearRect(0, 0, this.size[0], this.size[1]);
        if (this.mask) {
          this.context.beginPath();
          this.context.rect(this.mask[0], this.mask[1], this.mask[2], this.mask[3]);
          this.context.clip();
        }
        this.childrens.forEach((function(_this) {
          return function(child) {
            _this.context.save();
            child.animate();
            return _this.context.restore();
          };
        })(this));
        return this.needAnimation = false;
      };

      return Scene;

    })(ContainerObject);
  });

}).call(this);
