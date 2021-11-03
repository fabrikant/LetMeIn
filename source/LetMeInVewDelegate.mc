using Toybox.WatchUi;

class LetMeInViewDelegate extends WatchUi.InputDelegate {
	
	function openMenu() as Void {
		var cache as Dictonary = Application.Storage.getValue(CACHE_STORAGE_KEY);
		if (cache == null){
			return;
		}
        var keys as Array<String> = cache.keys();
		if (keys.size() == 0){
			return;
		}
		var menuQR as MenuQR = new MenuQR(); 
		WatchUi.pushView(menuQR, new MenuQRDelegate(menuQR), WatchUi.SLIDE_IMMEDIATE);
	
	}
	
    function onKey(keyEvent) {
    	if (keyEvent.getKey() == WatchUi.KEY_ENTER){
    		openMenu();
			return true;
		}else{
			return false;
		}    
    }

    function onTap(clickEvent) {
        openMenu();
        return true;
    }
}