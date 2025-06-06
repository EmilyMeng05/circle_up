# Course Topics Applied
1) Accessing Phone Sensors
=> We access the phone's camera in order to upload photos:
- A critical part of our application is to upload photos, when the alarm goes off. Thus, we provide the user with an option to either
choose a photo from their library, or they can use their phone's camera in order to take a live photo, and upload to the server. 

2) Querying Web Services
=> Use Firebase API to perform authentication
- In our application, it is important that our users are authenticated in order to join a circle, upload their photos, and 
just basically use any of the core functionality of the application. Thus, we make use of Firebase's Authentication and make calls to the API
to perform sign-in, sign-up, in order to signin and signup users of our application. 

3) Persistence
=> Use Firebase Firestore and Cloud Storage
- In our application, we need to remember a particular user, if they have already been authenticated, and also store the circle information, so that when they reauthenticate, they are able to view the circle information they set when they signed up. Further, we should remember the photos the user uploaded, if it was within a certain timeframe, so that we can retrieve these photos and display them, upon the app being terminated and restarted. Thus, we use Firebase firestore for the database and firebase cloud storage to store the images. 

4) Undo/Redo
- If a user is trying to upload a photo, and they take a photo with their camera, the photo preview displays. However, if the user wants to use a different photo, for whatever reason, they can choose to take another photo, and the preview will update. However, if the user changes their mind again, they can use undo/redo in order to quickly retrieve any previous selections. From personal experience, many people take multiple photos and upload the best looking photo. However, there are times, when the initial photo taken was the best photo. Thus, having a way to remember this through the undo and redo, allows for our users to have a smooth experience, and go back "versions" of their photos. 


5) Gestures
- In our photo gallery, users can navigate through multiple photos by swiping right or left, in order view the photos. These photos make use of GestureDetection, and use the onPan gesture in order to detect the swipe. Further, to ensure that it is actually a proper swipe and not mistaken for a mis swipe, there is a decent buffer room encoded for the distance, so that mis clicks or mis taps would not be mistaken for a swipe. 


# Learnings from Accessibility in App Design

One of the major learning from the Accessbility in Design lecture from CSE 340 was the fact that "You are NOT the user". In designing our application, this was important to us, since we wanted to design the UI to be both minimal/simple, but also easy to navigate for people of all kinds of backgrounds/perspectives. Thus, we built a UI, where the background and buttons had a noticable constrast (black buttons, light grey background),making it clear to actually see the UI elements. Furthermore, we included semanticLabels throughout the codebase, so that incase someone is using a screenreader/talkback on the application, they are also able to understand how to use the application, and not be confused. In general, as explained in lecutre "designing for the most exteme case results in designs that benefit many people". Thus, we felt that the overall app functioned better and was easier to use, when we designed for the most extreme cases, as many of these changes just benefit and help the user experience as a whole. 

# Citations

1) https://www.youtube.com/watch?v=Dh-cTQJgM-Q
- This video, we learned about how to use TextFieldController, in order to get user
input, and also were inspired to make a simple UI for the login and sign-up views.

2) https://mercyjemosop.medium.com/select-and-upload-images-to-firebase-storage-flutter-6fac855970a9 
- This article helped understand how to upload images to firebase storage through flutter

3) https://www.fluttermapp.com/articles/local-notifications (Local Notifications for the Alarm)
- This article helped us understand how to get flutter local notifications working
- https://www.youtube.com/watch?v=uKz8tWbMuUw (Scheduling Notifs) => This video helped us understand how to do scheduled notifications for the alarm 

4) https://firebase.google.com/docs/auth/flutter/password-auth
- This contains the documentation for FireBase auth API for flutter specifically

5)https://api.flutter.dev/flutter/material/showTimePicker.html
- Documentation for showTimePicker in order to select the alarm time in the noGroup page


# Futher Understanding
In terms of presenting a challenge, this project was quite challenging for our group to work with. There was significant coding required, to get each feature working, and the code to handle user authentication, photo upload/storage, and lobby/circle creation was quite difficult, as it was not just to do with writing code. When working with a project with this much complexity, we found that it was a lot more the thinking and planning that helped us solve these challenges, as if we knew the "schemas" for the database, and planned out all of the potential things we would need to store, the code was much easier to write. While the backend portion was complicated enough, we also needed to display all of this in a nice and presentable manner in the UI/views, which was also a pretty major challenge, as each feature was basically a step up from what we had done in the class projects. 


