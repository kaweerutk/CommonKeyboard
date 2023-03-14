//
//  CommonKeyboard.swift
//  CommonKeyboard
//
//  Created by Kaweerut Kanthawong on 8/9/2019.
//  Copyright © 2019 Kaweerut Kanthawong. All rights reserved.
//

import UIKit

public protocol CommonKeyboardContainerProtocol: AnyObject {
  var scrollViewContainer: UIScrollView { get }
}

public class CommonKeyboard: NSObject {
  private enum Consts {
    static let defaultAnimationDuration: TimeInterval = 0.2
  }
    
  public static let shared = CommonKeyboard()
  
  public var debug: Bool = false
  
  public var enabled: Bool = false {
    didSet {
      guard (enabled != oldValue) else { return }
      setEnabled(enabled)
    }
  }
  
  private let utility: CKUtilityProtocol
  private let keyboardObserver: CommonKeyboardObserverProtocol
  private var tapGesture: UITapGestureRecognizer?
  private var prevScrollInsetBottom: CGFloat?
  
  private override init() {
    self.utility = CKUtility()
    self.keyboardObserver = CommonKeyboardObserver()
    super.init()
  }
  
  // for testing
  internal init(utility: CKUtilityProtocol, keyboardObserver: CommonKeyboardObserverProtocol) {
    self.utility = utility
    self.keyboardObserver = keyboardObserver
    super.init()
  }
  
  public var currentResponder: UIResponder? {
    return utility.currentResponder
  }
  
