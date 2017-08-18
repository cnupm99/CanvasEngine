@echo Build coffee
node build.js
@pause
@echo Compile coffee
call coffee -c CanvasEngine.coffee
@pause
@echo Minify js file
node minify.js
@echo Complite!
@pause