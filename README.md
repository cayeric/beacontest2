# beacontest2
This app monitors the transition into a region with an active iBeacon, or out of the region - in foreground as well as in the background. If a transition occurs, the app calls a web-service passing transition details in the URL.

## Installation
* Clone the repository
* In project file beacontest.xcodeproj: select "TARGETS/beacontest2", select your iOS developer account for code signing in "general/signing"
* in AppDelegate.m modify the "define" section to your needs
	* add your custom service URL you wish to get called when entering or exiting the beacon environment
	* set the proximity UUID of the beacon you wish to monitor 
* run the test-App with attached iOS device

