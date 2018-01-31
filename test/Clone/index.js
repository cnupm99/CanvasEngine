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

	var counter = 1;
	
	document.body.addEventListener("click", function(e){

		var scene = CE.add({

			type: "scene",
			name: "scene" + counter,
			position: [counter * 50, counter * 50]

		});

		scene.clone(image);

		counter++;

		CE.get("default").clear();
		image = null;

		console.log(CE.childrens);

	});

});