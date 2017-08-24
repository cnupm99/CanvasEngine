"use strict";

requirejs.config({
	
	// baseUrl: "../../js"
	baseUrl: "../../bin"

});

// requirejs(["CanvasEngine", "../utils/FPS/FPS"], function(CanvasEngine, FPS) {
requirejs(["CanvasEngine.min", "../utils/FPS/FPS"], function(CanvasEngine, FPS) {

	// создаем движок
	var ce = new CanvasEngine({

		size: [1000, 800]

	});

	var f = new FPS(ce, [5, 5]);

	// создали сцену
	var scene = ce.add({

		type: "scene",
		name: "scene"

	});

	var count = 100;

	for(var i = 0; i < count; i++) {

		var position = [Math.round(1000 * Math.random()), Math.round(800 * Math.random())],
			rotation = Math.round(360 * Math.random()),
			kind = 1 + Math.round(3 * Math.random());

		scene.add({

			type: "image",
			src: "../star_" + kind + ".png",
			position: position,
			rotation: rotation,
			anchor: [0.5, 0.5]

		});

	}

	ce.addEvent(function(){

		scene.childrens.forEach(function(child){

			child.rotateOn(1);

		});

	});

});