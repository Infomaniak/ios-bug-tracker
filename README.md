# InfomaniakBugTracker

Bug tracker component in Swift to add in iOS apps (internal use).

## Installation

1. In your Xcode project, go to: File > Swift Packages > Add Package Dependency…
2. Enter the package URL: `git@github.com:Infomaniak/ios-bug-tracker.git`

## Usage

### Configuration

Before presenting the bug tracker, you need to configure it like this:

```swift
BugTracker.instance.configure(with: BugTrackerInfo(
    accessToken: "<access-token>",
    route: "route", // route to find the project bucket (optional)
    project: "app-mobile-mail", // project name
    serviceId: 0 // service ID to find the project bucket (optional) 
))
```

### Checking that the user is staff

The bug tracker component can only be used by staff accounts. To check this, use the `isStaff` property of the `UserProfile` object (from [InfomaniakCore](https://github.com/Infomaniak/ios-core) package).

Note: the token needs the `user_info_staff` scope to be able to fetch this property.

### Present the view using SwiftUI

To present the bug tracker component using SwiftUI, simply return a `BugTrackerView` in a `sheet` or `NavigationLink`.

```swift
struct MyView: View {
    @State private var showingBugTracker = false

    var body: some View {
        VStack {
            Text("My view")
            Button("Present bug tracker") {
                showingBugTracker = true
            }
        }
        .sheet(isPresented: $showingBugTracker) {
            BugTrackerView(isPresented: $showingBugTracker)
        }
    }
}
```

### Present the view using UIKit

To present the bug tracker component using UIKit, simply present a `BugTrackerViewController` instance.

```swift
myViewController.present(BugTrackerViewController(), animated: true)
```
