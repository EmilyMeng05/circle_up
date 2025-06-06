# Audit Report
Our app was audited by Group # 9
Location of Audit: CSE 340 Lecture, June 4th 2025


# Audit Feedback
- Our group received a couple pieces of feedback. First of all, we received feedback that the phone would vibrate even after the alarm would go off. Second, we received feedback that our semantic labels, especially for the login/signup buttons was not specific enough, potentially causing confusion as to what the buttons would be for. 


# How we addressed the feedback
- First, we addressed the semantic labels, by going through the login/signup pages, and making sure that each button and image had semantic labels and that these labels were as specific and clear as possible. Furthermore, we went through the remaining pages/files in the application to ensure that we had semantic labels, and that these labels achieved the purpose of working with the screen-reader. 

- Second, we addressed the alarm issue. We had a good bit of trouble getting the alarm to work with the application, and work consistently, thus we switched to a notification handler. Basically, when the alarm would go off, or whenever it was scheduled to go off, a notification would be sent, and the phone would not vibrate even if the alarm was continuously going off. Furthermore, the notification would work with the app closed, on, or even terminated, ensuring that these notifications would be sent in most scenarios for the users. 


