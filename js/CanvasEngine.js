// Generated by CoffeeScript 1.10.0
(function() {
  "use strict";
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(["ContainerObject", "Scene"], function(ContainerObject, Scene) {
    var CanvasEngine;
    return CanvasEngine = (function(superClass) {
      extend(CanvasEngine, superClass);

      function CanvasEngine(options) {
        this._animate = bind(this._animate, this);
        if (!this.canvasSupport()) {
          console.log("your browser not support canvas and/or context");
          return false;
        }
        CanvasEngine.__super__.constructor.call(this, options);
        this.parent = options.parent || document.body;
        if (this.size[0] === 0 && this.size[1] === 0) {
          this.size = [this.int(this.parent.clientWidth), this.int(this.parent.clientHeight)];
        }
        this._beforeAnimate = [];
        this._scene = "default";
        this.add({
          type: "scene",
          name: "default"
        });
        this.start();
      }

      CanvasEngine.prototype.add = function(options) {
        var scene, type;
        if (options == null) {
          options = {};
        }
        type = options.type || "scene";
        if (type === "scene") {
          return this._createScene(options);
        } else {
          scene = this.get(options.scene);
          if (!scene) {
            scene = this.getActive();
          }
          if (!scene) {
            scene = this.add({
              type: "scene",
              name: "default"
            });
          }
          return scene.add(options);
        }
      };

      CanvasEngine.prototype.remove = function(childName) {
        var index;
        index = this.index(childName);
        if (index === -1) {
          return false;
        }
        this.parent.removeChild(this.childrens[index].canvas);
        this.childrens.splice(index, 1);
        return true;
      };

      CanvasEngine.prototype.onTop = function(childName) {
        var maxZ, result;
        maxZ = 0;
        result = false;
        this.childrens.forEach(function(child) {
          if (child.zIndex > maxZ) {
            maxZ = child.zIndex;
          }
          if (childName === child.name) {
            return result = child;
          }
        });
        if (result) {
          result.setZIndex(maxZ + 1);
        }
        return result;
      };

      CanvasEngine.prototype.getActive = function() {
        var result;
        result = this.get(this._scene);
        if (!result) {
          result = this.childrens[0];
        }
        if (!result) {
          result = false;
        }
        return result;
      };

      CanvasEngine.prototype.setActive = function(sceneName) {
        this._scene = sceneName || "default";
        return this.getActive();
      };

      CanvasEngine.prototype.start = function() {
        return this._render = requestAnimationFrame(this._animate);
      };

      CanvasEngine.prototype.stop = function() {
        return cancelAnimationFrame(this._render);
      };

      CanvasEngine.prototype.addEvent = function(func) {
        return this._beforeAnimate.push(func);
      };

      CanvasEngine.prototype.removeEvent = function(func) {
        return this._beforeAnimate.forEach((function(_this) {
          return function(item, i) {
            if (item === func) {
              return _this._beforeAnimate.splice(i, 1);
            }
          };
        })(this));
      };

      CanvasEngine.prototype.fullscreen = function(value) {
        if (value == null) {
          value = true;
        }
        if (value) {
          if (this.parent.requestFullScreen != null) {
            this.parent.requestFullScreen();
          } else if (this.parent.webkitRequestFullScreen != null) {
            this.parent.webkitRequestFullScreen();
          } else if (this.parent.mozRequestFullScreen != null) {
            this.parent.mozRequestFullScreen();
          } else {
            return false;
          }
        } else {
          if (document.cancelFullScreen != null) {
            document.cancelFullScreen();
          } else if (document.webkitCancelFullScreen != null) {
            document.webkitCancelFullScreen();
          } else if (document.mozCancelFullScreen != null) {
            document.mozCancelFullScreen();
          } else if (document.exitFullScreen != null) {
            document.exitFullScreen();
          } else {
            return false;
          }
        }
        return true;
      };

      CanvasEngine.prototype.isFullscreen = function() {
        var element;
        element = document.fullscreenElement || document.webkitFullscreenElement || document.mozFullscreenElement;
        return element != null;
      };

      CanvasEngine.prototype.canvasSupport = function() {
        return document.createElement("canvas").getContext != null;
      };

      CanvasEngine.prototype._createScene = function(options) {
        var scene;
        if (options.visible == null) {
          options.visible = this.visible;
        }
        if (options.position == null) {
          options.position = this.position;
        }
        if (options.size == null) {
          options.size = this.size;
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
        options.parent = this.parent;
        scene = new Scene(options);
        this.childrens.push(scene);
        this.setActive(scene.name);
        return scene;
      };

      CanvasEngine.prototype._animate = function() {
        this._beforeAnimate.forEach(function(func) {
          return func();
        });
        this.needAnimation = false;
        this.childrens.forEach((function(_this) {
          return function(child) {
            var needAnimation;
            needAnimation = child.needAnimation || child.childrens.some(function(childOfChild) {
              return childOfChild.needAnimation;
            });
            _this.needAnimation = _this.needAnimation || needAnimation;
            if (needAnimation) {
              return child.animate();
            }
          };
        })(this));
        return this._render = requestAnimationFrame(this._animate);
      };

      return CanvasEngine;

    })(ContainerObject);
  });

}).call(this);
