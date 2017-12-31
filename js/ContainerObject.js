// Generated by CoffeeScript 2.0.2
(function() {
  "use strict";
  define(["DisplayObject"], function(DisplayObject) {
    var ContainerObject;
    return ContainerObject = class ContainerObject extends DisplayObject {
      
      // свойства:

      //  childrens:Array - массив дочерних объектов

      // методы:

      //  get(childName:String):Object/false - поиск среди дочерних элементов по имени элемента
      //  remove(childName:String):Boolean - удаление дочернего элемента по его имени
      //  rename(oldName, newName:String):Boolean - переименование дочернего элемента
      //  index(childName:String):int - возвращает индекс элемента в массиве дочерних по его имени

      constructor(options) {
        super(options);
        
        // массив дочерних элементов,
        // для CanvasEngine это Scene
        // для Scene остальные элементы
        // для остальных элементов - массив пустой
        // свойство ТОЛЬКО ДЛЯ ЧТЕНИЯ

        this.childrens = [];
      }

      
      // поиск среди дочерних элементов по имени элемента

      get(childName) {
        var index;
        index = this.index(childName);
        if (index === -1) {
          return false;
        }
        return this.childrens[index];
      }

      
      // удаление дочернего элемента по его имени

      remove(childName) {
        var index;
        index = this.index(childName);
        if (index === -1) {
          return false;
        }
        this.childrens.splice(index, 1);
        this.needAnimation = true;
        return true;
      }

      
      // переименование дочернего элемента

      rename(oldName, newName) {
        var index;
        index = this.index(oldName);
        if (index === -1) {
          return false;
        }
        this.childrens[index].name = newName;
        return true;
      }

      
      // возвращает индекс элемента в массиве дочерних по его имени

      index(childName) {
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
      }

    };
  });

}).call(this);
