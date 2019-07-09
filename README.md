Application that detect ur location with geofence and connected wifi

Easy start
1. Run Pod install
2. then build into any device
3. You will saw "No  enter any fence", because predefined fence are not around you
4. The label will notify u which geofence u enter and leaving

Note: kindly allow location service at first launch, didnt do dialog for request service again.


Customization
1. Geofence are manually added in Code Level (No UI for it,since in real life, Setel app's geofences will fetch from server side)
	- To add new geofence, go to File : ViewModel/GeofenceViewModel.swift
	- Function : getTestData(...)
	- add in new row like
	```
	geofences.append(Geofence(id: "3", coordinate: CLLocationCoordinate2D(latitude: 3.11743470880481, longitude: 101.67611098392119), radius: radius, title:"Mid Valley Office",bssid:"9c:d6:43:2d:3c:48"))
	```
	- bssid is optional, which is wifi bssid, to detect exact location with connected wifi, you have to add bssid for that geofence object
	- Note: must using xcode development Team that have Access Wifi Information capabilities.
	
2. Common/ConfigManager.swift
	- You can adjust ur desired distance, radius, maximun monitoring count and etc
	
3. There is special test mode which is isWalking
   - isWalking mode have lesser regionRadius and it will create few geofence around user location, which also will bypass the geofences you add in Section 1
   - isWalking mode will active real time location finding when didUpdateLocations triggered.
   - The last commit isWalking mode is on, to edit it. Kindly go to AppDelegate.swift
   - Change ConfigManager.shared.setup(isWalking:true) to false
   