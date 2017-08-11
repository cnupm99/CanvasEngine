"use strict";

requirejs.config({
	
	baseUrl: "../../js"

});

requirejs(["Scene"], function(Scene){

	var a = new Scene({

		name: "Scene1",
		position: [300, 50],
		center: [50, 50],
		rotation: 45,
		size: [100, 100]

	});

	a.context.fillStyle = "#000";
	a.context.rect(0, 0, a.size[0], a.size[1]);
	a.context.fill();

	console.log(a);

	console.log(a.position);

	console.log(a.size);

});