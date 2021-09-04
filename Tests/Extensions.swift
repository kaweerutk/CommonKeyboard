//
//  Extensions.swift
//  Tests
//
//  Created by Kaweerut Kanthawong on 8/9/2019.
//  Copyright © 2019 Kaweerut Kanthawong. All rights reserved.
//

import UIKit
@testable import CommonKeyboard

extension UIScrollView {
  static func instance(
    frame: CGRect = Screen.bounds,
    contentInset: UIEdgeInsets = .zero,
    contentSize: CGSize = Screen.size,
    contentOffset: CGPoint = .zero) -> UIScrollView
  {
    
    let scrollView = UIScrollView(frame: frame)
    scrollView.contentInset = contentInset
    scrollView.contentSize = contentSize
    scrollView.setContentOffset(contentOffset, animated: false)
    return scrollView
  }
}


class Screen {
  static var bounds: CGRect {
    return UIScreen.main.bounds
  }
  
  static var size: CGSize {
    return UIScreen.main.bounds.size
  }
  
  static var width: CGFloat {
    return UIScreen.main.bounds.size.width
  }
  
  static var height: CGFloat {
    return UIScreen.main.bounds.size.height
  }
}
