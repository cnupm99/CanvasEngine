"use strict";

requirejs.config({
	
	baseUrl: "../../js"

});

requirejs(["AbstractObject"], function(AO){

	var a = new AO({

		center: [200, 200]

	});

	console.log(a);

	console.log(a.int(3.14));
	console.log(a.int(-3.1456));

});