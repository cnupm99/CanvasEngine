(function(){"use strict";define("base",[],function(){var t;return t=function(){function t(t){this._parent=t.parent||document.body,this._rotation=t.rotation||0,this._alpha=t.alpha||1,this._sizes=this._point(t.sizes),this._position=this._point(t.position),this._center=this._point(t.center)}return t.prototype._point=function(t,e){return null==t?[0,0]:null!=e?[this._int(t),this._int(e)]:Array.isArray(t)?[this._int(t[0]),this._int(t[1])]:null!=t.x&&null!=t.y?[this._int(t.x),this._int(t.y)]:null!=t.width&&null!=t.height?[this._int(t.width),this._int(t.height)]:[0,0]},t.prototype._int=function(t){return Math.round(this._value(t))},t.prototype._value=function(t){return null!=t?+t:0},t}()})}).call(this),function(){"use strict";var t=function(t,n){function i(){this.constructor=t}for(var s in n)e.call(n,s)&&(t[s]=n[s]);return i.prototype=n.prototype,t.prototype=new i,t.__super__=n.prototype,t},e={}.hasOwnProperty;define("DisplayObject",["base"],function(e){var n;return n=function(e){function n(t){n.__super__.constructor.call(this,t),this.name=t.name,this._shadow=!1,this.needAnimation=!0}return t(n,e),n.prototype.setTransform=function(t){return this.setSizes(t.sizes),this.setPosition(t.position),this.setCenter(t.center),this.setRotation(t.rotation),this.setAlpha(t.alpha)},n.prototype.setSizes=function(t){return null!=t&&(this._sizes=this._point(t)),this.needAnimation=!0},n.prototype.setPosition=function(t){return null!=t&&(this._position=this._point(t)),this.needAnimation=!0},n.prototype.setCenter=function(t){return null!=t&&(this._center=this._point(t)),this.needAnimation=!0},n.prototype.setRotation=function(t){return null!=t&&(this._rotation=this._value(t)),this.needAnimation=!0},n.prototype.setAlpha=function(t){return null!=t&&(this._alpha=this._value(t)),this.needAnimation=!0},n.prototype.setShadow=function(t){return null!=t?this._shadow={color:t.color||"#000",blur:t.blur||3,offsetX:t.offsetX||0,offsetY:t.offsetY||0,offset:t.offset||0}:this._shadow=!1,this.needAnimation=!0},n.prototype.animate=function(t){return t.save(),this._deltaX=this._position[0],this._deltaY=this._position[1],this._shadow&&(t.shadowColor=this._shadow.color,t.shadowBlur=this._shadow.blur,t.shadowOffsetX=Math.max(this._shadow.offsetX,this._shadow.offset),t.shadowOffsetY=Math.max(this._shadow.offsetY,this._shadow.offset)),0!==this._rotation&&(t.translate(this._center[0]+this._position[0],this._center[1]+this._position[1]),t.rotate(this._rotation*Math.PI/180),this._deltaX=-this._center[0],this._deltaY=-this._center[1]),this.needAnimation=!1},n}(e)})}.call(this),function(){"use strict";var t=function(t,n){function i(){this.constructor=t}for(var s in n)e.call(n,s)&&(t[s]=n[s]);return i.prototype=n.prototype,t.prototype=new i,t.__super__=n.prototype,t},e={}.hasOwnProperty;define("Image",["DisplayObject"],function(e){var n;return n=function(e){function n(t){n.__super__.constructor.call(this,t),this.onload=t.onload,this._realSizes=[100,100],this.needAnimation=!1,this._image=document.createElement("img"),this.setSrc(t.src)}return t(n,e),n.prototype.setSrc=function(t){return this._loaded=!1,this._image.onload=function(t){return function(){if(t._realSizes=[t._image.width,t._image.height],(t._sizes[0]<=0||t._sizes[1]<=0)&&(t._sizes=t._realSizes),t.needAnimation=!0,t._loaded=!0,null!=t.onload)return t.onload(t._realSizes)}}(this),this._image.src=t},n.prototype.getSizes=function(){return this._sizes},n.prototype.getRealSizes=function(){return this._realSizes},n.prototype.animate=function(t){if(this._loaded)return n.__super__.animate.call(this,t),this._sizes[0]===this._realSizes[0]&&this._sizes[1]===this._realSizes[1]?t.drawImage(this._image,this._deltaX,this._deltaY):t.drawImage(this._image,this._deltaX,this._deltaY,this._sizes[0],this._sizes[1]),t.restore(),this.needAnimation=!1},n}(e)})}.call(this),function(){"use strict";var t=function(t,n){function i(){this.constructor=t}for(var s in n)e.call(n,s)&&(t[s]=n[s]);return i.prototype=n.prototype,t.prototype=new i,t.__super__=n.prototype,t},e={}.hasOwnProperty;define("Text",["DisplayObject"],function(e){var n;return n=function(e){function n(t){n.__super__.constructor.call(this,t),this._text=t.text||"",this.setFont(t.font),this._fillStyle=t.fillStyle||!1,this._strokeStyle=t.strokeStyle||!1,this.width=0,this.needAnimation=!0}return t(n,e),n.prototype.setText=function(t){return this._text=t,this.needAnimation=!0},n.prototype.fillStyle=function(t){return this._fillStyle=t||!1,this.needAnimation=!0},n.prototype.strokeStyle=function(t){return this._strokeStyle=t||!1,this.needAnimation=!0},n.prototype.setFont=function(t){var e;return this._font=t||"12px Arial",e=document.createElement("span"),e.appendChild(document.createTextNode("height")),e.style.cssText="font: "+this._font+"; white-space: nowrap; display: inline;",document.body.appendChild(e),this.fontHeight=e.offsetHeight,document.body.removeChild(e),this.needAnimation=!0},n.prototype.animate=function(t){return n.__super__.animate.call(this,t),t.font=this._font,t.textBaseline="top",this._fillStyle&&(t.fillStyle=this._fillStyle,t.fillText(this._text,this._deltaX,this._deltaY)),this._strokeStyle&&(t.strokeStyle=this._strokeStyle,t.strokeText(this._text,this._deltaX,this._deltaY)),this.width=t.measureText(this._text).width,t.restore(),this.needAnimation=!1},n}(e)})}.call(this),function(){"use strict";var t=function(t,n){function i(){this.constructor=t}for(var s in n)e.call(n,s)&&(t[s]=n[s]);return i.prototype=n.prototype,t.prototype=new i,t.__super__=n.prototype,t},e={}.hasOwnProperty;define("Graph",["DisplayObject"],function(e){var n;return n=function(e){function n(t){n.__super__.constructor.call(this,t),this._commands=[],this.needAnimation=!1}return t(n,e),n.prototype.line=function(t,e,n,i){var s,o;return s=this._point(t,e),o=this._point(n,i),this._commands.push({command:"line",from:s,to:o}),this.needAnimation=!0},n.prototype.clear=function(){return this._commands=[],this.needAnimation=!0},n.prototype.strokeStyle=function(t){return this._commands.push({command:"strokeStyle",style:t})},n.prototype.fillStyle=function(t){return this._commands.push({command:"fillStyle",style:t})},n.prototype.linearGradient=function(t,e,n,i,s){return this._commands.push({command:"gradient",point1:this._point(t,e),point2:this._point(n,i),colors:s})},n.prototype.rect=function(t,e,n,i,s){var o,r;return null==s&&(s=0),o=this._point(t,e),r=this._point(n,i),this._commands.push({command:"rect",point:o,sizes:r,radius:s}),this.needAnimation=!0},n.prototype.moveTo=function(t,e){var n;return n=this._point(t,e),this._commands.push({command:"moveTo",point:n})},n.prototype.lineTo=function(t,e){var n;return n=this._point(t,e),this._commands.push({command:"lineTo",point:n}),this.needAnimation=!0},n.prototype.fill=function(){return this._commands.push({command:"fill"}),this.needAnimation=!0},n.prototype.stroke=function(){return this._commands.push({command:"stroke"}),this.needAnimation=!0},n.prototype.polyline=function(t,e){return null==e&&(e=!0),this._commands.push({command:"beginPath"}),this.moveTo(t[0][0],t[0][1]),t.forEach(function(t){return function(e){return t.lineTo(e[0],e[1])}}(this)),e&&this._commands.push({command:"stroke"}),this.needAnimation=!0},n.prototype.polygon=function(t){return this.polyline(t,!1),this.lineTo(t[0][0],t[0][1]),this._commands.push({command:"stroke"}),this._commands.push({command:"fill"}),this.needAnimation=!0},n.prototype.lineWidth=function(t){return t=this._int(t),this._commands.push({command:"lineWidth",width:t})},n.prototype.setLineDash=function(t){return this._commands.push({command:"setDash",dash:t})},n.prototype.lineDashOffset=function(t){return t=this._int(t),this._commands.push({command:"dashOffset",offset:t})},n.prototype._drawRoundedRect=function(t,e,n,i,s,o){var r,a,h,u,c,p;return a=Math.PI,r=a/2,h=e+o,u=e+i-o,c=n+o,p=n+s-o,t.moveTo(h,n),t.lineTo(u,n),t.arc(u,c,o,-r,0),t.lineTo(e+i,p),t.arc(u,p,o,0,r),t.lineTo(h,n+s),t.arc(h,p,o,r,a),t.lineTo(e,c),t.arc(h,c,o,a,3*r)},n.prototype.animate=function(t){return n.__super__.animate.call(this,t),t.lineCap="round",this._commands.forEach(function(e){return function(n){var i;switch(n.command){case"beginPath":return t.beginPath();case"stroke":return t.stroke();case"fill":return t.fill();case"setDash":return t.setLineDash(n.dash);case"dashOffset":return t.lineDashOffset=n.offset;case"moveTo":return t.moveTo(n.point[0]+e._deltaX,n.point[1]+e._deltaY);case"lineTo":return t.lineTo(n.point[0]+e._deltaX,n.point[1]+e._deltaY);case"line":return t.beginPath(),t.moveTo(n.from[0]+e._deltaX,n.from[1]+e._deltaY),t.lineTo(n.to[0]+e._deltaX,n.to[1]+e._deltaY),t.stroke();case"strokeStyle":return t.strokeStyle=n.style;case"fillStyle":return t.fillStyle=n.style;case"lineWidth":return t.lineWidth=n.width;case"rect":return t.beginPath(),0===n.radius?t.rect(n.point[0]+e._deltaX,n.point[1]+e._deltaY,n.sizes[0],n.sizes[1]):e._drawRoundedRect(t,n.point[0]+e._deltaX,n.point[1]+e._deltaY,n.sizes[0],n.sizes[1],n.radius);case"gradient":return i=t.createLinearGradient(n.point1[0]+e._deltaX,n.point1[1]+e._deltaY,n.point2[0]+e._deltaX,n.point2[1]+e._deltaY),n.colors.forEach(function(t){return i.addColorStop(t[0],t[1])}),t.fillStyle=i}}}(this)),t.restore(),this.needAnimation=!1},n}(e)})}.call(this),function(){"use strict";var t=function(t,n){function i(){this.constructor=t}for(var s in n)e.call(n,s)&&(t[s]=n[s]);return i.prototype=n.prototype,t.prototype=new i,t.__super__=n.prototype,t},e={}.hasOwnProperty;define("TilingImage",["Image"],function(e){var n;return n=function(e){function n(t){n.__super__.constructor.call(this,t),this._rect=t.rect}return t(n,e),n.prototype.setRect=function(t){return this._rect=t,this.needAnimation=!0},n.prototype.animate=function(t){if(this._loaded)return n.__super__.animate.call(this,t),t.fillStyle=t.createPattern(this._image,"repeat"),t.rect(this._rect[0],this._rect[1],this._rect[2],this._rect[3]),t.fill(),t.restore(),this.needAnimation=!1},n}(e)})}.call(this),function(){"use strict";var t=function(t,n){function i(){this.constructor=t}for(var s in n)e.call(n,s)&&(t[s]=n[s]);return i.prototype=n.prototype,t.prototype=new i,t.__super__=n.prototype,t},e={}.hasOwnProperty;define("Scene",["base","Image","Text","Graph","TilingImage"],function(e,n,i,s,o){var r;return r=function(e){function r(t){r.__super__.constructor.call(this,t),this.name=t.name,this.canvas=document.createElement("canvas"),this.canvas.style.position="absolute",this.setZ(t.zIndex),this.context=this.canvas.getContext("2d"),this.setTransform(t),this._mask=!1,this._needAnimation=!1,this._objects=[]}return t(r,e),r.prototype.setZ=function(t){return this._zIndex=this._int(t),this.canvas.style.zIndex=this._zIndex},r.prototype.getZ=function(){return this._zIndex},r.prototype.add=function(t){var e;if(null!=t.type){switch(t.type){case"image":e=new n(t);break;case"text":e=new i(t);break;case"graph":e=new s(t);break;case"tile":null==t.rect&&(t.rect=[0,0,this._sizes[0],this._sizes[1]]),e=new o(t)}return this._objects.push(e),e}},r.prototype.get=function(t){var e;return e=!1,this._objects.some(function(n){var i;return i=n.name===t,i&&(e=n),i}),e},r.prototype.remove=function(t){var e;return e=-1,this._objects.some(function(n,i){var s;return s=n.name===t,s&&(e=i),s}),e>-1&&(this._objects.splice(e,1),!0)},r.prototype.addChild=function(t){return this._objects.push(t),this._needAnimation=!0},r.prototype.removeChild=function(t){var e;return e=-1,this._objects.some(function(n,i){var s;return s=n===t,s&&(e=i),s}),e>-1&&(this._objects.splice(e,1),!0)},r.prototype.needAnimation=function(){return this._needAnimation||this._objects.some(function(t){return t.needAnimation})},r.prototype.testPoint=function(t,e){var n,i;return n=this.context.getImageData(t,e,1,1),i=n.data,null==i.every&&(i.every=Array.prototype.every),!i.every(function(t){return 0===t})},r.prototype.setMask=function(t,e,n,i){return arguments.length<4?this._mask=!1:this._mask={x:this._int(t),y:this._int(e),width:this._int(n),height:this._int(i)},this._needAnimation=!0},r.prototype.setTransform=function(t){return this.setSizes(t.sizes),this.setPosition(t.position),this.setCenter(t.center),this.setRotation(t.rotation),this.setAlpha(t.alpha)},r.prototype.setSizes=function(t){return null!=t&&(this._sizes=this._point(t)),this.canvas.width=this._sizes[0],this.canvas.height=this._sizes[1],this._needAnimation=!0},r.prototype.setPosition=function(t){return null!=t&&(this._position=this._point(t)),this.canvas.style.left=this._position[0],this.canvas.style.top=this._position[1],this._needAnimation=!0},r.prototype.setCenter=function(t){return null!=t&&(this._center=this._point(t)),this.context.translate(this._center[0],this._center[1]),this._needAnimation=!0},r.prototype.setRotation=function(t){return null!=t&&(this._rotation=this._value(t)),this.context.rotation=this._rotation*Math.PI/180,this._needAnimation=!0},r.prototype.setAlpha=function(t){return null!=t&&(this._alpha=this._value(t)),this.context.globalAlpha=this._alpha,this._needAnimation=!0},r.prototype.animate=function(){return this.context.clearRect(0,0,this.canvas.width,this.canvas.height),this._mask&&(this.context.beginPath(),this.context.rect(this._mask.x,this._mask.y,this._mask.width,this._mask.height),this.context.clip()),this._objects.forEach(function(t){return function(e){return e.animate(t.context)}}(this)),this._needAnimation=!1},r}(e)})}.call(this),function(){"use strict";define("Scenes",["Scene"],function(t){var e;return e=function(){function e(t){this._scenes=[],this._stage=t,this._activeSceneName=""}return e.prototype.create=function(e){var n,i,s;return i=e.name||"default",n=this.get(i),n||(n=new t(e),this._stage.appendChild(n.canvas),this._scenes.push(n)),s=null==e.setActive||e.setActive,s&&(this._activeSceneName=i),n},e.prototype.active=function(){return this._activeSceneName},e.prototype.active.set=function(t){var e;return e=this.get(t),e&&(this._activeSceneName=t),e},e.prototype.active.get=function(){return this.get(this._activeSceneName)},e.prototype.get=function(t){var e;return e=!1,this._scenes.some(function(n){var i;return i=n.name===t,i&&(e=n),i}),e},e.prototype.remove=function(t){var e;return e=this._index(t),e>-1&&(this._parent.removeChild(this._scenes[e].canvas),this._scenes.splice(e,1),!0)},e.prototype.rename=function(t,e){var n;return n=this.get(t),n&&(n.name=e),n},e.prototype.onTop=function(t){var e,n;return e=0,n=!1,this._scenes.forEach(function(i){if(i.getZ()>e&&(e=i.getZ()),t===i.name)return n=i}),n&&n.setZ(e+1),n},e.prototype.needAnimation=function(){return this._scenes.some(function(t){return t.needAnimation()})},e.prototype.animate=function(){return this._scenes.forEach(function(t){if(t.needAnimation())return t.animate()})},e.prototype._index=function(t){var e;return e=-1,this._scenes.some(function(n){var i;return i=n.name===t,i&&(e=n),i}),e},e}()})}.call(this),function(){"use strict";var t=function(t,e){return function(){return t.apply(e,arguments)}};define("FPS",[],function(){var e;return e=function(){function e(e){this._onTimer=t(this._onTimer,this),this._scene=e.scene,this._graph=this._scene.add({type:"graph"}),this._values=[],this._caption=this._scene.add({type:"text",fillStyle:"#00FF00",font:"10px Arial",position:[3,10]}),this._caption2=this._scene.add({type:"text",fillStyle:"#FF0000",font:"10px Arial",position:[48,10]}),this.start(),this._onTimer()}return e.prototype.start=function(){return this._counter=this._updateCounter=this._FPSValue=0,this._interval=setInterval(this._onTimer,1e3)},e.prototype.stop=function(){return clearInterval(this._interval),this._counter=this._updateCounter=this._FPSValue=0},e.prototype._onTimer=function(){var t,e,n,i,s,o;for(this._FPSValue=this._counter,this._counter=0,this._updateValue=this._updateCounter,this._updateCounter=0,this._values.push([this._FPSValue,this._updateValue]),84===this._values.length&&this._values.shift(),this._graph.clear(),this._graph.fillStyle("#000"),this._graph.rect(0,0,90,40),this._graph.fill(),e=n=0,i=this._values.length;0<=i?n<i:n>i;e=0<=i?++n:--n)o=87-this._values.length+e,t=this._values[e][0],s=this._values[e][1],this._graph.strokeStyle("#00FF00"),this._graph.line(o,37,o,37-23*t/60),this._graph.strokeStyle("#FF0000"),this._graph.line(o,37,o,37-23*s/60);return this._caption.setText("FPS: "+this._FPSValue),this._caption2.setText("UPS: "+this._updateValue)},e.prototype.update=function(t){if(this._counter++,t)return this._updateCounter++},e}()})}.call(this),function(){"use strict";var t=function(t,e){return function(){return t.apply(e,arguments)}},e=function(t,e){function i(){this.constructor=t}for(var s in e)n.call(e,s)&&(t[s]=e[s]);return i.prototype=e.prototype,t.prototype=new i,t.__super__=e.prototype,t},n={}.hasOwnProperty;define("CanvasEngine",["base","Scenes","FPS"],function(n,i,s){var o;return o=function(n){function o(e){this._animate=t(this._animate,this);var n;return this._canvasSupport()?(o.__super__.constructor.call(this,e),this._scenes=new i(this._parent),this._beforeAnimate=[],this._showFPS=null==e.showFPS||e.showFPS,this._showFPS&&(n=this._scenes.create({name:"FPS",sizes:[90,40],position:[5,5],zIndex:9999,setActive:!1}),this._FPS=new s({scene:n})),void this.start()):(console.log("your browser not support canvas and/or context"),!1)}return e(o,n),o.prototype.start=function(){return this._render=requestAnimationFrame(this._animate)},o.prototype.stop=function(){return closeRequestAnimation(this._render)},o.prototype.addEvent=function(t){return this._beforeAnimate.push(t)},o.prototype.removeEvent=function(t){return this._beforeAnimate.forEach(function(e){return function(n,i){if(n===t)return e._beforeAnimate.splice(i,1)}}(this))},o.prototype.add=function(t){var e,n,i;return i=t.type||"scene","scene"===i?(null==t.sizes&&(t.sizes=this._sizes),this._scenes.create(t)):(n=t.scene||this._scenes.active()||"default",e=this._scenes.create({name:n,sizes:t.sizes||this._sizes}),e.add(t))},o.prototype._canvasSupport=function(){return null!=document.createElement("canvas").getContext},o.prototype._animate=function(){var t;return this._beforeAnimate.forEach(function(t){if("function"==typeof t)return t()}),t=this._scenes.needAnimation(),t&&this._scenes.animate(),this._showFPS&&this._FPS.update(t),this._render=requestAnimationFrame(this._animate)},o}(n),window.CanvasEngine=o})}.call(this);