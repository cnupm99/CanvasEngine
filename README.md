# CanvasEngine

Simple Canvas Engine for javascript / coffeescript

## Подключение

    requirejs(["CanvasEngine"], function(CanvasEngine) {
        //
        // code
        //
    });

или

    define(["CanvasEngine"], function(CanvasEngine) {
        //
        // code
        //
    });

## Создание

По умолчанию parent = document.body
Размеры, если не указаны отдельно, равны размеру parent

    var ce = new CanvasEngine();

Можно задать опции:

    var ce = new CanvasEngine({
        parent: document.getElementById("main")
    });

Также доступны опции: **visible, position, size, center, rotation, alpha, mask, shadow**. В данном случае они имеют только тот смысл, что они будут установлены как значения по умолчанию для сцен.

Если браузер не поддерживает canvas/context, то ce = false, также будет сообщение в консоли.

## Цикл анимации

Цикл анимации запускается автоматически. Остановить/запустить его в ручную можно командами ce.**stop()**, ce.**start()**

Добавить/удалить свою функцию в цикл анимации:

    ce.addEvent(myFunction);
    ce.removeEvent(myFunction);

Такие функции выполняются *ПЕРЕД* анимацией.

## Сцены

Все рисуется на сценах. По умолчанию создается сцена с именем default.

Если при создании объекта не указать сцену, то он будет добавлен на активную сцену. При создании сцены она становится активной.

Получить сцену:

    ce.get("default");

Создать сцену:

    ce.add({
        type: "scene", // не обязательно, если тип не указан, то будет создана сцена
        name: "myScene"
    });

Установить/получить активную сцену:

    ce.getActive();
    ce.setActive("otherScene");

Очередность отображения сцен определяется опцией **zIndex**. Чем больше **zIndex**, тем выше сцена относительно других. Показывать сцену поверх всех остальных можно методом **onTop**:

    ce.onTop("myScene");

Переименовать сцену:

    ce.rename("oldName", "newName");

Удалить сцену:

    ce.remove("myScene");

## Добавление объектов на экран

Замостить область (в данном случае весь parent):

    ce.add({
        type: "tile",
        src: "wall.png"
    });

Объект будет добавлен на активную сцену. Указать сцену можно явно:

    ce.add({
        type: "image",
        scene: "myScene",
        src: "flower.png",
        position: [200, 200],
        center: [150, 150]
    });

Либо работать непосредственно со сценой:

    var scene = ce.add({
        name: "myScene"
    });
    var text = scene.add({
        type: "text",
        text: "Hello, World!",
        font: "50px Arial",
        fillStyle: "#000"
    });
    // Центрируем текст на сцене по горизонтали
    text.move((scene.size[0] - text.textWidth)/2, 50);

## API

### CanvasEngine:

- **parent**:Element - элемент для отрисовки движка
- **add**(options):DisplayObject - метод для добавления новых объектов / сцен
- **remove**(childName):Boolean - удаляем сцену
- **onTop**(childName):Scene/Boolean - поднимаем сцену на верх отображения
- **getActive**():Scene/Boolean - получить активную сцену
- **setActive**(sceneName:String):Scene - установить активную сцену по имени
- **start**() - запускаем цикл анимации
- **stop**() - останавливаем цикл анимации
- **addEvent**(func) - добавить функцию, выполняемую каждый раз перед анимацией
- **removeEvent**(func) - удалить функцию из цикла анимации
- **canvasSupport**():Boolean - проверка, поддерживает ли браузер canvas и context

### Общие свойства/методы экранных объектов:

- **name**:String - имя объекта для его идентификации
- **type**:String - тип объекта
- **canvas**:Canvas - канвас для рисования
- **context**:Context2d - контекст для рисования
- **visible**:Boolean - видимость объекта, устанавливаемая пользователем
- **position**:Array - позиция объекта
- **size**:Array - размер объекта
- **realSize**:Array - реальный размер объкта
- **center**:Array - относительные координаты точки центра объекта, вокруг которой происходит вращение
- **anchor**:Array - дробное число, показывающее, где должен находиться цент относительно размеров объекта
- **scale**:Array - коэффициенты для масштабирования объектов
- **rotation**:int - число в градусах, на которое объект повернут вокруг центра по часовой стрелке
- **alpha**:Number - прозрачность объекта
- **shadow**:Object - тень объекта
- **needAnimation**: Boolean - сообщает движку, нужно ли анимировать объект
- **set**(value:Object) - установка сразу нескольких свойств
- **show**():Boolean - 
- **hide**():Boolean - 
- **move**(value1, value2:int):Array - изменить позицию объекта
- **shift**(deltaX, deltaY:int):Array - сдвигаем объект на нужное смещение по осям
- **resize**(value1, value2:int):Array - изменить размер объекта
- **upsize**(value1, value2:int):Array - обновить реальные размеры объекта
- **setCenter**(value1, value2: int):Array - установить новый центр объекта
- **setAnchor**(value1, value2: Number):Array - установить новый якорь объекта
- **zoom**(value1, value2:Number):Array - установить масштаб объекта
- **rotate**(value:int):int - установить угол поворота объекта
- **rotateOn**(value:int):int - повернуть объект на угол относительно текщего
- **setAlpha**(value:Number):Number - установить прозрачность объекта
- **setShadow**(value:Object): Object - установить тень объекта
- **testPoint**(pointX, pointY:int):Boolean - проверка, пуста ли данная точка
- **testRect**(pointX, pointY:int):Boolean - проверка, входит ли точка в прямоугольник объекта
- **needAnimation**:Boolean - нужно ли анимировать данный объект с точки зрения движка
- **getOptions**() - возвращаем объект с текущими опциями фигуры

