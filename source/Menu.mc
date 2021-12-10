import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

///////////////////////////////////////////////////////////////////////////////
class MenuQR extends WatchUi.Menu2 {
	function initialize(){
		Menu2.initialize({:title => Application.loadResource(Rez.Strings.MENU_QR_TITLE)});
		
		var cache = Application.Storage.getValue(CACHE_STORAGE_KEY);
		if (cache == null){
			return;
		}
        var keys = cache.keys();
        for (var i = 0; i <cache.size(); i++){
        	addItem(new MenuItem(keys[i], cache[keys[i]], keys[i], null));
        }
	}
	
	function close(){
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
	}
}

///////////////////////////////////////////////////////////////////////////////
class MenuQRDelegate extends WatchUi.Menu2InputDelegate{
	
	var menuQR;  
	
	function initialize(menuQR) {
	 	self.menuQR = menuQR;
        Menu2InputDelegate.initialize();
    }
	
	function onSelect(item){
		WatchUi.pushView(new MenuContext(), new MenuContextDelegate(menuQR, item), WatchUi.SLIDE_IMMEDIATE);
	}
}

///////////////////////////////////////////////////////////////////////////////
class MenuContext extends WatchUi.Menu2{
	
	function initialize(){
		Menu2.initialize({:title => Application.loadResource(Rez.Strings.MENU_CONTEXT_TITLE)});
       	addItem(new MenuItem(Application.loadResource(Rez.Strings.SHOW), null, :show, null));
       	addItem(new MenuItem(Application.loadResource(Rez.Strings.SET_DEFAULT), null,:setDefault, null));
       	addItem(new MenuItem(Application.loadResource(Rez.Strings.DEL), null, :remove, null));
	}
}

///////////////////////////////////////////////////////////////////////////////
class MenuContextDelegate extends WatchUi.Menu2InputDelegate{
	
	var menuQR;
	var itemQR;
	
	function initialize(menuQR, itemQR) {
	 	self.menuQR = menuQR;
	 	self.itemQR = itemQR;
        Menu2InputDelegate.initialize();
    }
	
	function onSelect(item){
		
		var key = itemQR.getLabel();
		if (item.getId() == :show){
			currentKey = key;
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
			menuQR.close();
		}else if (item.getId() == :setDefault){
			Application.Storage.setValue(DEFAULT_QR_KEY, key);
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		}else if (item.getId() == :remove){
			WatchUi.pushView(
				new WatchUi.Confirmation(Application.loadResource(Rez.Strings.REMOVE_CONFIRMATION)),
				new RemoveConfirmationDelegate(menuQR, itemQR),
				WatchUi.SLIDE_IMMEDIATE);
		}
		
	}
}

///////////////////////////////////////////////////////////////////////////////
class RemoveConfirmationDelegate extends WatchUi.ConfirmationDelegate {
 	
 	var menuQR;
	var itemQR;
    
    function initialize(menuQR, itemQR) {
	 	self.menuQR = menuQR;
	 	self.itemQR = itemQR;        
	 	ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        
        if (response == WatchUi.CONFIRM_YES) {
			var key = itemQR.getLabel();
			Application.Storage.deleteValue(key);
			var cache = Application.Storage.getValue(CACHE_STORAGE_KEY);
			cache.remove(key);
			Application.Storage.setValue(CACHE_STORAGE_KEY, cache);
			
			var defKey = Application.Storage.getValue(DEFAULT_QR_KEY);
			if (defKey != null){
				if (defKey.equals(key)){
					Application.Storage.deleteValue(DEFAULT_QR_KEY);
				}
			}
			
			if (currentKey.equals(key)){
				currentKey = "";
			}
			menuQR.deleteItem(menuQR.findItemById(itemQR.getId())); 
			
			if (cache.keys().size() == 0){
				menuQR.close();
			}
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }
}