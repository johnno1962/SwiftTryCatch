//
//  SwiftTryCatchTests.swift
//  SwiftTryCatchTests
//
//  Created by John Holdsworth on 31/03/2015.
//  Copyright (c) 2015 John Holdsworth. All rights reserved.
//

import UIKit
import XCTest
import SwiftTryCatch

class SwiftTryCatchTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    var user: String?

    func fetchURL( repo: String ) -> String? {
        if let url = NSURL( string: "https://github.com/\(U(user))/\(repo)" ) {
            var error: NSError?
            if let string = NSString( contentsOfURL: url, encoding: NSUTF8StringEncoding, error: &error ) {
                return string
            } else {
                _throw( NSException( name: "fetchURL: Could not fetch",
                    reason: U(error).localizedDescription, userInfo: nil ) )
            }
        } else {
            _throw( NSException( name: "fetchURL", reason: "Invalid URL", userInfo: nil) )
        }
        return nil
    }
    
    func testExample() {
        // This is an example of a functional test case.

        var gotException = false
        _try {
            let result = self.fetchURL( "SwiftTryCatch" )
        }
        _catch {
            (exception) in
            gotException = true
        }
        XCTAssert(gotException, "Pass")

        user = "johnno1962"
        gotException = false
        _try {
            let result = self.fetchURL( "Cabbage" )
        }
        _catch {
            (exception) in
            gotException = true
        }
        XCTAssert(gotException, "Pass")

        gotException = false
        _try {
            let result = self.fetchURL( "SwiftTryCatch" )
        }
        _catch {
            (exception) in
            gotException = true
        }
        XCTAssert(!gotException, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
