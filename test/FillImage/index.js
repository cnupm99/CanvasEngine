"use strict";

requirejs.config({
	
	// baseUrl: "../../js"
	baseUrl: "../../bin"

});

// requirejs(["CanvasEngine"], function(CanvasEngine){
requirejs(["CanvasEngine.min"], function(CanvasEngine){

	var CE = new CanvasEngine({

		parent: document.getElementById("main")

	});

	var graph = CE.add({

		type: "graph",
		position: [50, 50],
		size: [100, 100]

	});

	var img = new Image();
	img.onload = function() {

		let p = graph.context.createPattern(img, "repeat");
		graph.fillStyle(p);
		graph.strokeStyle("rgba(0,0,0,0.9)");
		graph.lineWidth(8);
		graph.circle(50, 50, 50);
		graph.stroke();
		graph.fill();

	};
	img.src = "test.jpg";

});