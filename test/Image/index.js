"use strict";

requirejs.config({
	
	baseUrl: "../../js"

});

requirejs(["CanvasEngine"], function(CanvasEngine){

	var CE = new CanvasEngine({

		parent: document.getElementById("main")

	});

	var image = CE.add({

		type: "image",
		src: "../flower.png",
		position: [50, 50],
		anchor: [0.5, 0.5]

	});

	var scale = 1,
		ds = 0.01;

	CE.addEvent(function(){

		image.rotation++;

		scale += ds;
		if ((scale > 1.2) || (scale < 0.5)) {

			ds = -ds;

		}
		image.scale = [scale, scale];

	});

	console.log(image);

});