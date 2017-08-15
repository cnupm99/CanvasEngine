// Generated by CoffeeScript 1.10.0
(function() {
  "use strict";
  define(function() {
    var AbstractObject;
    return AbstractObject = (function() {
      function AbstractObject(options) {
        if (options == null) {
          options = {};
        }
        this.parent = options.parent || document.body;
        this.childrens = [];
      }

      AbstractObject.prototype.get = function(childName) {
        var index;
        index = this.index(childName);
        if (index === -1) {
          return false;
        }
        return this.childrens[index];
      };

      AbstractObject.prototype.remove = function(childName) {
        var index;
        index = this.index(childName);
        if (index === -1) {
          return false;
        }
        this.childrens.splice(index, 1);
        return true;
      };

      AbstractObject.prototype.rename = function(oldName, newName) {
        var index;
        index = this.index(oldName);
        if (index === -1) {
          return false;
        }
        this.childrens[index].name = newName;
        return true;
      };

      AbstractObject.prototype.index = function(childName) {
        var result;
        result = -1;
        this.childrens.some(function(child, index) {
          var flag;
          flag = child.name === childName;
          if (flag) {
            result = index;
          }
          return flag;
        });
        return result;
      };

      AbstractObject.prototype.point = function(value1, value2) {
        if (value1 == null) {
          return [0, 0];
        }
        if (value2 != null) {
          return [this.number(value1), this.number(value2)];
        }
        if (Array.isArray(value1)) {
          return [this.number(value1[0]), this.number(value1[1])];
        } else {
          if ((value1.x != null) && (value1.y != null)) {
            return [this.number(value1.x), this.number(value1.y)];
          }
          if ((value1.width != null) && (value1.height != null)) {
            return [this.number(value1.width), this.number(value1.height)];
          }
          return [0, 0];
        }
      };

      AbstractObject.prototype.pixel = function(value1, value2) {
        var result;
        result = this.point(value1, value2);
        return [result[0] >> 0, result[1] >> 0];
      };

      AbstractObject.prototype.int = function(value) {
        return this.number(value) >> 0;
      };

      AbstractObject.prototype.number = function(value) {
        if (value != null) {
          return +value;
        } else {
          return 0;
        }
      };

      AbstractObject.prototype.deg2rad = function(value) {
        return this.number(value) * this._PIDIV180;
      };

      AbstractObject.prototype._PIDIV180 = Math.PI / 180;

      return AbstractObject;

    })();
  });

}).call(this);
