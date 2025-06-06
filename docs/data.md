# Data Design
=> This section will contain information about the datastructures/classes that we designed
1) User Data Structure
- File: lib/models/user.dart

In this file the AppUser class represents the user object
- This object is basically all of the metadata that we need to track for a particular user. In designing this, we designed it to include ALL of the metadata that we would potentially require, including for our stretch goals. The reason for this is that any change/modification to these custom objects, would mean that there could be an issue with 'old' versions vs 'new' versions especially with integrating in a database setting. Thus, we created the data structure called AppUser, containing all of the metadata we would possibl need, such as their uid, email, displayName, createdAt, and all of the group information. 


2) Alarm Circle Structures
- File: lib/models/alarm_circle.dart
The alarm circle object represents the data structure which stores all of the information/metadata regarding the lobby that is created, when a user creates a new circle. In designing this datastructure, we needed to track all of the information, such as the unique circle_id, the code, the alarmTime, all of the memberIds (people who are part of the group), and then who created it. Once again, the way we designed was that we would track everything that we would possible need, and in case, we found that we didn;t need something, we could always make something optional, null, or pass in some dummy value. What this does, is that it avoids the issue of wanting to add something in when we are signinficantly deep into the development process, and messing up the database schema. Thus, we took the careful appraoch of doing too much than too less. 




# Data Flow
=> This function will contain the Dataflow, and how we use the datastructures in our code via providers

In terms for the dataflow, we make use of the provider, for the authentication. Basically, this allows for us to track the state, and then pass this provider around throughout the various files, and call the functions, maintaining a single global state throughout the entire codebase. We designed it in this fashion since we wanted to have a singleton instance of the authentication, so that we could have persistent authentication. While we did not get to implementing this portion fully, wehre the user is automatically taken to the circle_page upon opening the application, this was a feature we had discussed and thus, having a auth_provider helped us track the user's authentication (whether they had been authenticated, and if they were signed in or not). We basically called the code throught the auth provider object in order to sign_in and sign_up, in our login and signup pages. In these functions, we would create and or update the user object as discuseed in the previous section, and then upadate the data inside the firebase firestore database, to ensure persistence. 


## Services

In our code, we have a services folder, which contains user_service, 
notification_service, and alarm_circle_service. While this does not create a data structure per say, it is extremely crucial to the dataflow, since the functions in alarm_cricle_service, and user_service, are called to actually persist the user and circle objects to the firestore database. Basically, whenever these objects are created, we cannot just leave them as be, since upon termination and re-opening of the app, nothing would be saved. Thus, we implement persistence, through these files, and when the user signs up, we will create an AppUser object, and update the database. Similarly, upon login, we will update the AppUser object, and then update the database. In case, we need to retrieve something from the database, such as getting the user's email or uid, we can call functions from these services. 

