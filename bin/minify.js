var fs = require("fs");

var code = fs.readFileSync("CanvasEngine.js", "utf8");

var request = require("d:/Дистрибутивы/nodejs/node_modules/request/");
request.post({url:"http://closure-compiler.appspot.com/compile", form:{

	"js_code":code,
	"compilation_level":"SIMPLE_OPTIMIZATIONS",
	"output_format":"text",
	"output_info": "compiled_code"

}}, function (error, response, body) {
	
	console.log('error:', error);
	console.log('statusCode:', response && response.statusCode);

	var versionFile = fs.readFileSync("version.txt", "utf8"),
		// получаем номер билда
		versionData = versionFile.split("\n"),
		version = versionData[0].trim(),
		build = versionData[1].split(" "),
		date = new Date();

	// вычисляем номер билда
	build = +build[1].trim();

	// сохраняем номер версии
	var	versionText = "// " + versionData[0].trim() + ", build " + build + ", " + date.toDateString() + "\r\n"

	// итоговый текст
	body = versionText + body.trim();
	
	fs.writeFileSync("CanvasEngine.min.js", body, "utf8");

});