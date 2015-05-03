//
//  ShyHiTests.swift
//  ShyHiTests
//
//  Created by Jonathan Amato on 4/29/15.
//  Copyright (c) 2015 ShyHi. All rights reserved.
//

import UIKit
import XCTest
//import ShyHi

class ShyHiTests: XCTestCase {
    
   // var vc:NewChatViewController = NewChatViewController()
    
    override func setUp() {
        super.setUp()
        /*
        var storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        vc = storyboard.instantiateViewControllerWithIdentifier("MyStoryboard") as! NewChatViewController
        vc.loadView()
        vc.viewDidLoad()
        */
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /*
    func testNewChatButtonTextDidLoad() {
        //assert our new chat button has loaded
        XCTAssertTrue(vc.NewChatButton.text == "New Chat", "New Chat Button is not set, it is currently \(vc.NewChatButton.text)")
    }
    */
    
    func testPerformanceExample() {
        self.measureBlock() {
        }
    }
    
}
