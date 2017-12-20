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

	// текст с толстой обводкой и заливкой градиентом
	var text = CE.add({

		type: "text",
		text: "Hello, World!",
		font: "80px Helvetica",
		fillStyle: [[0, "#F00"], [1, "#000"]],
		strokeStyle: "#0000FF",
		strokeWidth: 3

	});

	text.move([(CE.size[0] - text.textWidth) / 2, 200]);

	console.log(text.realSize);
	console.log(text.fontHeight, text.textWidth, text.textHeight);

	var text2 = CE.add({

		type: "text",
		text: "More then one\nline text!",
		font: "40px Helvetica",
		fillStyle: "#000",
		position: [50, 50]

	});

	console.log(text2.realSize);
	console.log(text2.fontHeight, text2.textWidth, text2.textHeight);

	var text3 = CE.add({

		type: "text",
		text: "More then one\nline text with\nUNDERLINE",
		font: "20px Helvetica",
		fillStyle: "#000",
		underline: true,
		position: [50, 200]

	});

});