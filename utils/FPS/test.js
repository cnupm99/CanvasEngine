"use strict";

requirejs.config({
	
	baseUrl: "../../bin"

});

requirejs(["CanvasEngine"], function(CanvasEngine) {

	// создаем движок
	var ce = new CanvasEngine({

		sizes: [1000, 800],
		showFPS: true

	});

	// создали сцену
	var scene = ce.add({

		type: "scene",
		name: "scene"

	});

	var count = 1000,
		rotation = 0;

	for(var i = 0; i < count; i++) {

		var position = [Math.round(1000 * Math.random()), Math.round(800 * Math.random())],
			kind = 1 + Math.round(3 * Math.random());

		scene.add({

			type: "image",
			src: "../star_" + kind + ".png",
			position: position,
			rotation: rotation,
			center: [12, 12]

		});

	}

	ce.addEvent(function(){

		scene.objects.forEach(function(child){

			rotation++;
			child.setRotation(rotation / 180 * Math.PI);

		});

	});

});