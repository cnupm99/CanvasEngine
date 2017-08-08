"use strict";

requirejs.config({
	
	baseUrl: "../../js"

});

requirejs(["AbstractObject"], function(AO){

	var a = new AO();

	console.log(a);

	console.log(a.position);

	a.position = {

		x: 200,
		y: 150

	}

	console.log(a.position);

});