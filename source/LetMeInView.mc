import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Communications;
import Toybox.System;

class LetMeInView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    	var code as String = Application.Properties.getValue("NEW_CODE");
    	if (! code.equals("")){
    		downloadQR(code);
    	}
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        //View.onUpdate(dc);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.clear();
        
		var cache as Dictonary = Application.Storage.getValue(CACHE_STORAGE_KEY);
		if (cache == null){
			return;
		}
        
        var label as String = currentKey;
        if (label == null || label.equals("")){
        	label = Application.Storage.getValue(DEFAULT_QR_KEY);
        }
        if (label == null || label.equals("")){
	        var keys as Array<String> = cache.keys();
	        if (keys.size() > 0){
	        	label = keys[0];
	        }
        } 
        if (label == null || label.equals("")){
			var x as Number = (dc.getWidth()/2).toNumber();
			var y as Number = (dc.getHeight()/2).toNumber();
        	dc.drawText(x, y, Graphics.FONT_MEDIUM, Application.loadResource(Rez.Strings.NO_DATA), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		}else{        
			var bitmapSize as Number = getBitmapSize();
			var bitmap as Graphics.BufferedBitmap = new Graphics.BufferedBitmap({
				:width => bitmapSize, 
				:height => bitmapSize, 
				:palete => [Graphics.COLOR_BLACK, Graphics.COLOR_WHITE],
				:bitmapResource => Application.Storage.getValue(label)
			});
			var x as Number = ((dc.getWidth() - bitmapSize)/2).toNumber();
			var y as Number = ((dc.getHeight() - bitmapSize)/2).toNumber();
			dc.drawBitmap(x, y, bitmap);
			
			if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND){
				var font as Number = Graphics.FONT_SYSTEM_TINY;
				dc.drawText(
					dc.getWidth()/2, 
					y - dc.getFontHeight(font), 
					font, 
					label, 
					Graphics.TEXT_JUSTIFY_CENTER
				);
			}   
		}	
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
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

    function downloadQR(qrStr as String) as Void{
    	
    	var bitmapSize as Number = getBitmapSize();
    	 
		var strUrl as String = "https://chart.googleapis.com/chart?cht=qr&chld=M";
		strUrl += "&chs=" + bitmapSize +"x"+ bitmapSize;
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
		System.println("onReceiveImage "+code);
		
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
