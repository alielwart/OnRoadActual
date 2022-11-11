# OnRoad

OnRoad is an iOS mobile application that provides haptic feedback during navigation.

## Installation:

1. Navigate to the main branch and clone it to local machine

2. Navigate to Terminal and go to the home directory. Create a .netrc file if one does not already exist and copy/paste the following code, then save.

```bash
machine api.mapbox.com
login mapbox
password YOUR_SECRET_MAPBOX_ACCESS_TOKEN
```

Email lillywu@umich.edu for the secret access token!

3. Open the main branch in Xcode. Go to preferences -> account -> + button to add your apple developer account through your appleID.

4. Click on the outermost OnRoad with the blue icon to the left.
  1. Make sure you're in project -> onRoad -> Info. Check the the iOS deployment is 15.0 at least (if you plan to run this on an iPhone, your device must          also be at least iOS 15.0.
  4b. Click on package dependencies and make sure you see MapBoxNavigation with at least version 2.8.0
  4c. Navigate to targets -> OnRoad -> General. Again check for iOS 15.0.
  4d. Click on Signing & Capabilities. The team should be selected as <Your appleID Name> (Personal Team), anywhere else this option shows up, make sure that the selection is the same (do the same for OnRoadTests & OnRoadUITests)
  4e. Choose a unique bundle identifier to be provisioned to your account. This may not be necessary always, but to be safe choose a uniwue identifier, e.g. OnRoad<your last name>. Doing so, a prompt will appear for you to enter your device's (laptop) password. Type it in and click always allow...the prompt may still be there so repeat the step (about 6~ times) until it disappears. (Not clear why it does this but it's trying to access keychain and may have something to do with provisioning to the Apple developer account.
  
Try Building the Application to an iPhone 14 Pro device as the simulator.
  
If the build fails, close Xcode and quit the application. From Github Desktop/Terminal/Xcode, open the main branch once again but wait for the packages to index. You should see these packages show up.
  
  <img width="270" alt="Screen Shot 2022-11-10 at 10 53 40 PM" src="https://user-images.githubusercontent.com/55675415/201259628-3f1ba8fa-54f8-480c-a356-384c01fc04ab.png">
  
Once the packages are indexed and no longer have a loading icon to the right, try building again and it should succeed.

  
 



