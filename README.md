# LogStore

Redirect NSLog on the fly into a file and present the log in your app when you need.

## Usage

**Activate redirection of NSLog**:

![](https://github.com/dasdom/LogStore/blob/master/screenshots/ActivateLog.gif)

**Show log**:

![](https://github.com/dasdom/LogStore/blob/master/screenshots/ShowLog.gif)

**Deactivate redirection of NSLog and delete stored log**:

![](https://github.com/dasdom/LogStore/blob/master/screenshots/DeactivateLog.gif)

**Indicator at the top left that redirection into file is active**:

![](https://github.com/dasdom/LogStore/blob/master/screenshots/RedirectIndicator.JPG)

**Log**:

![](https://github.com/dasdom/LogStore/blob/master/screenshots/Log.PNG)

## Installation:

- Put `LogStore.h` and `LogStore.m` into you project. It's tiny. Just 178 cloc.
- Add the following to you AppDelegate:

```objc
- (UIWindow *)window {
    if (!_window) {
        _window = [LogStore shakeableWindow];
    }
    return _window;
}
```
- Remember to remove this code prior to submitting to review.

### Swift 

Swift does not print to stderr by default. So to redirect `print()` in Swift to the same file, add this code:
```swift
import Foundation

var standardError = FileHandle.standardError

extension FileHandle : TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.write(data)
    }
}
```
and use `print("foobar", to:&standardError)` instead of `print("foobar")`.

## Licence

MIT

## Author

Dominik Hauser

[@swiftpainless](https://twitter.com/swiftpainless)
