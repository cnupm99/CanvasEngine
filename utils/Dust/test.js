"use strict";

requirejs.config({
	
	baseUrl: "../../bin"

});

requirejs(["CanvasEngine.min", "../utils/Dust/Dust", "../utils/Dust/ImagesLoader", "../utils/FPS/FPS"], function(CanvasEngine, Dust, ImagesLoader, FPS) {

	// создаем движок
	var ce = new CanvasEngine({

		size: [1000, 800]

	});

	var fps = new FPS(ce, [5, 5]);

	// создали сцену
	var scene = ce.add({

		type: "scene",
		name: "scene"

	});

	var dust = new Dust(ce);

	var il = new ImagesLoader("../");
	il.loadList([

		{
			name: "star_1",
			src: "star_1.png"
		},
		{
			name: "star_2",
			src: "star_2.png"
		},
		{
			name: "star_3",
			src: "star_3.png"
		},
		{
			name: "star_4",
			src: "star_4.png"
		}

	], function(total, loaded, images){

		scene.canvas.addEventListener("click", function(e){

			dust.add({

				scene: scene,
				position: [e.pageX, e.pageY],
				from: images["star_1"].image,
				beginScale: 0.1,
				endScale: 0.3,
				endRadius: 10,
				hideRadius: 20,
				gravitation: 1,
				speed: 2,
				speedRand: 0

			});

		});

		setInterval(function(){

			var type = 1 + Math.floor(Math.random() * 4);

			dust.add({

				scene: scene,
				position: [1000 * Math.random(), 800 * Math.random()],
				from: images["star_" + type].image,

			});

		}, 250);

	});

});