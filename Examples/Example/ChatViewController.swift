//
//  ChatViewController.swift
//  KeyboardExample
//
//  Created by Kaweerut Kanthawong on 8/9/2019.
//  Copyright © 2019 Kaweerut Kanthawong. All rights reserved.
//

import UIKit
import CommonKeyboard

class ChatViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    lazy var keyboardObserver = CommonKeyboardObserver()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // drag down to dismiss keyboard
        tableView.keyboardDismissMode = .interactive
        
        keyboardObserver.subscribe(events: [.willChangeFrame, .dragDown]) { [weak self] (info) in
            guard let weakSelf = self else { return }
            let bottom = (info.isShowing
                ? (-info.visibleHeight) + weakSelf.view.backwardSafeAreaInsets.bottom
                : 0
            )
            UIView.animate(info, animations: { [weak self] in
                self?.bottomConstraint.constant = bottom
                self?.view.layoutIfNeeded()
            })
        }
    }
    
}

extension ChatViewController: CommonKeyboardContainerProtocol {
    // return specific scrollViewContainer
    // UIScrollView or a class that inherited from (e.g., UITableView or UICollectionView)
    var scrollViewContainer: UIScrollView {
        return tableView
    }
}
