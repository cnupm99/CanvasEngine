var 

	// путь к файлам
	INPUT_PATH = "../coffee/",
	// итоговый файл
	OUTPUT = "CanvasEngine.coffee",
	// список файлов в нужной последоватлености
	FILES = [
		"AbstractObject",
		"DisplayObject",
		"ContainerObject",
		"Graph",
		"Image",
		"Text",
		"TilingImage",
		"Scene",
		"CanvasEngine"
	],
	// файл с номером версии
	VERSION_FILE = "version.txt",

	// подключаем модуль для чтения/записи файлов
	fs = require("fs"),

	// читаем файл версии
	versionFile = fs.readFileSync(VERSION_FILE, "utf8"),
	// получаем номер билда
	versionData = versionFile.split("\n"),
	version = versionData[0].trim(),
	build = versionData[1].split(" "),
	date = new Date();

// вычисляем номер билда
build = +build[1].trim();
build++;

// сохраняем номер версии
var	versionText = versionData[0].trim() + "\r\nbuild " + build + "\r\n" + date.toDateString();
console.log(versionText);
fs.writeFileSync(VERSION_FILE, versionText, "utf8");

// начальный текст
var text = "#\r\n# CanvasEngine\r\n#\r\n# " + versionData[0].trim() + "\r\n# build " + build + "\r\n# " + date.toDateString() + "\r\n#\r\n\r\n";

// перебор файлов
for(var i = 0; i < FILES.length; i++) {

	console.log("read file: " + FILES[i]);

	var script = fs.readFileSync(INPUT_PATH + FILES[i] + ".coffee", "utf8");
	if(i > 0){

		var arr = script.split("\r\n");
		arr.shift();
		arr.shift();
		arr.shift();
		arr.shift();
		script = arr.join("\r\n");
		script = "\r\n\r\n" + script

	}
	text += script;

}

// заключительный текст
text += "\r\n\r\n\t#\r\n\t# Возвращаем результат\r\n\t#\r\n\treturn CanvasEngine";

// создаем выходной файл
fs.writeFileSync(OUTPUT, text, "utf8");

// сообщение
console.log(OUTPUT + " created\n");