  @objc public func dismiss() {
    UIApplication.shared.sendAction(#selector(UIView.resignFirstResponder), to: nil, from: nil, for: nil)
  }
  
  // MARK: - internal & private
  
  internal func setEnabled(_ enabled: Bool) {
    guard enabled else {
      keyboardObserver.removeAll()
      tapGesture = nil
      return
    }
    tapGesture = UITapGestureRecognizer(target: self, action: #selector(CommonKeyboard.dismiss))
    tapGesture?.cancelsTouchesInView = false
    tapGesture?.delegate = self
    subscribeKeyboard()
  }
  
  private func subscribeKeyboard() {
    // keyboard didShow
    keyboardObserver.subscribe(events: [.didShow]) { [weak self] (_) in
      guard let self = self
            , let topVC = self.utility.topViewController
            , let tapGesture = self.tapGesture else { return }
      topVC.view.addGestureRecognizer(tapGesture)
    }
    
    // keyboard willHide
    keyboardObserver.subscribe(events: [.willHide]) { [weak self] (info) in
      guard let self = self else { return }
      if
        let topVC = self.utility.topViewController,
        let tapGesture = self.tapGesture
      {
        topVC.view.removeGestureRecognizer(tapGesture)
      }
      let scrollContainer = self.utility.currentScrollContainer
      guard let bottom = self.prevScrollInsetBottom else { return }
      self.prevScrollInsetBottom = nil
      scrollContainer?.contentInset.bottom = bottom
    }
    
    // keyboard willChangeFrame
    keyboardObserver.subscribe(events: [.willChangeFrame]) { [weak self] (info) in
      guard let self = self else { return }
      if self.debug {
        self.printDebugDescription(info: info)
      }
      
      guard
        info.isShowing,
        let responsederView = self.currentResponder as? UIView,
        let scrollContainer = self.utility.currentScrollContainer,
        let window = self.utility.currentWindow,
        let topViewController = self.utility.topViewController
      else { return }
      
      let keyboardOffset = (responsederView.value(forKey: KeyboardOffsetKeyName) as? CGFloat) ?? 0
      self.handleKeyboard(keyboardInfo: info,
                          keyboardOffset: keyboardOffset,
                          responsederView: responsederView,
                          scrollContainer: scrollContainer,
                          window: window,
                          topViewController: topViewController)
    }
  }
  
  internal func handleKeyboard(
    keyboardInfo: CommonKeyboardNotificationInfo,
    keyboardOffset: CGFloat,
    responsederView: UIView,
    scrollContainer: UIScrollView,
    window: UIWindow,
    topViewController: UIViewController
  ) {
    if prevScrollInsetBottom == nil {
      prevScrollInsetBottom = scrollContainer.contentInset.bottom
    }
    
    let keyboardFrame = keyboardInfo.keyboardFrameEnd
    let targetFrame = window.convert(responsederView.frame, from: responsederView.superview)
    let targetBottomY = (targetFrame.origin.y + targetFrame.size.height + keyboardOffset)
    let diff = targetBottomY - keyboardFrame.origin.y
    
    var newContentInset = scrollContainer.contentInset
    newContentInset.bottom = (keyboardInfo.visibleHeight - topViewController.view.backwardSafeAreaInsets.bottom)
    
    let newContentOffset: CGPoint = diff > 0
      ? getScrollDownContentOffset(scrollContainer: scrollContainer, diff: diff)
      : getScrollUpContentOffset(scrollContainer: scrollContainer, diff: diff)
    
    scrollContainer.contentInset = newContentInset
      
    let animationDuration = keyboardInfo.animationDuration > 0
      ? keyboardInfo.animationDuration
      : Consts.defaultAnimationDuration
      
    UIView.animate(
      withDuration: animationDuration,
      delay: 0,
      options: [UIView.AnimationOptions(rawValue: keyboardInfo.animationCurve)],
      animations: {
        scrollContainer.setContentOffset(newContentOffset, animated: false)
      }
    )
  }
  
  internal func getScrollDownContentOffset(
    scrollContainer: UIScrollView,
    diff: CGFloat
  ) -> CGPoint {
    var newContentOffset = scrollContainer.contentOffset
    newContentOffset.y += diff
    return newContentOffset
  }
  
  internal func getScrollUpContentOffset(
    scrollContainer: UIScrollView,
    diff: CGFloat
  ) -> CGPoint {
    var newContentOffset = scrollContainer.contentOffset
    let contentInsetTop: CGFloat = scrollContainer.contentInset.top + scrollContainer.backwardSafeAreaInsets.top
    let scrollableDownOffset = scrollContainer.contentOffset.y + contentInsetTop
    
    if scrollableDownOffset >= abs(diff) {
      newContentOffset.y += diff
    } else {
      newContentOffset.y = -contentInsetTop
    }
    return newContentOffset
  }
}

extension CommonKeyboard: UIGestureRecognizerDelegate {
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return !(touch.view is UIControl)
  }
}

extension CommonKeyboard {
  private func printDebugDescription(info: CommonKeyboardNotificationInfo) {
    print("----- CommonKeyboard debug enabled -----")
    print("- isShowing: ", info.isShowing)
    print("- keyboardFrameBegin: ", info.keyboardFrameBegin)
    print("- keyboardFrameEnd: ", info.keyboardFrameEnd)
    print("- visibleHeight: ", info.visibleHeight)
    print("- isLocal: ", info.isLocal ?? false)
    if let scrollContainer = utility.currentScrollContainer {
      print("- scrollContainer: ", scrollContainer.description)
    } else {
      let noContainerMessage = """
        \n \
        ***** \n \
          COULD NOT FIND `scrollContainer` \n \
          YOU BETTER TO IMPLEMENT `CommonKeyboardContainerProtocol` \n \
          IN `topViewController` (\(utility.topViewController?.description ?? "nil") \n \
          TO RETURN SPECIFIC `scrollContainer` \n \
        *****
      """
      print("- scrollContainer: ", noContainerMessage)
    }
    print("------")
  }
}

fileprivate extension UIView {
  var backwardSafeAreaInsets: UIEdgeInsets {
    if #available(iOS 11, *) {
      return safeAreaInsets
    }
    return .zero
  }
}
