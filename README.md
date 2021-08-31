# BottomCardController

### About
Controller with sheet style. You can customize height or suppport modal style in iOS 12.

Simple adding close button and centering arrow indicator. Customizable height. Using custom `TransitionDelegate`.


## Navigate

- [Installation](#installation)
    - [Swift Package Manager](#swift-package-manager)
    - [Manually](#manually)
- [Quick Start](#quick-start)
- [Usage](#usage)
    - [Light StatusBar](#light-statusbar)
    - [Custom Height](#custom-height)
    - [Close Button](#close-button)
    - [Arrow Indicator](#arrow-indicator)
    - [Dismissing](#dismissing)
    - [Corner Radius](#corner-radius)
    - [Haptic](#haptic)
    - [Snapshots](#snapshots)
    - [Working with UIScrollView](#working-with-uiscrollview)
    - [UITableView & UICollectionView](#working-with-uitableview--uicollectionview)
    - [Confirm before dismiss](#confirm-before-dismiss)
    - [Delegate](#delegate)
    - [Modal presentation of other controller](#modal-presentation-of-other-controller)


## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

To integrate `BottomCardController` into your Xcode project using Xcode 11, specify it in `Project > Swift Packages`:

```ogdl
https://github.com/rdscoo1/BottomCardController
```

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate `BottomCardController` into your project manually. Put `Source/BottomCardController` folder in your Xcode project. Make sure to enable `Copy items if needed` and `Create groups`.

## Quick Start

Create controller and call func `presentBottomCard`:

```swift
import UIKit
import BottomCardController

class ViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let controller = UIViewController()
        self.present(controller)
    }
}
```

If you want customize controller (remove indicator, set custom height and other), create controller and set `transitioningDelegate` to `BottomCardTransitioningDelegate` object. Use `present` or `dismiss` functions:

```swift
let controller = UIViewController()
let transitionDelegate = BottomCardTransitioningDelegate()
controller.transitioningDelegate = transitionDelegate
controller.modalPresentationStyle = .custom
controller.modalPresentationCapturesStatusBarAppearance = true
self.present(controller, animated: true, completion: nil)
```

Please, do not init `BottomCardTransitioningDelegate` like this:

```swift
controller.transitioningDelegate = BottomCardTransitioningDelegate()
```

You will get an error about weak property.

## Usage

### Light StatusBar

To set light status bar for presented controller, use `preferredStatusBarStyle` property. Also set `modalPresentationCapturesStatusBarAppearance`. See example:

```swift
import UIKit

class ModalViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
```

### Custom Height

Property `customHeight` sets custom height for controller. Default is `nil`:

```swift
transitionDelegate.customHeight = 350
```

### Close Button

Property `showCloseButton` added circle button with dismiss action. Default is `false`:
```swift
transitionDelegate.showCloseButton = false
```

### Arrow Indicator

On the top of controller you can add arrow indicator with animatable states. It simple configure.
Property `showIndicator` shows or hides top arrow indicator. Default is `true`:

```swift
transitionDelegate.showIndicator = true
```

Property Parameter `indicatorColor` for customize color of arrow. Default is `gray`:

```swift
transitionDelegate.indicatorColor = UIColor.white
```

Property `hideIndicatorWhenScroll` shows or hides indicator when scrolling. Default is `false`:

```swift
transitionDelegate.hideIndicatorWhenScroll = true
```

### Dismissing

You can also configure events that will dimiss the controller.
Property `swipeToDismissEnabled` enables dismissal by swipe gesture. Default is `true`:

```swift
transitionDelegate.swipeToDismissEnabled = true
```

Property `translateForDismiss` sets how much need to swipe down to close the controller. Work only if `swipeToDismissEnabled` is true. Default is `240`:

```swift
transitionDelegate.translateForDismiss = 100
```

Property `tapAroundToDismissEnabled` enables dismissal by tapping parent controller. Default is `true`:

```swift
transitionDelegate.tapAroundToDismissEnabled = true
```

### Corner Radius

Property `cornerRadius` for customize corner radius of controller's view. Default is `10`:

```swift
transitionDelegate.cornerRadius = 10
```

### Haptic

Property `hapticMoments` allow add taptic feedback for some moments. Default is `.willDismissIfRelease`:

```swift
transitionDelegate.hapticMoments = [.willPresent, .willDismiss]
```

### Snapshots

The project uses a snapshot of the screen in order to avoid compatibility and customisation issues. Before controller presentation, a snapshot of the parent view is made, and size and position are changed for the snapshot. Sometimes you will need to update the screenshot of the parent view, for that use static func:

```swift
BottomCardController.updatePresentingController(modal: controller)
```

and pass the controller, which is modal and uses `BottomCardTransitioningDelegate`.

If the parent controller scrollings and you try to show `BottomCardController`, you will see how it froze, and in a second its final position is updated. I recommend before present `BottomCardController`  stop scrolling force:

```swift 
scrollView.setContentOffset(self.contentOffset, animated: false)
```

### Working with UIScrollView

If you use `UIScrollView` (or UITableView & UICollectionView) on controller, I recommend making it more interactive. When scrolling reaches the top position, the controller will interactively drag down, simulating a closing animation. Also available close controller by drag down on `UIScrollView`. To do this, set the delegate and in the function `scrollViewDidScroll` call:

```swift
func scrollViewDidScroll(_ scrollView: UIScrollView) {
    SPStorkController.scrollViewDidScroll(scrollView)
}
```

### Working with UITableView & UICollectionView

Working with a collections classes is not difficult. In the `Example` folder you can find an implementation. However, I will give a couple of tips for making the table look better.

Also, I recommend setting bottom insets (it optional):

```swift
tableView.contentInset.top = self.navBar.height
tableView.scrollIndicatorInsets.top = self.navBar.height
```

Please, also use `BottomCardController.scrollViewDidScroll` function in scroll delegate for more interactiveness with your collection or table view.

### Confirm before dismiss

For confirm closing by swipe, tap around, close button and indicator use `BottomCardControllerConfirmDelegate`. Implenet protocol:

```swift
@objc public protocol SPStorkControllerConfirmDelegate: class {
    
    var needConfirm: Bool { get }
    
    func confirm(_ completion: @escaping (_ isConfirmed: Bool)->())
}
```

and set `confirmDelegate` property to object, which protocol impleneted. Function `confirm` call if `needConfirm` return true. Pass `isConfirmed` with result. Best options use `UIAlertController` with `.actionSheet` style for confirmation.

If you use custom buttons, in the target use this code:

```swift
BottomCardController.dismissWithConfirmation(controller: self, completion: nil)
```

It call `confirm` func and check result of confirmation. See example project for more details.

### Delegate

You can check events by implement `BottomCardControllerDelegate` and set delegate for `transitionDelegate`:

```swift
transitionDelegate.storkDelegate = self
```

Delagate has this functions: 

```swift
protocol BottomCardControllerDelegate: class {
    
    optional func didDismissStorkBySwipe()
    
    optional func didDismissStorkByTap()
}
```

### Modal presentation of other controller

If you want to present modal controller on `BottomCardController`, please set:

```swift
controller.modalPresentationStyle = .custom
```

It’s needed for correct presentation and dismissal of all modal controllers.