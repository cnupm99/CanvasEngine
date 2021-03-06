"use strict";

requirejs.config({
	
	// baseUrl: "../../js"
	baseUrl: "../../bin"

});

// requirejs(["CanvasEngine"], function(CanvasEngine){
requirejs(["CanvasEngine.min", "../test/Image/Mouse"], function(CanvasEngine, Mouse){

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

	var image3 = CE.add({

		type: "image",
		src: "../flower.png",
		rect: [0, 0, 100, 100],
		position: [500, 500],
		size: [100, 100]

	});

	var mouse = new Mouse();
	var scene = CE.add({

		type: "scene",
		name: "square",
		size: [500, 500],
		position: [10, 10]

	});

	var image4 = scene.add({

		type: "image",
		src: "../square_1.png",
		position: [10, 200],
		size: [200, 200],
		center: [100, 100]

	});

	mouse.add(image4, "mouseover", function(e){

		image4.setShadow({

			blur: 10

		});
		mouse.setCursor("pointer");

	}, "rect");
	mouse.add(image4, "mouseout", function(e){

		image4.setShadow({});
		mouse.setCursor("default");

	}, "rect");

});