### Scene:

- **zIndex**:int - индекс, определяющий порядок сцен, чем выше индекс, тем выше сцена над остальными
- **mask**:Array - маска объекта
- **add**(data:Object):DisplayObject - добавление дочернего объекта
- **clone**(anotherObject:DisplayObject):DisplayObject - клонирование графического объекта
- **clear**() - полная очистка сцены
- **get**(childName:String):Object/false - поиск среди дочерних элементов по имени элемента
- **remove**(childName:String):Boolean - удаление дочернего элемента по его имени
- **rename**(oldName, newName:String):Boolean - переименование дочернего элемента
- **index**(childName:String):int - возвращает индекс элемента в массиве дочерних по его имени
- **setMask**(value:Object):Object - установка маски
- **setZIndex**(value:int):int - установка зед индекса канваса
- **shiftAll**(value1, value2:int) - сдвигаем все дочерные объекты

### Image

- **onload**:Function - ссылка на функцию, которая должна выполниться после загрузки картинки
- **loaded**:Boolean - загружена ли картинка
- **image**:Image - объект картинки
- **loadedFrom**:String - строка с адресом картинки
- **rect**:Array - прямоугольник для отображения части картинки
- **src**(url:string): загрузка картинки с указанным адресом
- **from**(image:Image, url:String) - создание из уже существующей и загруженной картинки
- **setRect**(rect:Array):Array - установка области для отображения только части картинки

### Graph

- **clear**() - очистка экрана и команд
- **beginPath**() - начало отрисовки линии
- **lineCap**(value:String) - установить стиль окончания линий
- **strokeStyle**(style:String) - стиль линий
- **fillStyle**(style:String) - стиль заливки
- **linearGradient**(x1, y1, x2, y2:int, colors:Array) - установка градиента
- **lineWidth**(value:int) - толщина линий
- **setLineDash**(value:int) - установка пунктирной линии
- **lineDashOffset**(value:int) - смещение пунктирной линии
- **moveTo**(x, y:int) - перемещение указателя
- **lineTo**(x, y:int) - линия в указанную точку
- **line**(x1, y1, x2, y2:int) - рисуем линию по двум точкам
- **rect**(x, y, width, height, radius:int) - рисуем прямоугольник (опционально скругленный)
- **circle**(x, y, radius:int) - рисуем круг
- **arc**(x, y, radius:int, beginAngle, endAngle:number, antiClockWise:Boolean) - нарисовать дугу
- **polyline**(points:Array, needDraw:Boolean) - полилиния
- **polygon**(points:Array) - полигон
- **fill**() - заливка фигуры
- **stroke**() - прорисовка контура
- **log**() - выводим массив комманд в консоль

### Text

- **fontHeight**:int - высота шрифта
- **textWidth**:int - ширина текущего текста
- **textHeight**:int - высота текущего текста
- **realSize**:Array - размеры области текущего текста с учетом шрифта и многострочности
- **font**:String - текущий шрифт
- **fillStyle**:String/Array/Boolean - текущая заливка, градиент или false, если заливка не нужна
- **strokeStyle**:String/Boolean - обводка шрифта или false, если обводка не нужна
- **strokeWidth**:int - ширина обводки
- **underline**:Boolean - подчеркнутый текст
- **underlineOffset**:int - смещение линии подчеркивания
- **text**:String - отображаемый текст
- **setFont**(font:String):String - установка шрифта
- **setFillStyle**(style:String/Array):String/Array - установка заливки текста
- **setStrokeStyle**(style:String):String - установка обводки
- **setStrokeWidth**(value:int):int - толщина обводки
- **setUnderline**(value:Boolean, offset:int):Boolean - установка подчеркивания текста
- **write**(text:String):String - установка текста

### Tile

- **rect**:Array - прямоугольник для замастивания
- **setRect**(value:Array):Array - установка области