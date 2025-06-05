# Circle Up App (README)

Note: The application is best run on a phone, especially an android phone running Android 13+, in order
to view all of the notifications (when the alarm time hits) and also upload and view the photo's without any issues. 

# Instructions to Run the Project
Android:
- Flutter clean: In order to remove any conflicting dependencies
- Flutter pub get: In order to install any required packaged
** Flutter pub get should be enough however, to run the project as, all of the packages should be installed **

IOS:
<FILL IN>

IMPORTANT: Our project makes use of Firebase, and thus, we use a .env file in order to store our API keys and secrets
- In order to actuall run the application, these keys must be used, and the content of the .env file should have been emailed to the professors.
The .env file should work as long as it is in the same directory as the main project i.e. code/circle_up

In order to get the application running, please use the command Flutter run --release and then make sure that notifications for the application are enabled, in the phone settings.

At this point the application should properly build and run: If there are any issues, ensure that Firebase CLI has been installed, and you are running on an Android OS 13+, however,
the packages should already be installed, and running flutter pub get should resolve any issues. 


# How to Interact/Use the app (Basic)
1) Authenticate with the app
- New users should sign-in, and existing users should login to the application

2) If the user is NOT part of an existing circle, either they can join a circle, or create their own circle with their custom alarm

3) Ideally, upon waking up at their desired alarm time, the user cna then upload their daily photo, and then also view a gallery of all of the members photos in the circle


# Core Files and Their Purposes
Our app has a couple major components:
1) Authentication
- Login / Sign - up

At the high level, the authentication is used to login and sign up users to the application. We also have various other files, that are related to a user, which we will explain below: 

In terms of the backend, the main files are auth/auth.dart, auth/auth_provider.dart, models/user.dart, and services/user_service.dart.
Below is a more detailed explanation of each of the files:

1) auth/auth.dart:
- Contains the API calls to Firebase to complete the authentication
=> Login, Signup, Signout, and isAuthenticated
- This file contains just the functions, that call the Firebase API, whereas AuthProvider, is used to actually call those functions and use them throughout the application

2) auth/auth_provider.dart
- This file is the classic provider class that extends the notifier class as we have done in class. The reason that auth and auth_provider were separated is that the logic from auth, if changed, would not affect the way that the code in auth_provider was written, and thus was easier in a developmental perspective for us. This provider is the only instance of the auth object, and it is passed around the code, in order to get user information. 

3) models/user.dart
- This contains the class definiutions for the user object, called AppUser. 
While the auth code contains the functions to actually make the API calls, we wanted to store user metadata, and for this, we created a user object, which we would then store in the firestore database to make sure it was persistent. This allowed for us to track the user's id, name, email, and also eventually handle them joining a particular group. 

4) services/user_service.dart
- This file contains the class UserService, which contacts the firestore database to actually make the function calls in order to create, update, read, and write to the database, in terms for updating the user object. As an example, if a user logs into the application, we need to make an API call to actually create and signup the user, but we also need to store their metadata into the firestore database right after. Thus, thus user_service, handles the latter portion of storing the metadata into the firestore database, as its functions implement the CRUD operations. The functions are also written, so that we can eventually handle operations where a user leaves a certain group, or joins a group, easily allowing us to call functions from a singular class. 



2) Lobby Creation

- NoGroup / Circle Page
At a high level, the purpose of this is actually giving an authenticated user, the ability to create and or join an existing group, or "circle" as we like to call it. 
For example, if a users friend has already created a "circle", all the user needs to do is type the circles code and they will join the group. However, if the user wants to create their own circle, they can also do that. 

The files crucial to this portion of our app are:

- models/alarm_circle.dart, 
- services/alarm_circle_service.dart
- views/no_group_page.dart
- views/circle_page.dart

Below is a detailed explanation of each of the files:

1) models/alarm_circle.dart
- Once again, in our application persistence is quite crucial, and thus, we needed a way to store metadata about a circle/group. Thus, this alarm_circle file contains the class defintion that contains metadata about a circle, such as its id, the ids of the members, the set alarm time, and others. 

