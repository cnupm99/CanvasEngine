"use strict";

requirejs.config({
	
	baseUrl: "../../bin"

});

requirejs(["CanvasEngine", "../utils/ProgressBar/ProgressBar"], function(CanvasEngine, ProgressBar) {

	// создаем движок
	var ce = new CanvasEngine({

		sizes: [1000, 800]

	});

	// создали сцену
	var scene = ce.add({

		type: "scene",
		name: "scene"

	});

	// прогресс бар по умолчанию
	var pb = new ProgressBar({

		scene: scene,
		position: [100, 100],
		progress: 80,
		showCaption: true,
		caption: "Загрузка: "

	});

	var pb2 = new ProgressBar({

		scene: scene,
		position: [100, 200],
		sizes: [250, 20],
		progress: 0,
		showCaption: false,
		showProgress: false

	});

	var counter = 0;

	ce.addEvent(function(){

		counter++;

		if (counter % 10 == 0) {

			var progress = pb.getProgress();
			progress++;
			if(progress > 100) progress = 0;
			pb.progress(progress);

		}
		if (counter % 2 == 0) {

			var progress = pb2.getProgress();
			progress++;
			if(progress > 100) progress = 0;
			pb2.progress(progress);

		}

	});

});