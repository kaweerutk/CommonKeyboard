//
//  Extensions.swift
//  CommonKeyboard
//
//  Created by Kaweerut Kanthawong on 8/9/2019.
//  Copyright © 2019 Kaweerut Kanthawong. All rights reserved.
//

import UIKit

// MARK: - UITextField & UITextView

internal let KeyboardOffsetKeyName: String = "keyboardOffset"
internal let IgnoredCommonKeyboardKeyName: String = "ignoredCommonKeyboard"
private var KeyboardOffsetAssociatedKey: UInt8 = 0
private var IgnoredCommonKeyboardAssociatedKey: UInt8 = 0
private let DefaultKeyboardOffset: CGFloat = 10
private let DefaultIgnoredCommonKeyboard: Bool = false

public extension UITextField {
  @IBInspectable
  var keyboardOffset: CGFloat {
    get {
      return (objc_getAssociatedObject(self, &KeyboardOffsetAssociatedKey) as? CGFloat) ?? DefaultKeyboardOffset
    }
    set(newValue) {
      objc_setAssociatedObject(self, &KeyboardOffsetAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  @IBInspectable
  var ignoredCommonKeyboard: Bool {
    get {
      return (objc_getAssociatedObject(self, &IgnoredCommonKeyboardAssociatedKey) as? Bool) ?? DefaultIgnoredCommonKeyboard
    }
    set(newValue) {
      objc_setAssociatedObject(self, &IgnoredCommonKeyboardAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}

public extension UITextView {
  @IBInspectable
  var keyboardOffset: CGFloat {
    get {
      return (objc_getAssociatedObject(self, &KeyboardOffsetAssociatedKey) as? CGFloat) ?? DefaultKeyboardOffset
    }
    set(newValue) {
      objc_setAssociatedObject(self, &KeyboardOffsetAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  @IBInspectable
  var ignoredCommonKeyboard: Bool {
    get {
      return (objc_getAssociatedObject(self, &IgnoredCommonKeyboardAssociatedKey) as? Bool) ?? false
    }
    set(newValue) {
      objc_setAssociatedObject(self, &IgnoredCommonKeyboardAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}

// MARK: - UIView

public extension UIView {
  static func animate(
    _ keyboardNotificationInfo: CommonKeyboardNotificationInfo,
    delay: TimeInterval = 0,
    animations: @escaping () -> Void,
    completion: ((Bool) -> Void)? = nil
  ) {
    UIView.animate(
      withDuration: keyboardNotificationInfo.animationDuration,
      delay: delay,
      options: [UIView.AnimationOptions(rawValue: keyboardNotificationInfo.animationCurve)],
      animations: animations,
      completion: completion)
  }
}
