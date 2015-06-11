# BRYXStackView

[![CI Status](http://img.shields.io/travis/Harlan Haskins/BRYXStackView.svg?style=flat)](https://travis-ci.org/Harlan Haskins/BRYXStackView)
[![Version](https://img.shields.io/cocoapods/v/BRYXStackView.svg?style=flat)](http://cocoapods.org/pods/BRYXStackView)
[![License](https://img.shields.io/cocoapods/l/BRYXStackView.svg?style=flat)](http://cocoapods.org/pods/BRYXStackView)
[![Platform](https://img.shields.io/cocoapods/p/BRYXStackView.svg?style=flat)](http://cocoapods.org/pods/BRYXStackView)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Screenshot

![Screenshot](Screenshot.png)

### Code

Any time you add a subview to a StackView, it's automatically re-positioned within the stack.

There are four functions exposed by StackView.

```swift
func addSubview(view: UIView)
func addSubview(view: UIView, withEdgeInsets edgeInsets: UIEdgeInsets)
func removeAllSubviews()
func batchUpdates(updates: () -> (), completion: (() -> ())? = nil)
```

If you're adding many subviews, it's recommended that you add them
within a call to `batchUpdates()`

```swift
self.stackView.batchUpdates({
    self.stackView.addSubview(UIView())
    self.stackView.addSubview(UIView())
    self.stackView.addSubview(UIView(), withEdgeInsets: UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 15.0))
    self.stackView.addSubview(UIView())
})
```

This will ensure the constraints are only created once, and you'll get much
better performance.

## Requirements

iOS 8, if installing through CocoaPods, otherwise iOS 7.

## Installation

BRYXStackView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "BRYXStackView"
```

## Authors

Harlan Haskins, harlan@bryx.com

Adam Binsz, adam.binsz@bryx.com

## License

BRYXStackView is available under the MIT license. See the LICENSE file for more info.
