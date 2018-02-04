"use strict";

requirejs.config({
	
	baseUrl: "../../js"
	// baseUrl: "../../bin"

});

requirejs(["CanvasEngine"], function(CanvasEngine){
// requirejs(["CanvasEngine.min"], function(CanvasEngine){

	var CE = new CanvasEngine({

		parent: document.getElementById("main")

	});

	// текст с толстой обводкой и заливкой градиентом
	var text = CE.add({

		type: "text",
		text: "Hello,\nWorld!",
		font: "80px Helvetica",
		fillStyle: [[0, "#F00"], [1, "#000"]],
		strokeStyle: "#0000FF",
		strokeWidth: 5

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
		underlineOffset: 5,
		position: [50, 200],
		baseline: "middle"

	});

	var text4 = CE.add({

		type: "text",
		text: "Зачеркнутый текст",
		font: "20px Helvetica",
		fillStyle: "#000",
		underline: true,
		underlineOffset: -5,
		position: [50, 300],
		baseline: "bottom"

	});

	var scene2 = CE.add({

		type: "scene",
		name: "scene2"

	});

	var graph = scene2.add({

		type: "graph"

	});

	graph.strokeStyle("#F00");
	graph.line(500, 50, 800, 50);
	graph.line(500, 100, 800, 100);

	var centered = scene2.add({

		type: "text",
		font: "20px Arial",
		text: "Centered\nTEXT",
		fillStyle: "#000",
		baseline: "top",
		position: [500, 50]

	});

	console.log(centered.textHeight, centered.fontHeight);

	centered.move([500 + (300 - centered.textWidth) / 2, 50 + (50 - centered.textHeight) / 2]);

	graph.rect(text.position[0], text.position[1], text.textWidth, text.textHeight);
	graph.stroke();

});