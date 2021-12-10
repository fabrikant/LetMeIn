import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

enum{
	CACHE_STORAGE_KEY = "KEYS",
	DEFAULT_QR_KEY = "DEF_KEY"
}

var currentKey;

class LetMeInApp extends Application.AppBase {

    function initialize() {
    	currentKey = "";
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    	downloadQR();
    }

    // onStop() is called when your application is exiting
    function onStop(state){
    }

	function onSettingsChanged(){
    	downloadQR();
	}
	
    // Return the initial view of your application here
    function getInitialView(){
        return [ new LetMeInView(), new LetMeInViewDelegate() ];
    }

    function getBitmapSize(){
    	var bitmapSize;
    	var screenSize = Tools.min(System.getDeviceSettings().screenHeight, System.getDeviceSettings().screenWidth);
    	
    	if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND){
    		bitmapSize = Toybox.Math.sqrt(screenSize*screenSize/2).toNumber();
    	}else{
    		bitmapSize = screenSize; 
    	}
    	return bitmapSize; 
    }

    function downloadQR(){
 
     	var qrStr = Application.Properties.getValue("NEW_CODE");
    	if (qrStr.equals("")){
    		return;
    	}
    	
    	var bitmapSize = getBitmapSize();
		var strUrl = "https://chart.googleapis.com/chart?cht=qr&chld=M|1";
		strUrl += "&chs=" + bitmapSize +"x"+ bitmapSize;
		strUrl += "&chl=" + Communications.encodeURL(qrStr);
		Communications.makeImageRequest(
			strUrl,
			{},
			{
				:palette => [ Graphics.COLOR_BLACK, Graphics.COLOR_WHITE],
				:maxWidth => bitmapSize,
				:maxHeight => bitmapSize,
				:dithering => Communications.IMAGE_DITHERING_NONE
			},
			self.method(:onReceiveImage)
		);
    }
	
	function onReceiveImage(code, data){
		if (code == 200){
			var cache = Application.Storage.getValue(CACHE_STORAGE_KEY);
			if (cache == null){
				cache = {};
			}
			
			var label = Application.Properties.getValue("NEW_LABEL"); 
			var source = Application.Properties.getValue("NEW_CODE");
			if (label.equals("")){
				label = source; 
			}
			cache[label] = source;
			Application.Storage.setValue(label, data);
			Application.Storage.setValue(CACHE_STORAGE_KEY, cache);
			
			Application.Properties.setValue("NEW_LABEL", "");
			Application.Properties.setValue("NEW_CODE", "");
			
			WatchUi.requestUpdate(); 
		}
	}
}

function getApp(){
    return Application.getApp();
}
