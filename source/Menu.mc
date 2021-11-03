import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

///////////////////////////////////////////////////////////////////////////////
class MenuQR extends WatchUi.Menu2 {
	function initialize(){
		Menu2.initialize({:title => Application.loadResource(Rez.Strings.MENU_QR_TITLE)});
		
		var cache as Dictonary = Application.Storage.getValue(CACHE_STORAGE_KEY);
		if (cache == null){
			return;
		}
        var keys as Array<String> = cache.keys();
        for (var i as Number = 0; i <cache.size(); i++){
        	addItem(new MenuItem(keys[i], cache[keys[i]], keys[i], null));
        }
	}
	
	function close() as Void{
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
	}
}

///////////////////////////////////////////////////////////////////////////////
class MenuQRDelegate extends WatchUi.Menu2InputDelegate{
	
	var menuQR as MenuQR;  
	
	function initialize(menuQR) {
	 	self.menuQR = menuQR;
        Menu2InputDelegate.initialize();
    }
	
	function onSelect(item as MenuItem){
		WatchUi.pushView(new MenuContext(), new MenuContextDelegate(menuQR, item), WatchUi.SLIDE_IMMEDIATE);
	}
}

///////////////////////////////////////////////////////////////////////////////
class MenuContext extends WatchUi.Menu2{
	
	function initialize(){
		Menu2.initialize({:title => Application.loadResource(Rez.Strings.MENU_CONTEXT_TITLE)});
       	addItem(new MenuItem(Application.loadResource(Rez.Strings.SHOW), null, :show, null));
       	addItem(new MenuItem(Application.loadResource(Rez.Strings.SET_DEFAULT), null,:setDefault, null));
       	addItem(new MenuItem(Application.loadResource(Rez.Strings.DEL), null, :delete, null));
	}
}

///////////////////////////////////////////////////////////////////////////////
class MenuContextDelegate extends WatchUi.Menu2InputDelegate{
	
	var menuQR as MenuQR;
	var itemQR as MenuItem;
	
	function initialize(menuQR, itemQR) {
	 	self.menuQR = menuQR;
	 	self.itemQR = itemQR;
        Menu2InputDelegate.initialize();
    }
	
	function onSelect(item as MenuItem){
		
		var key as String = itemQR.getLabel();
		if (item.getId() == :show){
			currentKey = key;
			menuQR.close();
		}else if (item.getId() == :setDefault){
			Application.Storage.setValue(DEFAULT_QR_KEY, key);
		}else if (item.getId() == :delete){
			
			Application.Storage.deleteValue(key);
			var cache as Dictonary = Application.Storage.getValue(CACHE_STORAGE_KEY);
			cache.remove(key);
			Application.Storage.setValue(CACHE_STORAGE_KEY, cache);
			
			var defKey as String = Application.Storage.getValue(DEFAULT_QR_KEY);
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
		}
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
	}
}
