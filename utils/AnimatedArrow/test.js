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

	var ar = new AnimatedArrow(ce, {

		scene: scene,
		from: [500, 400],
		to: [100, 100]

	});

	var graph = scene.add({ type:"graph" });
	graph.fillStyle("#000");
	graph.rect(95, 95, 10, 10);
	graph.fill();
	graph.rect(495, 395, 10, 10);
	graph.fill();

	scene.canvas.addEventListener("mousemove", function(e){

		ar.setTo([e.pageX, e.pageY]);

	});
	scene.canvas.addEventListener("mouseout", function(e){

		ar.setTo([100, 100]);

	});

});