In terms of deepening our understanding, we felt that we had a much better understanding of how to use Firebase. While some members of our group had experience using firebase, it was quite difficult to actually integrate this into flutter, since none of us had used firebase in flutter before. However, after finishing this project, we learned how to use firebase's various functionality, and also learned how to plan out and map out a major project. In terms of the topic, I think we gained significant experience for the gestures, web services, and persistence. The persistence we used in Journal was quite simple compared to the persistence we used in this application, as we needed to plan out extensively what we wanted to store, why we wanted to store particular objects/metadata, prior to writing a single line of code. In terms of the gesture detection, we actually were able to implement this in a way, that made a core feature of our application better, as a user could swipe through the gallery of photos, in a relatively smooth manner. Finally, we gained a lot of experience working with the Firebase authentication and making calls to the API. While the weather app made a call to an external API, we did not do too much practice in the course making API calls, and to have firebase as the first major API call (for authentication service), it was definitely a challenge. Overall, we felt that the functionalities we built into the application stretched our programming skills, and overall deepened our understanding of the concepts we covered in CSE 340 (both in lecture and course projects).


# Original Concept to Final Implementation
One of the big things that changed from the concept to the final implementation was the actual alarm notification. Prior to starting the development process, we wanted to sound an alarm, kind of like how the regular phone alarm would. However, there was quite a bit of unforseen complication trying to implement the alarm, which we only realized as we got deep into implementing the alarm, and in terms of the application's main goal, it was to foster a sense of accountability, which we could also get across via a push notification, instead of the alarm sounding. Especially since we were did not implement a function to have multiple alarms like a regular alarm app, it did not make sense, to fully replace a regular alarm app, but act as a companion app, where we foster connections, and accountability with the rest of our key features. Thus, instead of having an alarm sound, we decided to send a push notification to all members in the group when the alarm fires/to upload their photo for the day. 


# Future Goals
- While we are quite happy with the way the application turned out, there are directions, and stretch goals we would like to explore in the future. The first one is actually integrating what we call the "failure" counter. Initially, this was a stretch goal in our design doc, and the idea was that if the user uploaded their photo way past their alarm time, we would count this photo as a "failed" attempt, and thus, everyone in the group would know that this photo was late. Another feature we want to implement is the ability for the user to have a personal alarm, and a group alarm, and the ability to cycle through them or turn one on and off. Currently, the only alarm that we send notifications for are the alarms for the group, however, this is not the most useful feature, as if someone wants to wake up at a different time from their group, this would not be possible with the current implementation of the app. 

In terms of increasing the accessibility and usability, we would like to do a couple of things. First, implement internationalization. Currently the application supports only the english language, and while that could cater to a decently large userbase, it basically becomes useless for over half the world, who would not speak or read english. Thus, if we have language support for multiple languages (eg: Spanish, French, Chinese), then we would cater towards a much larger audience, and overall have larger and more engaged user base. The second, as mentioned would be having a personal and group alarm. This would help increase the usability of the application, as user's right now have the same notification/alarm time, as everyone else in their circle, which is not the most useful thing, since people might have different wake-up times for various reasons. Thus, implementing this feature, where users can choose their alarm times, or toggle the group vs solo alarm on and off could again increase the usability of the application. Finally, we could implement ways to take photos using third party devices, to make it easier for people who might use a stylus, to take photos, as right now, there is not explicit support for that in our application. Overall, we believe there are tons of possibilities and a lot of potential for this app. 


# Final 340 Notes
- The most valuable thing that we learned in CSE 340 was to read documentation. Most courses in the CSE department just either explain everything you need to know to complete the project in the spec, or they cover every single thing in the class. However, CSE 340, while covering the important concepts in class and section, would also allow for a little bit of excercise for the student, to read through the flutter documentation, in order to find specific things. This is something we feel is valuable, since in the real-world, this is something programmers should be able to do, and is an important skill to have. 

- In terms of 2 to 3 pieces of advice that we would give future students, it would be to 1) have an open mind, and 2) take the extra steps to go above and beyond on the course projects to implement some of the optional goals. Briefly covering each, the lectures and section structure in general was a little different from most other CS courses in our experience, and thus, it was initially a weird experience. However, as we progressed through the quarter, some of the course content, and edstem lessons began making more and more sense, as these concepts were helpful in some of the course projects, and especially the final project. In general, the content in the course was just a little different from the typical CS theory courses we had experience with, and thus having an open mind would be something that most other students should have coming in. For the second piece of advice, a lot of the course projects, are pretty doable to get the base version done, in order to receive credit. However, they can also be extended to have tons and tons of cool functionality, that if explored, can lead to other learning, and help for the final project, as you would get more and more comfortable with flutter and dart. In general, it was kind of you get what you put into it, and the advice we would say for future students would be to really take time and try to implement these stretch features, even if they never end up finishing it, since even thinking about it is a great first step. 