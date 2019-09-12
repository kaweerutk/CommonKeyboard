//
//  CommonKeyboardObserver.swift
//  CommonKeyboard
//
//  Created by Kaweerut Kanthawong on 8/9/2019.
//  Copyright © 2019 Kaweerut Kanthawong. All rights reserved.
//

import UIKit

public enum CommonKeyboardObserverEvent {
    case willShow
    case didShow
    case willHide
    case didHide
    case willChangeFrame
    case didChangeFrame
    case dragDown
    
    var notification: NSNotification.Name {
        switch self {
        case .willShow:
            return UIResponder.keyboardWillShowNotification
        case .didShow:
            return UIResponder.keyboardDidShowNotification
        case .willHide:
            return UIResponder.keyboardWillHideNotification
        case .didHide:
            return UIResponder.keyboardDidHideNotification
        case .willChangeFrame:
            return UIResponder.keyboardWillChangeFrameNotification
        case .didChangeFrame:
            return UIResponder.keyboardDidChangeFrameNotification
        default:
            return NSNotification.Name(rawValue: "CommonKeyboardObserverEvent.dragDown")
        }
    }
}

public struct CommonKeyboardObserverItem: Hashable {
    public let events: [CommonKeyboardObserverEvent]
    public let notificationObservers: [NSObjectProtocol]
    public let handler: (CommonKeyboardNotificationInfo)->Void
    
    public static func == (lhs: CommonKeyboardObserverItem, rhs: CommonKeyboardObserverItem) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(notificationObservers.description)
    }
}

public struct CommonKeyboardNotificationInfo {
    public let keyboardFrameBegin: CGRect
    public let keyboardFrameEnd: CGRect
    public let visibleHeight: CGFloat
    public let animationDuration: Double
    public let animationCurve: UInt
    public let isLocal: Bool?
    public let isShowing: Bool
    
    internal init(keyboardFrameBegin: CGRect,
                  keyboardFrameEnd: CGRect,
                  visibleHeight: CGFloat,
                  animationDuration: Double,
                  animationCurve: UInt,
                  isLocal: Bool?) {
        self.keyboardFrameBegin = keyboardFrameBegin
        self.keyboardFrameEnd = keyboardFrameEnd
        self.visibleHeight = visibleHeight
        self.animationDuration = animationDuration
        self.animationCurve = animationCurve
        self.isLocal = isLocal
        isShowing = keyboardFrameEnd.origin.y < UIScreen.main.bounds.height
    }
    
    init?(notification: Notification) {
        guard let userInfo = notification.userInfo else { return nil }
        keyboardFrameBegin = ((userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) ?? .zero
        keyboardFrameEnd = ((userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) ?? .zero
        visibleHeight = UIScreen.main.bounds.height - keyboardFrameEnd.origin.y
        animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0
        animationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt) ?? 0
        if #available(iOS 9, *) {
            isLocal = (userInfo[UIResponder.keyboardIsLocalUserInfoKey] as? Bool)
        } else {
            isLocal = nil
        }
        isShowing = keyboardFrameEnd.origin.y < UIScreen.main.bounds.height
    }
}

public protocol CommonKeyboardObserverProtocol {
    func subscribe(events: [CommonKeyboardObserverEvent], _ handler: @escaping (CommonKeyboardNotificationInfo)->Void)
    func remove(_ observerItem: CommonKeyboardObserverItem)
    func removeAll()
}

////////////////////////////////
// MARK: - CommonKeyboardObserver
////////////////////////////////

public class CommonKeyboardObserver: CommonKeyboardObserverProtocol {
    
    internal var observers: Set<CommonKeyboardObserverItem>
    internal var operationQueue: OperationQueue
    
    public init() {
        observers = Set<CommonKeyboardObserverItem>()
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInteractive
        operationQueue.name = "CommonKeyboardObserver"
        DispatchQueue.main.async {
            _ = PanGestureWorker.shared
        }
    }
    
    deinit {
        removeAll()
    }
    
    public func subscribe(
        events: [CommonKeyboardObserverEvent],
        _ handler: @escaping (CommonKeyboardNotificationInfo)->Void
        )
    {
        operationQueue.addOperation { [weak self] in
            var notificationObservers: [NSObjectProtocol] = []
            events.forEach { (event) in
                let observer = NotificationCenter.default.addObserver(
                    forName: event.notification,
                    object: nil,
                    queue: .main,
                    using: { (notification) in
                        guard let info = CommonKeyboardNotificationInfo(notification: notification) else { return }
                        handler(info)
                })
                notificationObservers.append(observer)
            }
            
            let item = CommonKeyboardObserverItem(events: events,
                                                  notificationObservers: notificationObservers,
                                                  handler: handler)
            self?.observers.insert(item)
        }
    }
    
