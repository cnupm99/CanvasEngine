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

	var t = CE.add({

		type: "tile",
		src: "../wall.png",

	});

	var t2 = CE.add({

		type: "tile",
		src: "../flower.png",
		rect: [100, 100, 500, 300]

	});

	console.log(t);
	console.log(t2);

});