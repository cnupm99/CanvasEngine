// Generated by CoffeeScript 1.10.0
(function() {
  "use strict";
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(function() {
    var CanvasEngine, DisplayObject, FPS, Graph, Image, Scene, Scenes, Text, TilingImage, base;
    base = (function() {
      function base(options) {
        this._rotation = options.rotation || 0;
        this._alpha = options.alpha || 1;
        this._sizes = this._point(options.sizes);
        this._position = this._point(options.position);
        this._center = this._point(options.center);
      }

      base.prototype._point = function(value, value2) {
        if (value == null) {
          return [0, 0];
        }
        if (value2 != null) {
          return [this._int(value), this._int(value2)];
        }
        if (Array.isArray(value)) {
          return [this._int(value[0]), this._int(value[1])];
        } else {
          if ((value.x != null) && (value.y != null)) {
            return [this._int(value.x), this._int(value.y)];
          }
          if ((value.width != null) && (value.height != null)) {
            return [this._int(value.width), this._int(value.height)];
          }
          return [0, 0];
        }
      };

      base.prototype._int = function(value) {
        return Math.round(this._value(value));
      };

      base.prototype._value = function(value) {
        if (value != null) {
          return +value;
        } else {
          return 0;
        }
      };

      return base;

    })();
    DisplayObject = (function(superClass) {
      extend(DisplayObject, superClass);

      function DisplayObject(options) {
        DisplayObject.__super__.constructor.call(this, options);
        this.name = options.name;
        this._shadow = false;
        this.needAnimation = true;
      }

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
    Graph = (function(superClass) {
      extend(Graph, superClass);

      function Graph(options) {
        Graph.__super__.constructor.call(this, options);
        this._commands = [];
        this.needAnimation = false;
      }

      Graph.prototype.line = function(fromX, fromY, toX, toY) {
        var from, to;
        from = this._point(fromX, fromY);
        to = this._point(toX, toY);
        this._commands.push({
          "command": "line",
          "from": from,
          "to": to
        });
        return this.needAnimation = true;
      };

      Graph.prototype.clear = function() {
        this._commands = [];
        return this.needAnimation = true;
      };

      Graph.prototype.strokeStyle = function(style) {
        return this._commands.push({
          "command": "strokeStyle",
          "style": style
        });
      };

      Graph.prototype.fillStyle = function(style) {
        return this._commands.push({
          "command": "fillStyle",
          "style": style
        });
      };

      Graph.prototype.linearGradient = function(x1, y1, x2, y2, colors) {
        return this._commands.push({
          "command": "gradient",
          "point1": this._point(x1, y1),
          "point2": this._point(x2, y2),
          "colors": colors
        });
      };

      Graph.prototype.rect = function(fromX, fromY, width, height, radius) {
        var point, sizes;
        if (radius == null) {
          radius = 0;
        }
        point = this._point(fromX, fromY);
        sizes = this._point(width, height);
        this._commands.push({
          "command": "rect",
          "point": point,
          "sizes": sizes,
          "radius": radius
        });
        return this.needAnimation = true;
      };

      Graph.prototype.moveTo = function(toX, toY) {
        var point;
        point = this._point(toX, toY);
        return this._commands.push({
          "command": "moveTo",
          "point": point
        });
      };

      Graph.prototype.lineTo = function(toX, toY) {
        var point;
        point = this._point(toX, toY);
        this._commands.push({
          "command": "lineTo",
          "point": point
        });
        return this.needAnimation = true;
      };

      Graph.prototype.fill = function() {
        this._commands.push({
          "command": "fill"
        });
        return this.needAnimation = true;
      };

      Graph.prototype.stroke = function() {
        this._commands.push({
          "command": "stroke"
        });
        return this.needAnimation = true;
      };

      Graph.prototype.polyline = function(points, stroke) {
        if (stroke == null) {
          stroke = true;
        }
        this._commands.push({
          "command": "beginPath"
        });
        this.moveTo(points[0][0], points[0][1]);
        points.forEach((function(_this) {
          return function(point) {
            return _this.lineTo(point[0], point[1]);
          };
        })(this));
        if (stroke) {
          this._commands.push({
            "command": "stroke"
          });
        }
        return this.needAnimation = true;
      };

      Graph.prototype.polygon = function(points) {
        this.polyline(points, false);
        this.lineTo(points[0][0], points[0][1]);
        this._commands.push({
          "command": "stroke"
        });
        this._commands.push({
          "command": "fill"
        });
        return this.needAnimation = true;
      };

      Graph.prototype.lineWidth = function(width) {
        width = this._int(width);
        return this._commands.push({
          "command": "lineWidth",
          "width": width
        });
      };

      Graph.prototype.setLineDash = function(dash) {
        return this._commands.push({
          "command": "setDash",
          "dash": dash
        });
      };

      Graph.prototype.lineDashOffset = function(offset) {
        offset = this._int(offset);
        return this._commands.push({
          "command": "dashOffset",
          "offset": offset
        });
      };

      Graph.prototype._drawRoundedRect = function(context, x, y, width, height, radius) {
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

      Graph.prototype.animate = function(context) {
        Graph.__super__.animate.call(this, context);
        context.lineCap = "round";
        this._commands.forEach((function(_this) {
          return function(command) {
            var gradient;
            switch (command.command) {
              case "beginPath":
                return context.beginPath();
              case "stroke":
                return context.stroke();
              case "fill":
                return context.fill();
              case "setDash":
                return context.setLineDash(command.dash);
              case "dashOffset":
                return context.lineDashOffset = command.offset;
              case "moveTo":
                return context.moveTo(command.point[0] + _this._deltaX, command.point[1] + _this._deltaY);
              case "lineTo":
                return context.lineTo(command.point[0] + _this._deltaX, command.point[1] + _this._deltaY);
              case "line":
                context.beginPath();
                context.moveTo(command.from[0] + _this._deltaX, command.from[1] + _this._deltaY);
                context.lineTo(command.to[0] + _this._deltaX, command.to[1] + _this._deltaY);
                return context.stroke();
              case "strokeStyle":
                return context.strokeStyle = command.style;
              case "fillStyle":
                return context.fillStyle = command.style;
              case "lineWidth":
                return context.lineWidth = command.width;
              case "rect":
                context.beginPath();
                if (command.radius === 0) {
                  return context.rect(command.point[0] + _this._deltaX, command.point[1] + _this._deltaY, command.sizes[0], command.sizes[1]);
                } else {
                  return _this._drawRoundedRect(context, command.point[0] + _this._deltaX, command.point[1] + _this._deltaY, command.sizes[0], command.sizes[1], command.radius);
                }
                break;
              case "gradient":
                gradient = context.createLinearGradient(command.point1[0] + _this._deltaX, command.point1[1] + _this._deltaY, command.point2[0] + _this._deltaX, command.point2[1] + _this._deltaY);
                command.colors.forEach(function(color) {
                  return gradient.addColorStop(color[0], color[1]);
                });
                return context.fillStyle = gradient;
            }
          };
        })(this));
        context.restore();
        return this.needAnimation = false;
      };

      return Graph;

    })(DisplayObject);
    Text = (function(superClass) {
      extend(Text, superClass);

      function Text(options) {
        Text.__super__.constructor.call(this, options);
        this._context = options.context;
        this.setFont(options.font);
        this.setText(options.text || "");
        this.fillStyle(options.fillStyle);
        this._strokeStyle = options.strokeStyle || false;
        this._strokeWidth = options.strokeWidth || 1;
        this.needAnimation = true;
      }

      Text.prototype.setText = function(text) {
        this._text = text;
        this._context.save();
        this._context.font = this._font;
        this.width = this._context.measureText(this._text).width;
        this._context.restore();
        return this.needAnimation = true;
      };

      Text.prototype.fillStyle = function(style) {
        this._fillStyle = style || false;
        return this.needAnimation = true;
      };

      Text.prototype.strokeStyle = function(style) {
        this._strokeStyle = style || false;
        return this.needAnimation = true;
      };

      Text.prototype.setFont = function(font) {
        var span;
        this._font = font || "12px Arial";
        span = document.createElement("span");
        span.appendChild(document.createTextNode("height"));
        span.style.cssText = "font: " + this._font + "; white-space: nowrap; display: inline;";
        document.body.appendChild(span);
        this.fontHeight = span.offsetHeight;
        document.body.removeChild(span);
        return this.needAnimation = true;
      };

      Text.prototype.animate = function(context) {
        var gradient;
        Text.__super__.animate.call(this, context);
        context.font = this._font;
        context.textBaseline = "top";
        if (this._fillStyle) {
          if (Array.isArray(this._fillStyle)) {
            gradient = context.createLinearGradient(this._deltaX, this._deltaY, this._deltaX, this._deltaY + this.fontHeight);
            this._fillStyle.forEach(function(color) {
              return gradient.addColorStop(color[0], color[1]);
            });
            context.fillStyle = gradient;
          } else {
            context.fillStyle = this._fillStyle;
          }
          context.fillText(this._text, this._deltaX, this._deltaY);
        }
        if (this._strokeStyle) {
          context.strokeStyle = this._strokeStyle;
          context.lineWidth = this._strokeWidth;
          context.strokeText(this._text, this._deltaX, this._deltaY);
        }
        context.restore();
        return this.needAnimation = false;
      };

      return Text;

    })(DisplayObject);
    Image = (function(superClass) {
      extend(Image, superClass);

      function Image(options) {
        Image.__super__.constructor.call(this, options);
        this.onload = options.onload;
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
            _this._loaded = true;
            if (_this.onload != null) {
              return _this.onload(_this._realSizes);
            }
          };
        })(this);
        return this._image.src = src;
      };

      Image.prototype.getSizes = function() {
        return this._sizes;
      };

      Image.prototype.getRealSizes = function() {
        return this._realSizes;
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
    TilingImage = (function(superClass) {
      extend(TilingImage, superClass);

      function TilingImage(options) {
        TilingImage.__super__.constructor.call(this, options);
        this._rect = options.rect;
      }

      TilingImage.prototype.setRect = function(rect) {
        this._rect = rect;
        return this.needAnimation = true;
      };

      TilingImage.prototype.animate = function(context) {
        if (!this._loaded) {
          return;
        }
        TilingImage.__super__.animate.call(this, context);
        context.fillStyle = context.createPattern(this._image, "repeat");
        context.rect(this._rect[0], this._rect[1], this._rect[2], this._rect[3]);
        context.fill();
        context.restore();
        return this.needAnimation = false;
      };

      return TilingImage;

    })(Image);
    Scene = (function(superClass) {
      extend(Scene, superClass);

      function Scene(options) {
        Scene.__super__.constructor.call(this, options);
        this.name = options.name;
        this.canvas = document.createElement("canvas");
        this.canvas.style.position = "absolute";
        this.setZ(options.zIndex);
        this.context = this.canvas.getContext("2d");
        this.setTransform(options);
        this._mask = false;
        this._needAnimation = false;
        this._objects = [];
      }

      Scene.prototype.setZ = function(value) {
        this._zIndex = this._int(value);
        return this.canvas.style.zIndex = this._zIndex;
      };

      Scene.prototype.getZ = function() {
        return this._zIndex;
      };

      Scene.prototype.add = function(options) {
        var result;
        if (options.type == null) {
          return;
        }
        switch (options.type) {
          case "image":
            result = new Image(options);
            break;
          case "text":
            options.context = this.context;
            result = new Text(options);
            break;
          case "graph":
            result = new Graph(options);
            break;
          case "tile":
            if (options.rect == null) {
              options.rect = [0, 0, this._sizes[0], this._sizes[1]];
            }
            result = new TilingImage(options);
        }
        this._objects.push(result);
        return result;
      };

      Scene.prototype.get = function(objectName) {
        var answer;
        answer = false;
        this._objects.some(function(_object) {
          var flag;
          flag = _object.name === objectName;
          if (flag) {
            answer = _object;
          }
          return flag;
        });
        return answer;
      };

      Scene.prototype.remove = function(objectName) {
        var index;
        index = -1;
        this._objects.some(function(_object, i) {
          var flag;
          flag = _object.name === objectName;
          if (flag) {
            index = i;
          }
          return flag;
        });
        if (index > -1) {
          this._objects.splice(index, 1);
          return true;
        }
        return false;
      };

      Scene.prototype.addChild = function(_object) {
        this._objects.push(_object);
        return this._needAnimation = true;
      };

      Scene.prototype.removeChild = function(_object) {
        var index;
        index = -1;
        this._objects.some(function(_object2, i) {
          var flag;
          flag = _object2 === _object;
          if (flag) {
            index = i;
          }
          return flag;
        });
        if (index > -1) {
          this._objects.splice(index, 1);
          return true;
        }
        return false;
      };

      Scene.prototype.needAnimation = function() {
        return this._needAnimation || this._objects.some(function(_object) {
          return _object.needAnimation;
        });
      };

      Scene.prototype.testPoint = function(pointX, pointY) {
        var imageData, pixelData;
        imageData = this.context.getImageData(pointX, pointY, 1, 1);
        pixelData = imageData.data;
        if (pixelData.every == null) {
          pixelData.every = Array.prototype.every;
        }
        return !pixelData.every(function(value) {
          return value === 0;
        });
      };

      Scene.prototype.setMask = function(x, y, width, height) {
        if (arguments.length < 4) {
          this._mask = false;
        } else {
          this._mask = {
            x: this._int(x),
            y: this._int(y),
            width: this._int(width),
            height: this._int(height)
          };
        }
        return this._needAnimation = true;
      };

      Scene.prototype.setTransform = function(options) {
        this.setSizes(options.sizes);
        this.setPosition(options.position);
        this.setCenter(options.center);
        this.setRotation(options.rotation);
        return this.setAlpha(options.alpha);
      };

      Scene.prototype.setSizes = function(sizes) {
        if (sizes != null) {
          this._sizes = this._point(sizes);
        }
        this.canvas.width = this._sizes[0];
        this.canvas.height = this._sizes[1];
        return this._needAnimation = true;
      };

      Scene.prototype.setPosition = function(position) {
        if (position != null) {
          this._position = this._point(position);
        }
        this.canvas.style.left = this._position[0];
        this.canvas.style.top = this._position[1];
        return this._needAnimation = true;
      };

      Scene.prototype.setCenter = function(center) {
        if (center != null) {
          this._center = this._point(center);
        }
        this.context.translate(this._center[0], this._center[1]);
        return this._needAnimation = true;
      };

      Scene.prototype.setRotation = function(rotation) {
        if (rotation != null) {
          this._rotation = this._value(rotation);
        }
        this.context.rotation = this._rotation * Math.PI / 180;
        return this._needAnimation = true;
      };

      Scene.prototype.setAlpha = function(alpha) {
        if (alpha != null) {
          this._alpha = this._value(alpha);
        }
        this.context.globalAlpha = this._alpha;
        return this._needAnimation = true;
      };

      Scene.prototype.animate = function() {
        this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
        if (this._mask) {
          this.context.beginPath();
          this.context.rect(this._mask.x, this._mask.y, this._mask.width, this._mask.height);
          this.context.clip();
        }
        this._objects.forEach((function(_this) {
          return function(_object) {
            return _object.animate(_this.context);
          };
        })(this));
        return this._needAnimation = false;
      };

      return Scene;

    })(base);
    Scenes = (function() {
      function Scenes(stage) {
        this._scenes = [];
        this._stage = stage;
        this._activeSceneName = "";
      }

      Scenes.prototype.create = function(options) {
        var scene, sceneName, setActive;
        sceneName = options.name || "default";
        scene = this.get(sceneName);
        if (!scene) {
          scene = new Scene(options);
          this._stage.appendChild(scene.canvas);
          this._scenes.push(scene);
        }
        setActive = options.setActive != null ? options.setActive : true;
        if (setActive) {
          this._activeSceneName = sceneName;
        }
        return scene;
      };

      Scenes.prototype.active = function() {
        return this._activeSceneName;
      };

      Scenes.prototype.active.set = function(sceneName) {
        var scene;
        scene = this.get(sceneName);
        if (scene) {
          this._activeSceneName = sceneName;
        }
        return scene;
      };

      Scenes.prototype.active.get = function() {
        return this.get(this._activeSceneName);
      };

      Scenes.prototype.get = function(sceneName) {
        var answer;
        answer = false;
        this._scenes.some(function(scene) {
          var flag;
          flag = scene.name === sceneName;
          if (flag) {
            answer = scene;
          }
          return flag;
        });
        return answer;
      };

      Scenes.prototype.remove = function(sceneName) {
        var index;
        index = this._index(sceneName);
        if (index > -1) {
          this._parent.removeChild(this._scenes[index].canvas);
          this._scenes.splice(index, 1);
          return true;
        }
        return false;
      };

      Scenes.prototype.rename = function(sceneName, newName) {
        var scene;
        scene = this.get(sceneName);
        if (scene) {
          scene.name = newName;
        }
        return scene;
      };

      Scenes.prototype.onTop = function(sceneName) {
        var maxZ, result;
        maxZ = 0;
        result = false;
        this._scenes.forEach(function(scene) {
          if (scene.getZ() > maxZ) {
            maxZ = scene.getZ();
          }
          if (sceneName === scene.name) {
            return result = scene;
          }
        });
        if (result) {
          result.setZ(maxZ + 1);
        }
        return result;
      };

      Scenes.prototype.needAnimation = function() {
        return this._scenes.some(function(scene) {
          return scene.needAnimation();
        });
      };

      Scenes.prototype.animate = function() {
        return this._scenes.forEach(function(scene) {
          if (scene.needAnimation()) {
            return scene.animate();
          }
        });
      };

      Scenes.prototype._index = function(sceneName) {
        var index;
        index = -1;
        this._scenes.some(function(scene) {
          var flag;
          flag = scene.name === sceneName;
          if (flag) {
            index = scene;
          }
          return flag;
        });
        return index;
      };

      return Scenes;

    })();
    FPS = (function() {
      function FPS(options) {
        this._onTimer = bind(this._onTimer, this);
        this._scene = options.scene;
        this._graph = this._scene.add({
          type: "graph"
        });
        this._values = [];
        this._caption = this._scene.add({
          type: "text",
          fillStyle: "#00FF00",
          font: "10px Arial",
          position: [3, 1]
        });
        this._caption2 = this._scene.add({
          type: "text",
          fillStyle: "#FF0000",
          font: "10px Arial",
          position: [48, 1]
        });
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
        if (this._values.length === 84) {
          this._values.shift();
        }
        this._graph.clear();
        this._graph.fillStyle("#000");
        this._graph.rect(0, 0, 90, 40);
        this._graph.fill();
        for (i = j = 0, ref = this._values.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
          x = 87 - this._values.length + i;
          fps = this._values[i][0];
          ups = this._values[i][1];
          this._graph.strokeStyle("#00FF00");
          this._graph.line(x, 37, x, 37 - 23 * fps / 60);
          this._graph.strokeStyle("#FF0000");
          this._graph.line(x, 37, x, 37 - 23 * ups / 60);
        }
        this._caption.setText("FPS: " + this._FPSValue);
        return this._caption2.setText("UPS: " + this._updateValue);
      };

      FPS.prototype.update = function(needAnimation) {
        this._counter++;
        if (needAnimation) {
          return this._updateCounter++;
        }
      };

      return FPS;

    })();
    CanvasEngine = (function(superClass) {
      extend(CanvasEngine, superClass);

      function CanvasEngine(options) {
        this._animate = bind(this._animate, this);
        var scene;
        if (!this._canvasSupport()) {
          console.log("your browser not support canvas and/or context");
          return false;
        }
        CanvasEngine.__super__.constructor.call(this, options);
        this._parent = options.parent || document.body;
        this.scenes = new Scenes(this._parent);
        this._beforeAnimate = [];
        this._showFPS = options.showFPS != null ? options.showFPS : true;
        if (this._showFPS) {
          scene = this.scenes.create({
            name: "FPS",
            sizes: [90, 40],
            position: [5, 5],
            zIndex: 9999,
            setActive: false
          });
          this._FPS = new FPS({
            scene: scene
          });
        }
        this.start();
      }

      CanvasEngine.prototype.start = function() {
        return this._render = requestAnimationFrame(this._animate);
      };

      CanvasEngine.prototype.stop = function() {
        return cancelAnimationFrame(this._render);
      };

      CanvasEngine.prototype.addEvent = function(handler) {
        return this._beforeAnimate.push(handler);
      };

      CanvasEngine.prototype.removeEvent = function(handler) {
        return this._beforeAnimate.forEach((function(_this) {
          return function(item, i) {
            if (item === handler) {
              return _this._beforeAnimate.splice(i, 1);
            }
          };
        })(this));
      };

      CanvasEngine.prototype.add = function(options) {
        var scene, sceneName, type;
        type = options.type || "scene";
        if (type === "scene") {
          if (options.sizes == null) {
            options.sizes = this._sizes;
          }
          return this.scenes.create(options);
        } else {
          sceneName = options.scene || this.scenes.active() || "default";
          scene = this.scenes.create({
            name: sceneName,
            sizes: options.sizes || this._sizes
          });
          return scene.add(options);
        }
      };

      CanvasEngine.prototype._canvasSupport = function() {
        return document.createElement("canvas").getContext != null;
      };

      CanvasEngine.prototype._animate = function() {
        var needAnimation;
        this._beforeAnimate.forEach(function(handler) {
          if (typeof handler === "function") {
            return handler();
          }
        });
        needAnimation = this.scenes.needAnimation();
        if (needAnimation) {
          this.scenes.animate();
        }
        if (this._showFPS) {
          this._FPS.update(needAnimation);
        }
        return this._render = requestAnimationFrame(this._animate);
      };

      return CanvasEngine;

    })(base);
    return CanvasEngine;
  });

}).call(this);
