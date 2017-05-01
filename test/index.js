"use strict";

requirejs.config({
	
	baseUrl: "../bin"
	// baseUrl: "../js"

});

requirejs(["CanvasEngine"], function(o){

	// создаем движок
	var ce = new CanvasEngine({

		sizes: [1000, 800]

	});

	// замостим фон кирпичами,
	// сцена по умолчанию - default
	ce.add({

		type: "tile",
		src: "wall.png"

	});

	// создаем сцену
	var scene1 = ce.add({

		type: "scene",
		name: "scene1",
		zIndex: 10

	});

	// картинка на сцене
	var image = ce.add({

		type: "image",
		src: "flower.png",
		position: [200, 200],
		center: [150, 150]

	});

	// ВНИМАНИЕ!
	// В браузере firefox есть баг (на 25.04.17), а именно:
	// при попытке нарисовать на канве изображение, используя одновременно
	// маску и тень (setMask and setShadow в данном случае), получается
	// странная хрень, а точнее маска НЕ работает в данном случае.
	// Доказательство и пример здесь: http://codepen.io/cnupm99/pen/wdGKBO

	// добавим картинке тень
	image.setShadow({

		blur: 20

	});

	// добавим на сцену маску
	scene1.setMask(250, 250, 200, 200);

	var shadow = false;

	// так можно обратиться напрямую к канвасу
	// и добавить событие
	scene1.canvas.addEventListener("mousemove", function(e){

		// ВНИМАНИЕ!
		// использовать этот метод ЛОКАЛЬНО нужно осторожно, так как
		// в браузерах на основе chrome будет возникать ошибка безопасности
		// (как будто пытаешься загрузить изображение с другого хоста).
		// В firefox работает и локально без проблем.
		// При загрузке кода на сервер работает во всех браузерах.

		if(scene1.testPoint(e.clientX, e.clientY)) {

			document.body.style.cursor = "pointer";
			
			if (!shadow) {

				image.setShadow({});
				shadow = true;

			}

		} else {

			document.body.style.cursor = "default";
			
			if (shadow) {

				image.setShadow();
				shadow = false;

			}

		}

	});

	// создаем графический объект,
	// одновременно создается новая сцена
	var graph = ce.add({

		type: "graph",
		scene: "scene2"

	});

	// создаем графический объект,
	// автоматически добавляется на активную сцену,
	// в данном случае на scene2
	var graph2 = ce.add({

		type: "graph",
		position: [700, 500]

	});

	// рисуем прямоугольник с тенью и скругленными углами
	graph2.fillStyle("#888800");
	graph2.setShadow({
		color: "#888800",
		blur: 30
	});
	graph2.rect(0, 0, 100, 100, 10);
	graph2.fill()

	var counter = 0;

	// добавляем функцию в цикл анимации
	ce.addEvent(function(){

		// а тут мы рисуем многоугольник
		// с пунктирными анимированными границами
		counter++;
		if (counter % 2 == 0) {

			graph.clear();
			graph.fillStyle("#009900");
			graph.strokeStyle("#005555");
			graph.lineWidth(10);
			graph.setLineDash([20, 20]);
			graph.lineDashOffset(counter);
			graph.polygon([
				[300, 20],
				[650, 50],
				[400, 150],
				[290, 130]
			]);

		}

		if (counter > 360) {

			counter = 0;

		}

	});

});