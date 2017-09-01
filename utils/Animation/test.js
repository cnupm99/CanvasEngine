"use strict";

requirejs.config({
	
	baseUrl: "../../bin"

});

requirejs(["CanvasEngine.min", "../utils/Dust/ImagesLoader", "../utils/FPS/FPS", "../utils/Animation/Animation"], function(CanvasEngine, ImagesLoader, FPS, Animation) {

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

	var il = new ImagesLoader("");
	il.loadList([

		{
			name: "m1",
			src: "mouse_1.png"
		},
		{
			name: "m2",
			src: "mouse_3.png"
		},
		{
			name: "glaz",
			src: "glaz.jpg"
		},
		{
			name: "cat",
			src: "cat.png"
		}

	], function(total, loaded, images){

		// 
		// анимация через список картинок
		// 
		var a1 = new Animation(ce, {

			from: [images.m1.image, images.m2.image],
			position: [100, 100],
			slowing: 30

		});

		// 
		// анимация через список ссылок
		// НЕ рекомендуется из-за мигания при загрузке картинок
		// 
		var a2 = new Animation(ce, {

			src: ["mouse_4.png", "mouse_5.png"],
			position: [100, 200],
			slowing: 60

		});

		// 
		// анимация через набор прямоугольных нарезок из картинки
		// 
		var a3 = new Animation(ce, {

			from: images.glaz.image,
			position: [100, 300],
			frameSet:[
				[0, 0, 517, 166],
				[0, 166, 517, 166]
			],
			size: [517, 166],
			intervals: [60, 10]

		});

		// 
		// анимация через ширину или количество кадров
		// 
		var a4 = new Animation(ce, {

			from: images.cat.image,
			position: [100, 500],
			slowing: 5,
			frameCount: 5

		});

	});

});