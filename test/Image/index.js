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

	var image = CE.add({

		type: "image",
		src: "../flower.png",
		position: [150, 150],
		anchor: [0.5, 0.5]

	});

	var scale = 1,
		ds = 0.01;

	CE.addEvent(function(){

		image.rotateOn(1);

		scale += ds;
		if ((scale > 1.2) || (scale < 0.5)) {

			ds = -ds;

		}
		image.zoom([scale, scale]);

	});

	console.log(image);

	var image2 = CE.add({

		type: "image",
		src: "../flower.png",
		size: [100, 100],
		position: [500, 100],
		// anchor: [0.5, 0.5],
		center: [50, 50]

	});

	CE.addEvent(function(){

		image2.rotateOn(1);

	});

});