# MindFriend
 
Installation Guide
 
1.  Open the App Store on your Mac.
2.  Search for “Xcode”.
3.  Click Download (or Update, if already installed).
4.  Once installed, launch Xcode from your Applications folder.
5.  Accept the license agreement if prompted.
6.  Allow Xcode to install any required additional components.
7.  Open Xcode.
8.  Go to the menu bar and click Xcode > Settings (or Preferences).
9.  Navigate to the Components tab.
10. Look for iOS 16.x Simulator in the list.
11. Next from the command console. go into the backend foler
12. run npm install to install all dependencies
13. In the backend folder, create a .env file and paste this in
PORT=3000
MONGODB_URI = "mongodb+srv://emy1:SoftwareConstruction123@cluster0.kwxisml.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
MONGODB_DB = "MindFriend"
JWT_SECRET="your_super_secret_key"
14. after that run npm start to run the backend, make sure to do this before starting the Xcode simulation
15. There may be other packages not installed that node will notify you to install. If these errors pop-up, follow the error codes and download any and all instructions
11. Click the download icon next to it and wait for the installation to complete.
 
- Click on the Mindfriend folder on the left sidebar, the first folder with the apple store icon next to it. Go to Build Settings and ensure that your iOS Depoloyment Target is set to iOS 16.
 
How to Use it
Sign Up: If you don't have an account set up, click the sign up button, then sign in
Sign In: If you have an account already sign in
Add Friend: Seach for a username of a the person you want to friend. Note that it works more like a follow button. Adding someone is not reciprocal
Add Restriction: From the main feed, there should be a list of available apps. You can change what you want the restrction to be by clicking on the app and setting the field
Friend Feed: Any friends that you have followed will now have their exceeded apps displayed along with their justification for it
Add reason: to add reasons to your own exceeded apps, go to your feed and click the enter reason button. then select one of your exceeded apps, add a coment and save. This will not populate the feed of the friends you have
 
Limitations:
Because the Screentime API access required a $100 developer account, we have manually added dummy usage data to the user account to simulate how much time they might have spent on their apps. \
 
Functionality Description
A social app designed to help users regulate their screen time and be more mindful of their digital habits, particularly beneficial for individuals with ADHD.
