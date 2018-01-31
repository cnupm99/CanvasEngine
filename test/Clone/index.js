"use strict";

requirejs.config({
	
	baseUrl: "../../js"
	// baseUrl: "../../bin"

});

requirejs(["CanvasEngine"], function(CanvasEngine){
// requirejs(["CanvasEngine.min", "../test/Image/Mouse"], function(CanvasEngine, Mouse){

	var CE = new CanvasEngine({

		parent: document.getElementById("main")

	});

	var image = CE.add({

		type: "image",
		src: "../flower.png",
		position: [0, 0],
		size: [50, 50]

	});

	var graph = CE.add({type:"graph"});
	graph.fillStyle("rgba(0,0,0,0.7)");
	graph.rect(300, 50, 100, 70);
	graph.fill();

	var counter = 1;
	
	document.body.addEventListener("click", function(e){

		var scene = CE.add({

			type: "scene",
			name: "scene" + counter,
			position: [counter * 50, counter * 50]

		});

		scene.clone(image);
		scene.clone(graph);

		counter++;

		CE.get("default").clear();
		image = null;
		graph = null;

		console.log(CE.childrens);

	});

});