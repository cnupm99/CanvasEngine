"use strict";

requirejs.config({
	
	baseUrl: "../../bin"

});

requirejs(["CanvasEngine", "../utils/ProgressBar/ProgressBar"], function(CanvasEngine, ProgressBar) {

	// создаем движок
	var ce = new CanvasEngine({

		sizes: [1000, 800]

	});

	// создали сцену
	var scene = ce.add({

		type: "scene",
		name: "scene"

	});

	

});