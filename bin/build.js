var fs = require("fs"),
	par, inputPath, output, text;

var input = fs.readFileSync("build.txt", "utf8");

params = input.toString().split('\n');
inputPath = params[0].trim();
output = params[1].trim();
text = "#\n#\n# CanvasEngine\n#\n#\n\n";

for(var i = 2; i < params.length; i++) {

	var script = fs.readFileSync(inputPath + params[i].trim() + ".coffee", "utf8");
	if(i > 2){

		var arr = script.split("\n");
		arr.shift();
		arr.shift();
		arr.shift();
		arr.shift();
		script = arr.join("");
		script = "\n\n" + script

	}
	text += script;

}

text += "\n\n\t#\n\t# Возвращаем результат\n\t#\n\treturn CanvasEngine";

fs.writeFileSync(output, text, "utf8");