2) services/alarm_circle_service.dart
- This contains the core functionality of actually creating the circle. 
Functions such as generating the random 6 digit code, creating the circle in the firestore database, ensuring a user can either join an existing circle, or create a new circle, and also a user leaving the circle. Further, all of these functions make calls to the firestore database in order to make sure that a user action is persistent and updated. 


3) Photo Upload / Gallery View

This is the third crucial part of our application, as a user should be able to upload a photo and view all the photos in a circle in a 24 hour span. 

The file crucial to this functionality are photos/photo.dart. 

1) photos/photo.dart
- In this file, we have functions, which when called allow for the user to upload a photo to firebase's cloud storage, get their photos, and also get all the photos from a circle, in order to display. Basically, when a user uploads a photo, functions from this class are called, and in order to persist the photos, and actually store them, we make use of Firebase's cloud storage, to store the actual photos and then retrieve them when needed. 


4) Notifications
We found that the best way to notify a user of their alarm was to send them a notification from our app, saying their alarm has gone off, and they can then go ahead to upload their photo for the day. 

The file critical to this is: services/notification_service.dart
- In this file, we make use of flutter_local_notification to send the notification to the user, when their alarm goes off. The notifications are "persistent" as they fire when the app is closed, if a user terminated the app, or if the user is still on the application at the time of the alarm going off. 



Above are all of the "backend" files. Now, below, we will explain all of the views, and how we integrate the backend code to work with and actually display and help navigate through the application. 

First, the key is **main.dart**, where we make use of routing, in order to actually move from page to page. In main.dart, we define the routes for the various pages, we use such as /login, /signup, and we default to the /login route, when the app is initially opened. 

Next, the UI for the /login and /signup pages are implemented via the **views/auth_modal.dart** (login), and **views/sign_up.dart** (signup). 
At the heart of this implementation lies the custom components, enter_button, and text_field, which are defined in components/enter_button.dart, components/text_field.dart. The text field handles the logic of the textControllerField, which we use to read the user's text input for the email and password when logging in or signing up. The enter_button is a custom button widget, which is reused various times throughout the code, to perform onTap operations with. 


Once the user is logged in or signed up, they will be taken to noGroup page, if they are NOT in a circle, or they will be taken to circle_page, if they are already in a circle.
In views/circle_page, we allow for a user, to either join a group, by typing in the existing code, once again making use of the custom text widget, or they can create a new group. Both of these actions, will make use of the backend logic we mentioned for the circle lobby logic. Further, the user if they are creating a group, can select an alarm time, by interacting with the timePicker widget. 


In the views/circle_page, this displays the actual group information. It displays all of the members in the group, the time the alarm is set for (daily), and also allows for a user to leave the group at any time. Further, there are two buttons at the very top, where a user can upload photos, or view the photo gallery, if there are any photos they can view. 



Finally, for uploading and viewing photos, there are the files:
views/upload_photos.dart, which handles the UI for uploading a photo, and then views/photo_gallery.dart, which displays the photos in a nice manner. The user can upload the photos, either by choosing a photo from their phone gallery, or they can take a picture through their camera. 



# How our app hits the 5 implementation goals
1) API
- We make calls to the Firebase API in order to perform user authentication, thus we hit the goal for making calls to an external API

2) Persistence
- We make use of both firebase cloud storage and the firestore database, in order to store pictures and user/circle metadata, and make various CRUD calls. 

3) Sensors
- One of the core functionalities of the application is to take photos and upload, and we make use of the user's camera to take photos and upload it to the database. 

4) Undo/Redo
- When uploading a photo, the user can select a photo, and prior to uploading it, if they choose to, they can undo their selection. However, if they feel like they would like to go back, they can click the redo button. 

5) GestureDetection
- In the photogallery, the user can swipe left and right in order to cycle through the various photos, making use of the onPan* with the gesturedetection widget in flutter. 











