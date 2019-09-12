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
pod 'CommonKeyboard'
````

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
        CommonKeyboard.shared.enabled = true

        return true
    }
}
```
`CommonKeyboard` will automatically scroll to the input view when the cursor focused and tapping on a space to dismiss keyboard. This working with UIScrollView and all inheritance classes including UITableView and UICollectionView
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
            guard let weakSelf = self else { return }
            var bottom = 0
            if info.isShowing {
                bottom = -info.visibleHeight
                if #available(iOS 11, *) {
                    bottom += weakSelf.view.safeAreaInsets.bottom
                }
            }
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

Sometimes there are many UIScrollView containers in UI Stack View and the CommonKeyboard cannot find the right one you can implement `CommonKeyboardContainerProtocol` and return specific container

```swift
extension ExampleChatViewController: CommonKeyboardContainerProtocol {
    var scrollViewContainer: UIScrollView {
        return tableView
    }
}
```

Others

```swift
 // dismiss keyboard
 CommonKeyboard.shared.dismiss()

 // get current UIResponder
 let responder = CommonKeyboard.shared.currentResponder
```

## Requirements
- **iOS9** or later
- **Swift 4.2** or later

## Contact
If you have any question or issue please create an [issue](https://github.com/kaweerutk/CommonKeyboard/issues/new)!

## License
CommonKeyboard is released under the [MIT License](https://github.com/kaweerutk/CommonKeyboard/blob/master/LICENSE.md).
