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
		position: [50, 50]

	});

	graph.strokeStyle("#550000");
	graph.fillStyle("#550000");
	graph.lineWidth(5);
	graph.polygon([

		[0, 0],
		[100, 20],
		[20, 100]

	]);
	graph.line(0, 0, 200, 200);
	graph.log();

	var graph2 = CE.add({

		type: "graph",
		position: [50, 50]

	});

	graph2.linearGradient(0, 300, 100, 400, [[0, "#CCC"], [1, "#555"]]);
	graph2.setShadow({
		
		color: "#888800",
		blur: 30

	});
	graph2.rect(0, 300, 100, 100, 10);
	graph2.fill();
	graph2.log();

	var graph3 = CE.add({

		type: "graph",
		position: [50, 50]

	});

	var counter = 0;

	CE.addEvent(function(){

		counter++;

		if (counter % 2 == 0) {

			graph3.clear();
			graph3.strokeStyle("#005555");
			graph3.lineWidth(10);
			graph3.setLineDash([20, 20]);
			graph3.lineDashOffset(counter);
			graph3.polyline([
				[300, 20],
				[650, 50],
				[400, 150]
			], true);

		}

		if (counter > 360) {

			counter = 0;

		}

	});

});