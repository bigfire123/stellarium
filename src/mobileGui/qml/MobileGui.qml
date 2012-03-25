import QtQuick 1.1

Item {
	id: mobileGui

	////////////////////////
	// Properties
	////////////////////////

	//Minimum dp for each category
	// microPhoneScreen: small phones
	// normalPhoneScreen: average phone
	// tweenerScreenDp: ~5" mini tablets/phablets
	// mediumScreen: ~7" tablets
	// largeScreen: ~10" tablets

	// microPhoneScreen: < 280 dp
	property int normalPhoneScreenDp: 280
	property int tweenerScreenDp: 448
	property int mediumScreenDp: 560
	property int largeScreenDp: 672

	//currently divided on button width, rather than Android screen size divisions
	//if a button is 56dp wide, we get <5, 5, 8, 10, 12 buttons

	focus: true

	/* Placeholder values so the designer can be used;
	  these are set to fill 100% of the screen by the
	  MobileGui C++ class */
	width: 480
	height: 800

	////////////////////////
	// Signals
	////////////////////////
	signal fovChanged(real newFov)

	//pass mouse events if they only hit the root mousearea
	signal mousePressed(int x, int y, int button, int buttons, int modifiers)
	signal mouseReleased(int x, int y, int button, int buttons, int modifiers)
	signal mouseMoved(int x, int y, int button, int buttons, int modifiers)

	//////////////////////////////////
	// Screen size/dpi helper functions
	//////////////////////////////////

	// Layouts should use these functions rather than using pixels directly.
	// For instance -   width: dp(32)

	// dp are density-independent pixels
	// 1dp is equal to 1 pixel on a 160 pixels-per-inch display

	// The Wiki does (or will) contain information on standard spacing and sizes,
	// or refer to the Android design guidelines for ideas

	property real density: displayInfo.density

	// Convert from dp (density-independent pixels) along the display width to pixels
	function dp(number)
	{
		return Math.round(number * density)
	}

	// Width of the display in dp; that is, it gives us an indication of physical width.
	// This is higher for larger displays, but equal for displays of the same size but
	// different densities.
	function totalDpWidth()
	{
		return width / density;
	}

	////////////////////////
	// Other functions
	////////////////////////


	/* Choose a layout based on the screen size */
	function chooseLayout()
	{
		var screenWidth = totalDpWidth();
		return "LayoutSmall.qml"; //TODO: we only have LayoutSmall right now

		if(screenWidth < normalPhoneScreenDp)
		{
			return "LayoutExtraSmall.qml";
		}
		else if(screenWidth < tweenerScreenDp)
		{
			return "LayoutSmall.qml";
		}
		else if(screenWidth < mediumScreenDp)
		{
			return "LayoutSmall.qml";
			//return "LayoutTweener.qml";
		}
		else if(screenWidth < largeScreenDp)
		{
			return "LayoutMedium.qml";
		}
		else
		{
			return "LayoutLarge.qml";
		}
	}

	Loader {
		id: layoutLoader
		anchors.fill: parent
		source: chooseLayout()

		PinchArea
		{
			id: pinchZone
			pinch.dragAxis: Pinch.NoDrag

			anchors.fill: parent

			property real origFov

			onPinchStarted: origFov = stel.getCurrentFov();
			onPinchUpdated: mobileGui.fovChanged((1/pinch.scale)*origFov);
		}

		MouseArea
		{
			anchors.fill: parent

			onPressed: mobileGui.mousePressed(mouse.x, mouse.y, mouse.button, mouse.buttons, mouse.modifiers)
			onReleased: mobileGui.mouseReleased(mouse.x, mouse.y, mouse.button, mouse.buttons, mouse.modifiers)
			onMousePositionChanged: mobileGui.mouseMoved(mouse.x, mouse.y, mouse.button, mouse.buttons, mouse.modifiers)
		}

	}
}
