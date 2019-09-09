//
//  Extensions.swift
//  KeyboardExample
//
//  Created by Kaweerut Kanthawong on 8/9/2019.
//  Copyright © 2019 Kaweerut Kanthawong. All rights reserved.
//

import UIKit

extension UIView {
    var backwardSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11, *) {
            return safeAreaInsets
        }
        return .zero
    }
}
