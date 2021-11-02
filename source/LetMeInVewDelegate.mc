using Toybox.WatchUi;

class LetMeInViewDelegate extends WatchUi.InputDelegate {

    function onKey(keyEvent) {
    	if (keyEvent.getKey() == WatchUi.KEY_ENTER){
    		var menuQR as MenuQR = new MenuQR(); 
    		WatchUi.pushView(menuQR, new MenuQRDelegate(menuQR), WatchUi.SLIDE_IMMEDIATE);
			return true;
		}else{
			return false;
		}    
    }

    function onTap(clickEvent) {
        System.println(clickEvent.getType());      // e.g. CLICK_TYPE_TAP = 0
        return true;
    }
}