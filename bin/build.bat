@echo Build coffee
node build.js
rem @pause
@echo Compile coffee
call coffee -c CanvasEngine.coffee
rem @pause
@echo Minify js file
node minify.js
@echo Complite!
@pause