"use strict";

requirejs.config({
	
	baseUrl: "../../bin"

});

requirejs(["CanvasEngine", "../utils/Mouse/Mouse"], function(CanvasEngine, Mouse) {

	// создаем движок
	var ce = new CanvasEngine({

		parent: document.getElementById("main"),
		sizes: [1000, 800]

	});

	// создали сцену
	var scene = ce.add({

		type: "scene",
		name: "scene",
		position: [50, 50]

	});

	var graph = scene.add({

		type: "graph",
		position: [100, 100],
		sizes: [200, 50]

	});

	graph.rect(0, 0, 200, 50);
	graph.fill();

	var mouse = new Mouse(document.getElementById("main"));
	mouse.add(graph, "mouseover", function(){

		graph.clear();
		graph.fillStyle("#555");
		graph.rect(0, 0, 200, 50);
		graph.fill();
		graph.setShadow({Blur:10});
		mouse.setCursor("pointer");

	});
	mouse.add(graph, "mouseout", function(){

		graph.clear();
		graph.fillStyle("#000");
		graph.rect(0, 0, 200, 50);
		graph.fill();
		graph.setShadow();
		mouse.setCursor("default");

	});
	mouse.add(graph, "mousedown", function(){

		console.log("down");

	});
	mouse.add(graph, "mouseup", function(){

		console.log("up");

	});
	mouse.add(graph, "click", function(){

		console.log("click");

	});

});