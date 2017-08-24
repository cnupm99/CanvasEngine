"use strict";

requirejs.config({
	
	baseUrl: "../../bin"

});

requirejs(["CanvasEngine.min", "../utils/FPS/FPS"], function(CanvasEngine, FPS) {

	// создаем движок
	var ce = new CanvasEngine({

		size: [1000, 800]

	});

	var f = new FPS(ce, [5, 5]);

});