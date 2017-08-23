"use strict";

requirejs.config({
	
	baseUrl: "../../bin"

});

requirejs(["CanvasEngine.min", "../utils/AnimatedArrow/AnimatedArrow", "../utils/FPS/FPS"], function(CanvasEngine, AnimatedArrow, FPS) {

	// создаем движок
	var ce = new CanvasEngine({

		size: [1000, 800]

	});

	var fps = new FPS(ce, [5, 5]);

	// создали сцену
	var scene = ce.add({

		type: "scene",
		name: "scene"

	});

	var ar = new AnimatedArrow({

		scene: scene,
		from: [100, 100],
		to: [500, 500]

	});

});