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

	CE.addEvent(function(){

		image.rotation++;

	});

	console.log(image);

});