//
//  CommonKeyboard.swift
//  CommonKeyboard
//
//  Created by Kaweerut Kanthawong on 8/9/2019.
//  Copyright © 2019 Kaweerut Kanthawong. All rights reserved.
//

import UIKit

public protocol CommonKeyboardContainerProtocol: class {
    var scrollViewContainer: UIScrollView { get }
}

public class CommonKeyboard: NSObject {
    public static let shared = CommonKeyboard()
    
    public var enabled: Bool = false {
        didSet {
            guard (enabled != oldValue) else { return }
            setEnabled(enabled)
        }
    }
    
    internal var utility: CKUtilityProtocol
    internal var keyboardObserver: CommonKeyboardObserverProtocol
    internal var tapGesture: UITapGestureRecognizer?
    internal var prevScrollInsetBottom: CGFloat?
    
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
            guard let weakSelf = self
                , let topVC = weakSelf.utility.topViewController
                , let tapGesture = weakSelf.tapGesture else { return }
            topVC.view.addGestureRecognizer(tapGesture)
        }
        
        // keyboard willHide
        keyboardObserver.subscribe(events: [.willHide]) { [weak self] (info) in
            guard let weakSelf = self else { return }
            
            if let topVC = weakSelf.utility.topViewController
             , let tapGesture = weakSelf.tapGesture {
                topVC.view.removeGestureRecognizer(tapGesture)
            }
            
            let scrollContainer = weakSelf.utility.currentScrollContainer
            guard let bottom = weakSelf.prevScrollInsetBottom else { return }
            weakSelf.prevScrollInsetBottom = nil
            scrollContainer?.contentInset.bottom = bottom
        }
        
        // keyboard willChangeFrame
        keyboardObserver.subscribe(events: [.willChangeFrame]) { [weak self] (info) in
            guard info.isShowing
                , let weakSelf = self
                , let responsederView = weakSelf.currentResponder as? UIView
                , let scrollContainer = weakSelf.utility.currentScrollContainer
                , let window = weakSelf.utility.currentWindow
                , let topViewController = weakSelf.utility.topViewController else {
                    return
            }
            let keyboardOffset = (responsederView.value(forKey: KeyboardOffsetKeyName) as? CGFloat) ?? 0
            weakSelf.handleKeyboard(keyboardInfo: info,
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
        topViewController: UIViewController)
    {
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
            ? getScrollUpContentOffset(scrollContainer: scrollContainer, diff: diff)
            : getScrollDownContentOffset(scrollContainer: scrollContainer, diff: diff)

        UIView.animate(keyboardInfo, animations: {
            scrollContainer.setContentOffset(newContentOffset, animated: false)
        }, completion: { (_) in
            scrollContainer.contentInset = newContentInset
        })
    }
    
    internal func getScrollUpContentOffset(
        scrollContainer: UIScrollView,
        diff: CGFloat
        ) -> CGPoint
    {
        var newContentOffset = scrollContainer.contentOffset
        newContentOffset.y += diff
        return newContentOffset
    }
    
    internal func getScrollDownContentOffset(
        scrollContainer: UIScrollView,
        diff: CGFloat
        ) -> CGPoint
    {
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

fileprivate extension UIView {
    var backwardSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11, *) {
            return safeAreaInsets
        }
        return .zero
    }
}
