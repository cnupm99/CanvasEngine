// Generated by CoffeeScript 1.10.0
(function() {
  "use strict";
  define(["Scene"], function(Scene) {
    var Scenes;
    return Scenes = (function() {
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
  });

}).call(this);
