"use strict";

requirejs.config({
	
	baseUrl: "../../bin"

});

requirejs(["CanvasEngine.min", "../utils/ProgressBar/ProgressBar"], function(CanvasEngine, ProgressBar) {

	var isFirefox, isGecko, isOpera, ua;
	ua = typeof navigator !== "undefined" ? navigator.userAgent || '' : '';
	isFirefox = /firefox|iceweasel|fxios/i.test(ua);
	isOpera = (/opera/i.test(ua)) || (/opr\/|opios/i.test(ua));
	isGecko = (/gecko\//i.test(ua)) && !isOpera;
	window["FIREFIX"] = isFirefox || isGecko;

	// создаем движок
	var ce = new CanvasEngine({

		size: [1000, 800]

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

	// одноцветный невысокий бар без надписи
	var pb2 = new ProgressBar({

		scene: scene,
		position: [100, 200],
		size: [250, 20],
		progress: 0,
		showCaption: false,
		showProgress: false,
		singleColor: true

	});

	// кастомный бар с картинкой для фона
	// и отображением общего числа
	var pb3 = new ProgressBar({

		scene: scene,
		position: [100, 300],
		size: [189, 36],
		padding: 7,
		radius: 0,
		value: 0,
		showCaption: false,
		maxValue: 10000,
		backgroundImage: "back.png",
		font: "14px Arial",
		singleColor: true,
		colors: {
			progress: ["#05E0F3", "#023064"],
			caption: "#FFF",
			captionStroke: "#000"
		}

	});

	// кастомный бар с картинкой для фона
	// и отображением общего числа
	var pb4 = new ProgressBar({

		scene: scene,
		position: [100, 400],
		size: [570, 100],
		padding: [37, 27],
		radius: 2,
		value: 0,
		showCaption: true,
		showTotal: true,
		maxValue: 59,
		backgroundImage: "progressbar.png",
		font: "20px Arial",
		colors: {

			progress25: ["#FF0000", "#800000"],
			progress100: ["#00FF00", "#008000"],
			// progress50: ["#EFE683", "#feb645"],
			// progress50: ["#FF0000", "#800000"],
			progress50: ["#f2d31b", "#E3C40C"],
			progress75: ["#f2d31b", "#E3C40C"]

		}

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

		var value = pb3.getValue();
		value++;
		if (value > 10000) value = 0;
		pb3.value(value);

		var value = pb4.getValue();
		value++;
		if (value > 59) value = 0;
		pb4.value(value);

	});

});