import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

enum{
	CACHE_STORAGE_KEY,
	DEFAULT_QR_KEY
}

var currentKey as String;

class LetMeInApp extends Application.AppBase {

    function initialize() {
    	currentKey = "";
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new LetMeInView(), new LetMeInViewDelegate() ] as Array<Views or InputDelegates>;
    }

}

function getApp() as LetMeInApp {
    return Application.getApp() as LetMeInApp;
}