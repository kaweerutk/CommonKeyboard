//
//  CommonKeyboardTests.swift
//  CommonKeyboardTests
//
//  Created by Kaweerut Kanthawong on 8/9/2019.
//  Copyright © 2019 Kaweerut Kanthawong. All rights reserved.
//

import XCTest
@testable import CommonKeyboard

class CommonKeyboardTests: XCTestCase {
    
    let subject = CommonKeyboard.shared
    
    // MARK: testGetScrollUpContentOffset
    
    func testGetScrollUpContentOffset_GivenContentSizeMoreThanFrame_WhenDiffIs50() {
        let diff: CGFloat = 50
        var size = Screen.size
        size.height *= 2
        let scrollView = UIScrollView.instance(contentSize: size)
        
        let newContentOffset = subject.getScrollUpContentOffset(scrollContainer: scrollView, diff: diff)
        XCTAssert(newContentOffset.y == diff)
    }
    
    func testGetScrollUpContentOffset_GivenContentSizeLessThanFrame_WhenDiffIs55() {
        let diff: CGFloat = 55
        var size = Screen.size
        size.height /= 2
        let scrollView = UIScrollView.instance(contentSize: size)
        
        let newContentOffset = subject.getScrollUpContentOffset(scrollContainer: scrollView, diff: diff)
        XCTAssert(newContentOffset.y == diff)
    }
    
    func testGetScrollUpContentOffset_GivenContentSizeEqualFrame_WhenDiffIs90() {
        let diff: CGFloat = 90
        let size = Screen.size
        let scrollView = UIScrollView.instance(contentSize: size)
        
        let newContentOffset = subject.getScrollUpContentOffset(scrollContainer: scrollView, diff: diff)
        XCTAssert(newContentOffset.y == diff)
    }
    
    // MARK: testGetScrollDownContentOffset
    
    func testGetScrollDownContentOffset_GiveContentSizeMoreThanFrame_WhenDiffIsMinus40() {
        let diff: CGFloat = -40
        let initContentOffset = CGPoint(x: 0, y: Screen.size.height)
        var size = Screen.size
        size.height *= 2
        let scrollView = UIScrollView.instance(
            contentSize: size,
            contentOffset: initContentOffset
        )
        
        let newContentOffset = subject.getScrollDownContentOffset(scrollContainer: scrollView, diff: diff)
        let expectedContentOffsetY: CGFloat = initContentOffset.y + diff
        XCTAssert(newContentOffset.y == expectedContentOffsetY)
    }
    
    func testGetScrollDownContentOffset_GiveContentSizeLessThanFrame_WhenDiffIsMinus40() {
        let diff: CGFloat = -40
        let initContentOffset = CGPoint(x: 0, y: 20)
        var size = Screen.size
        size.height += 20
        let scrollView = UIScrollView.instance(
            contentSize: size,
            contentOffset: initContentOffset
        )
        
        let newContentOffset = subject.getScrollDownContentOffset(scrollContainer: scrollView, diff: diff)
        XCTAssert(newContentOffset.y == 0)
    }
    
    func testGetScrollDownContentOffset_GiveContentSizeMoreThanFrame_WhenContentInsetTop30AndContentOffsetY20() {
        let diff: CGFloat = -50
        let initContentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        let initContentOffset = CGPoint(x: 0, y: 20)
        var size = Screen.size
        size.height += 20
        let scrollView = UIScrollView.instance(
            contentInset: initContentInset,
            contentSize: size,
            contentOffset: initContentOffset
        )
        
        let newContentOffset = subject.getScrollDownContentOffset(scrollContainer: scrollView, diff: diff)
        XCTAssert(newContentOffset.y == -30)
    }
}
