"use strict";

requirejs.config({
	
	baseUrl: "../../js"

});

requirejs(["CanvasEngine"], function(CanvasEngine){

	var CE = new CanvasEngine({

		parent: document.getElementById("main")

	});

	for(var i = 1; i < 10; i++) {

		var image = CE.add({

			type: "image",
			src: "../flower.png",
			size: [60, 60],
			position: [70 * i, 50],
			alpha: i * 0.1

		});

	}

});