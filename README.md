# GitClient
App for searching repositories on GitHub. (iOS 12.0)

DataController class -> class for working with datasource.
NetworkService class -> networking class.

Cocoa:
Kingfisher > Images (Downloading/ Caching/ Retrieving images)
ProgressHUD > Activity indicator
CoreData > Storing last search results (1 Entity)
SnapKit > Programmatic Autolayout

For parsing and serializtion fo the jsons with JSONSerialization & Decodable

App Responsibilities: 
- Displaying search results from the CoreData and URLrequests.
- "Infinite" scrolling. New batch loading, when user reaches the end of collection.
- ProgressHUD activity indicator is added.
- Image caching and placeholders for imageViews.
- CollectionViewFlowLayout. (ResultCell > CollectionVeiwCell)
- Sorting by stars.
- Cancel will clean last results.

Details Screen
- Presented Details Screen
- GitHub repository link with redirection to github repository directly (Safari).