    public func remove(_ observerItem: CommonKeyboardObserverItem) {
        operationQueue.addOperation { [weak self] in
            self?._remove(observerItem)
        }
    }
    
    public func removeAll() {
        operationQueue.addOperation { [weak self] in
            self?.observers.forEach { self?._remove($0) }
        }
    }
    
    private func _remove(_ observerItem: CommonKeyboardObserverItem) {
        observerItem.notificationObservers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
        observers.remove(observerItem)
    }
    
}

////////////////////////////////
// MARK: - PanGestureWorker
////////////////////////////////

internal class PanGestureWorker: NSObject, UIGestureRecognizerDelegate {
    
    internal static let shared = PanGestureWorker()
    
    internal var utility: CKUtilityProtocol
    internal var keyboardObserver: CommonKeyboardObserverProtocol
    internal var panRecognizer: UIPanGestureRecognizer?
    
    private var lastKeyboardInfo: CommonKeyboardNotificationInfo?
    
    private override init() {
        utility = CKUtility()
        keyboardObserver = CommonKeyboardObserver()
        super.init()
        setup()
    }
    
    // for testing
    internal init(utility: CKUtilityProtocol, keyboardObserver: CommonKeyboardObserverProtocol) {
        self.utility = utility
        self.keyboardObserver = keyboardObserver
        super.init()
        setup()
    }
    
    private func setup() {
        keyboardObserver.subscribe(events: [.willShow, .willHide, .willChangeFrame]) { [weak self] (info) in
            guard let weakSelf = self else { return }
            weakSelf.lastKeyboardInfo = info
            if info.isShowing {
                weakSelf.addGesture()
            } else {
                weakSelf.removeGesture()
            }
        }
    }
    
    private func addGesture() {
        guard panRecognizer == nil else { return }
        let pan = UIPanGestureRecognizer(target: self, action: #selector(PanGestureWorker.drag(_:)))
        pan.delegate = self
        utility.currentWindow?.addGestureRecognizer(pan)
        panRecognizer = pan
    }
    
    private func removeGesture() {
        guard let pan = panRecognizer else { return }
        utility.currentWindow?.removeGestureRecognizer(pan)
        panRecognizer = nil
    }
    
    @objc public func drag(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard let window = utility.currentWindow
            , let lastKeyboardInfo = lastKeyboardInfo else {
                return
        }
        let point = panGestureRecognizer.location(in: window)
        let lastKeyboardFrame = lastKeyboardInfo.keyboardFrameEnd
        var newKeyboardFrame = lastKeyboardFrame
        newKeyboardFrame.origin.y = max(point.y, lastKeyboardFrame.origin.y)
        
        var keyboardInfo: [String : Any] = [
            UIResponder.keyboardFrameBeginUserInfoKey: newKeyboardFrame,
            UIResponder.keyboardFrameEndUserInfoKey: newKeyboardFrame,
            UIResponder.keyboardAnimationDurationUserInfoKey: 0.001,
            UIResponder.keyboardAnimationCurveUserInfoKey: 0,
            ]
        if #available(iOS 9, *) {
            keyboardInfo[UIResponder.keyboardIsLocalUserInfoKey] = lastKeyboardInfo.isLocal
        }
        
        NotificationCenter.default.post(name: CommonKeyboardObserverEvent.dragDown.notification,
                                        object: nil,
                                        userInfo: keyboardInfo)
    }
    
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
        ) -> Bool
    {
        var scrollContainer: UIScrollView? = utility.currentScrollContainer
        if scrollContainer == nil
            , let topVC = utility.topViewController {
            // Just traverse only 1 layer for the good performance
            // it better to implement `CommonKeyboardContainerProtocol`
            // to return specific scrollViewContainer you want to handle
            scrollContainer = topVC.view.subviews.first { $0 is UIScrollView } as? UIScrollView
        }
        
        if gestureRecognizer == panRecognizer
            , let scrollContainer = scrollContainer
            , scrollContainer.keyboardDismissMode == .interactive
        {
            let point = touch.location(in: gestureRecognizer.view)
            var view = gestureRecognizer.view?.hitTest(point, with: nil)
            while (view != nil) {
                if view === scrollContainer {
                    return true
                }
                view = view?.superview
            }
        }
        return false
    }
    
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool
    {
        return gestureRecognizer === self.panRecognizer
    }
}
