# LogStore

Redirect NSLog on the fly into a file and present the log in your app when you need.

## Usage

**Activate redirection of NSLog**:

![](https://github.com/dasdom/LogStore/blob/master/ActivateLog.gif)

**Show log**:

![](https://github.com/dasdom/LogStore/blob/master/ShowLog.gif)

**Deactivate redirection of NSLog and delete stored log**:



## Installation:

- Put `LogStore.h` and `LogStore.m` into you project. 
- Add the following to you AppDelegate:

```objc
- (UIWindow *)window {
    if (!_window) {
        _window = [LogStore shakeableWindow];
    }
    return _window;
}
```
- Remember to remove the code prior to submitting to review.

## Licence

MIT

## Author

Dominik Hauser

[@swiftpainless](https://twitter.com/swiftpainless)
