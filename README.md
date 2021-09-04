# CommonKeyboard
An elegant Keyboard library for iOS. simple, lightweight and standalone no sub-dependencies required

![Swift](https://img.shields.io/badge/Swift-4.2.0-orange.svg)
![Swift](https://img.shields.io/badge/License-MIT-brightgreen.svg)

![CommonKeyboard](https://user-images.githubusercontent.com/7533178/64553337-c5806c00-d36b-11e9-8fa6-e2cc5c4e1371.gif)
![CommonKeyboardObserver](https://user-images.githubusercontent.com/7533178/64553367-d204c480-d36b-11e9-881d-0974d81e4619.gif)

## Installation

#### [CocoaPods](https://cocoapods.org/)
Add the following to your `Podfile`
````
pod 'CommonKeyboard', :git => 'https://github.com/kaweerutk/CommonKeyboard.git', :tag => '1.0.6'
````
***  Note: I lost my `cocoapods trunk` account because I cannot figure out my yahoo email password :( so you have to specify `:git` and `:tag` to get the latest version of the CommonKeyboard
#### [Carthage](https://github.com/Carthage/Carthage)
Add the following to your `Cartfile`
````
github "kaweerutk/CommonKeyboard"
````

## Usage
In AppDelegate.swift, just `import CommonKeyboard` framework and enable CommonKeyboard.
```swift
import CommonKeyboard

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Just enable a single line of code
        // Supported UIScrollView or a class that inherited from (e.g., UITableView or UICollectionView)
        //
        // *** This doesn't work with UITableViewController because they've a built-in hander ***
        //
        CommonKeyboard.shared.enabled = true

        return true
    }
}
```
`CommonKeyboard` will automatically scroll to the input view when the cursor focused and tapping on a space to dismiss keyboard. This working with UIScrollView and all subclasses including UITableView and UICollectionView
(<strong>Note:</strong> This does not support `UITableViewController` because it will handle by itself)

Adjust an offset between keyboard and input view by set `keyboardOffset` the default value is 10, Or ignore common keyboard by giving `ignoredCommonKeyboard` a true value.

```swift
 textField.keyboardOffset = 20
 textField.ignoredCommonKeyboard = true

 textView.keyboardOffset = 2
 textView.ignoredCommonKeyboard = false
```

#### CommonKeyboardObserver
You can subscribe `CommonKeyboardObserver` to get keyboard notification info.

```swift
import CommonKeyboard

class ExampleChatViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    let keyboardObserver = CommonKeyboardObserver()

    override func viewDidLoad() {
        super.viewDidLoad()
        // drag down to dismiss keyboard
        tableView.keyboardDismissMode = .interactive

        keyboardObserver.subscribe(events: [.willChangeFrame, .dragDown]) { [weak self] (info) in
            guard let self = self else { return }
            let bottom = info.isShowing
                ? (-info.visibleHeight) + self.view.safeAreaInsets.bottom
                : 0
            UIView.animate(info, animations: { [weak self] in
                self?.bottomConstraint.constant = bottom
                self?.view.layoutIfNeeded()
            })
        }
    }
}
```

All events
```swift
public enum CommonKeyboardObserverEvent {
    case willShow
    case didShow
    case willHide
    case didHide
    case willChangeFrame
    case didChangeFrame
    case dragDown // scroll.keyboardDismissMode = .interactive
}
```

Sometimes there are many UIScrollView containers in UI Tree View and the CommonKeyboard cannot find the right one you can implement `CommonKeyboardContainerProtocol` and return specific container

```swift
extension ExampleChatViewController: CommonKeyboardContainerProtocol {
    var scrollViewContainer: UIScrollView {
        return tableView
    }
}
```

Misc

```swift
 // dismiss keyboard
 CommonKeyboard.shared.dismiss()

 // get current UIResponder
 let responder = CommonKeyboard.shared.currentResponder
```

Debugging

```swift
// enable debug mode to print out keyboard info
 CommonKeyboard.shared.debug = true


// ** Sample output **
/*
----- CommonKeyboard debug enabled -----
- isShowing:  true
- keyboardFrameBegin:  (0.0, 896.0, 414.0, 243.0)
- keyboardFrameEnd:  (0.0, 550.0, 414.0, 346.0)
- visibleHeight:  346.0
- isLocal:  true
- scrollContainer:  <UITableView: 0x103820e00; frame = (0 92; 414 700); clipsToBounds = YES; autoresize = RM+BM; gestureRecognizers = <NSArray: 0x28223a310>; layer = <CALayer: 0x282cf2960>; contentOffset: {0, 0}; contentSize: {414, 0}; adjustedContentInset: {0, 0, 0, 0}; dataSource: (null)>
------
*/

// ** Sample output incase CommonKeyboard could not find `scrollContainer` **

/*
 ----- CommonKeyboard debug enabled -----
- isShowing:  true
- keyboardFrameBegin:  (0.0, 896.0, 414.0, 243.0)
- keyboardFrameEnd:  (0.0, 550.0, 414.0, 346.0)
- visibleHeight:  346.0
- isLocal:  true
- scrollContainer:    
   ***** 
     COULD NOT FIND `scrollContainer` 
     YOU BETTER TO IMPLEMENT `CommonKeyboardContainerProtocol` 
     IN `topViewController` (<KeyboardExample.FormViewController: 0x10570a150> 
     TO RETURN SPECIFIC `scrollContainer` 
   *****
------
*/
```

## Requirements
- **iOS9** or later
- **Swift 4.2** or later

## Contact
If you have any question or issue please create an [issue](https://github.com/kaweerutk/CommonKeyboard/issues/new)!

## License
CommonKeyboard is released under the [MIT License](https://github.com/kaweerutk/CommonKeyboard/blob/master/LICENSE.md).
