"use strict";

requirejs.config({
	
	baseUrl: "../../js"

});

requirejs(["CanvasEngine"], function(CanvasEngine){

	var CE = new CanvasEngine({

		parent: document.getElementById("main"),
		position: [20, 30]

	});

	var scene = CE.add({

		name: "scene1",
		position: [50, 40]

	});

	var image = scene.add({

		type: "image",
		src: "../flower.png",
		position: [50, 50],

	});

	var image2 = scene.add({

		type: "image",
		src: "../flower.png",
		position: [500, 50]

	});

	CE.parent.addEventListener("mousemove", function(e){

		if (image.testRect(e.pageX, e.pageY)) {

			image.shadow = {

				color: "#000",
				blur: 3

			};

		} else {

			image.shadow = false;

		}

		// 
		// ВНИМАНИЕ!
		// использовать этот метод ЛОКАЛЬНО нужно осторожно, так как
		// в браузерах на основе chrome будет возникать ошибка безопасности
		// (как будто пытаешься загрузить изображение с другого хоста).
		// При загрузке кода на сервер работает во всех браузерах.
		// 
		
		if (image2.testRect(e.pageX, e.pageY) && image2.testPoint(e.pageX, e.pageY)) {

			image2.shadow = {

				color: "#000",
				blur: 3

			};

		} else {

			image2.shadow = false;

		}

	});

});