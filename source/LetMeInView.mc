import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Communications;
import Toybox.System;

class LetMeInView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.clear();
        
		var cache as Dictonary = Application.Storage.getValue(CACHE_STORAGE_KEY);
		if (cache == null){
			var x as Number = (dc.getWidth()/2).toNumber();
			var y as Number = (dc.getHeight()/2).toNumber();
        	dc.drawText(x, y, Graphics.FONT_MEDIUM, Application.loadResource(Rez.Strings.NO_DATA), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
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
			var bitmapSize as Number = getApp().getBitmapSize();
			var bitmap as Graphics.BufferedBitmap = new Graphics.BufferedBitmap({
				:width => bitmapSize, 
				:height => bitmapSize, 
				:palete => [Graphics.COLOR_BLACK, Graphics.COLOR_WHITE],
				:bitmapResource => Application.Storage.getValue(label)
			});
			var x as Number = ((dc.getWidth() - bitmapSize)/2).toNumber();
			var y as Number = ((dc.getHeight() - bitmapSize)/2).toNumber();
			dc.drawBitmap(x, y, bitmap);
			
			//dc.drawRectangle(x, y, bitmapSize, bitmapSize);
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
    
}
