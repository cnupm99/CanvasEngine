"use strict";

requirejs.config({
	
	baseUrl: "../../js"

});

requirejs(["CanvasEngine"], function(CanvasEngine){

	var CE = new CanvasEngine({

		parent: document.getElementById("main")

	});

	// текст с толстой обводкой и заливкой градиентом
	var text = CE.add({

		type: "text",
		text: "Hello, World!",
		font: "80px Helvetica",
		fillStyle: [[0, "#F00"], [1, "#000"]],
		strokeStyle: "#0000FF",
		strokeWidth: 3

	});

	text.position = [(CE.size[0] - text.textWidth) / 2, 200];

});