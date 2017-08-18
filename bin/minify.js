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
	
	fs.writeFileSync("CanvasEngine.min.js", body, "utf8");

});