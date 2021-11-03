import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

enum{
	CACHE_STORAGE_KEY = "KEYS",
	DEFAULT_QR_KEY = "DEF_KEY"
}

var currentKey as String;

class LetMeInApp extends Application.AppBase {

    function initialize() {
    	currentKey = "";
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    	downloadQR();
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

	function onSettingsChanged() as Void {
    	downloadQR();
	}
	
    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new LetMeInView(), new LetMeInViewDelegate() ] as Array<Views or InputDelegates>;
    }

    function getBitmapSize() as Number{
    	var bitmapSize as Number;
    	var screenSize as Number = Tools.min(System.getDeviceSettings().screenHeight, System.getDeviceSettings().screenWidth);
    	
    	if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND){
    		bitmapSize = Toybox.Math.sqrt(screenSize*screenSize/2).toNumber();
    	}else{
    		bitmapSize = screenSize; 
    	}
    	return bitmapSize; 
    }

    function downloadQR() as Void{
 
     	var qrStr as String = Application.Properties.getValue("NEW_CODE");
    	if (qrStr.equals("")){
    		return;
    	}
    	
    	var bitmapSize as Number = getBitmapSize();
    	var reqSize = (bitmapSize*2).toNumber(); 
		var strUrl as String = "https://chart.googleapis.com/chart?cht=qr&chld=M";
		strUrl += "&chs=" + reqSize +"x"+ reqSize;
		strUrl += "&chl=" + Communications.encodeURL(qrStr);
		Communications.makeImageRequest(
			strUrl,
			{},
			{
				:maxWidth => bitmapSize,
				:maxHeight=> bitmapSize
			},
			self.method(:onReceiveImage)
		);
    }
	
	function onReceiveImage(code as Number, data as BitmapResource) as Void{
		if (code == 200){
			var cache as Dictonary = Application.Storage.getValue(CACHE_STORAGE_KEY);
			if (cache == null){
				cache = {};
			}
			
			var label as String = Application.Properties.getValue("NEW_LABEL"); 
			var source as String = Application.Properties.getValue("NEW_CODE");
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

function getApp() as LetMeInApp {
    return Application.getApp() as LetMeInApp;
}