javascript: (function(root, ev) {
             function Brige() {
             this.init = function(evn) {
             this.version = evn.version;
             };
             
             this.callNative = function(url) {
             var t = document.createElement("iframe");
             t.style.width = "1px";
             t.style.height = "1px";
             t.style.display = "none";
             t.src = url;
             document.body.appendChild(t);
             setTimeout(function() {
                        document.body.removeChild(t),
                        t.remove()
                        },
                        100);
             };
             
             // Call By SDK
             this.saveToSDK = function(urls) {
             this.callNative('mmaViewabilitySDK://saveJSCacheData?data=' + JSON.stringify(urls));
             };
             
             // 停止SDK对当前广告位的监测,viewabilityID为当前监测广告的唯一标示ID
             this.stop = function(viewabilityID) {
             this.callNative('mmaViewabilitySDK://stopViewability?AdviewabilityID=' + viewabilityID);
             };
             
             // 根据配置文件解析监测数据,string为间隔对广告状态的监测数值
             this.sendViewabilityMessage = function(string) {
             
             };
             
             };
             if ("undefined" === typeof root.MMASDK) {
             root.MMASDK = new Brige();
             root.MMASDK.init(ev);
             root.__MMASDKInit = true;
             };
             })(window, {
                "version": "1.0"
                });
