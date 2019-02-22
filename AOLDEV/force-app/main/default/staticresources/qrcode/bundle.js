!function(e){function t(o){if(n[o])return n[o].exports;var a=n[o]={i:o,l:!1,exports:{}};return e[o].call(a.exports,a,a.exports,t),a.l=!0,a.exports}var n={};t.m=e,t.c=n,t.i=function(e){return e},t.d=function(e,n,o){t.o(e,n)||Object.defineProperty(e,n,{configurable:!1,enumerable:!0,get:o})},t.n=function(e){var n=e&&e.__esModule?function(){return e.default}:function(){return e};return t.d(n,"a",n),n},t.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},t.p="",t(t.s=5)}([function(e,t,n){"use strict";var o={},a=document.querySelector(".app__snackbar"),i=null;o.show=function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:4e3;e&&(i&&i.remove(),i=document.createElement("div"),i.className="app__snackbar-msg",i.textContent=e,a.appendChild(i),setTimeout(function(){i.remove()},t))},t.snackbar=o},function(e,t,n){"use strict";function o(e){!e&&window.isMediaStreamAPISupported?i.webcam=document.querySelector("video"):i.webcam=document.querySelector("img")}var a=n(0),i={};i.active=!1,i.webcam=null,i.canvas=null,i.ctx=null,i.decoder=null,i.setCanvas=function(){i.canvas=document.createElement("canvas"),i.ctx=i.canvas.getContext("2d")},i.init=function(){function e(){i.canvas.width=window.innerWidth,i.canvas.height=window.innerHeight}function t(e){navigator.mediaDevices.getUserMedia(e).then(function(e){i.webcam.srcObject=e,i.webcam.setAttribute("playsinline",!0),i.webcam.setAttribute("controls",!0),setTimeout(function(){document.querySelector("video").removeAttribute("controls")})}).catch(function(e){console.log("Error occurred ",e),n()})}function n(){window.noCameraPermission=!0,document.querySelector(".custom-scanner").style.display="none",a.snackbar.show("Unable to access the camera",1e4)}var r=!1;o(),i.setCanvas(),i.decoder=new Worker("decoder.min.js"),window.isMediaStreamAPISupported?i.webcam.addEventListener("play",function(t){r||(e(),r=!0)},!1):e(),window.isMediaStreamAPISupported&&navigator.mediaDevices.enumerateDevices().then(function(e){var n,o=e.filter(function(e){if(e.label.split(",")[1],"videoinput"==e.kind)return e});o.length>1?(n={video:{mandatory:{sourceId:o[1].deviceId?o[1].deviceId:null}},audio:!1},window.iOS&&(n.video.facingMode="environment"),t(n)):o.length?(n={video:{mandatory:{sourceId:o[0].deviceId?o[0].deviceId:null}},audio:!1},window.iOS&&(n.video.facingMode="environment"),t(n)):t({video:!0})}).catch(function(e){n(),console.error("Error occurred : ",e)})},i.scan=function(e,t){function n(t){if(t.data.length>0){var n=t.data[0][2];i.active=!1,e(n)}setTimeout(a,0)}function a(){if(i.active)try{i.ctx.drawImage(i.webcam,0,0,i.canvas.width,i.canvas.height);var e=i.ctx.getImageData(0,0,i.canvas.width,i.canvas.height);e.data&&i.decoder.postMessage(e)}catch(e){"NS_ERROR_NOT_AVAILABLE"==e.name&&setTimeout(a,0)}}i.active=!0,i.setCanvas(),i.decoder.onmessage=n,setTimeout(function(){o(t)}),a()},e.exports=i},function(e,t){},function(e,t){function n(e){return o.test(e)}e.exports=n;var o=/^(?:\w+:)?\/\/([^\s\.]+\.\S{2}|localhost[\:?\d]*)\S*$/},function(e,t){function n(){return"serviceWorker"in navigator&&(window.fetch||"imageRendering"in document.documentElement.style)&&("https:"===window.location.protocol||"localhost"===window.location.hostname||0===window.location.hostname.indexOf("127."))}function o(e){e||(e={}),n()&&navigator.serviceWorker.register("/sw.js")}function a(e,t){}function i(){n()&&navigator.serviceWorker.getRegistration().then(function(e){if(e)return e.update()})}t.install=o,t.applyUpdate=a,t.update=i},function(e,t,n){"use strict";function o(e){return e&&e.__esModule?e:{default:e}}var a=n(1),i=o(a),r=n(0),c=n(2),d=(o(c),n(3)),l=o(d);"serviceWorker"in navigator&&"localhost"!==window.location.hostname&&navigator.serviceWorker.ready.then(function(e){localStorage.getItem("offline")||(localStorage.setItem("offline",!0),r.snackbar.show("App is ready for offline usage.",5e3))}),n(4).install(),window.addEventListener("DOMContentLoaded",function(){function e(){window.appOverlay.style.borderStyle="solid"}function t(){d=document.createElement("img"),d.src="",d.id="frame"}function n(){console.log("Result: ",c),window.open(c,"_blank","toolbar=0,location=0,menubar=0"),c=null,a()}function o(){var e=arguments.length>0&&void 0!==arguments[0]&&arguments[0];window.isMediaStreamAPISupported&&!window.noCameraPermission&&(f.style.display="block"),e&&(f.style.display="block"),i.default.scan(function(e){c=e,w.value=e,w.select(),f.style.display="none",(0,l.default)(e)&&(p.style.display="inline-block"),u.classList.remove("app__dialog--hide"),m.classList.remove("app__dialog--hide"),document.querySelector("#frame")},e)}function a(){c=null,w.value="",window.isMediaStreamAPISupported||(d.src="",d.className=""),u.classList.add("app__dialog--hide"),m.classList.add("app__dialog--hide"),o()}function r(){var e=document.createElement("input");e.setAttribute("type","file"),e.setAttribute("capture","camera"),e.id="camera",window.appOverlay.style.borderStyle="",s.style.display="block",t();var n=document.querySelector(".app__layout-content");n.appendChild(e),n.appendChild(d),s.addEventListener("click",function(){f.style.display="none",document.querySelector("#camera").click()}),e.addEventListener("change",function(e){e.target&&e.target.files.length>0&&(d.className="app__overlay",d.src=URL.createObjectURL(e.target.files[0]),window.noCameraPermission||(f.style.display="block"),window.appOverlay.style.borderColor="rgb(62, 78, 184)",o(!0))})}window.iOS=["iPad","iPhone","iPod"].indexOf(navigator.platform)>=0,window.isMediaStreamAPISupported=navigator&&navigator.mediaDevices&&"enumerateDevices"in navigator.mediaDevices,window.noCameraPermission=!1;var c=null,d=null,s=document.querySelector(".app__select-photos"),u=document.querySelector(".app__dialog"),m=document.querySelector(".app__dialog-overlay"),p=document.querySelector(".app__dialog-open"),v=document.querySelector(".app__dialog-close"),f=document.querySelector(".custom-scanner"),w=document.querySelector("#result");document.querySelector(".app__help-text"),document.querySelector(".app__header-icon svg"),document.querySelector("video"),window.appOverlay=document.querySelector(".app__overlay"),window.addEventListener("load",function(t){i.default.init(),setTimeout(function(){e(),window.isMediaStreamAPISupported&&o()},1e3),r()}),v.addEventListener("click",a,!1),p.addEventListener("click",n,!1)})}]);