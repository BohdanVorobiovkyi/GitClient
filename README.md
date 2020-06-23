# GitClient
App for searching repositories on GitHub.

Main Data Controller class -> DataController

Cocoa:
Kingfisher > Images (Downloading/ Caching/ Retrieving images)
ProgressHUD > Activity indicator
CoreData > Storing last search results (1 Entity)
SnapKit > Programmatic Autolayout

App Responsibilities: 
- Displaying search results from the CoreData and URLrequests.
- "Infinite" scrolling. New batch loading, when user reaches the end of collection.
- ProgressHUD activity indicator is added.
- Image caching and placeholders for imageViews.
- Sorting by stars.
- Cancel will clean last results.

Details Screen
- Presented Details Screen
- GitHub repository link with redirection to Safari
