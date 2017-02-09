//
//  SwiftFlowTests.swift
//  SwiftFlowTests
//
//  Created by John Holdsworth on 31/03/2015.
//  Copyright (c) 2015 John Holdsworth. All rights reserved.
//

import UIKit
import XCTest
import SwiftFlow

class SwiftFlowTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    var user: String?

    func fetchURL( _ repo: String ) -> String? {
        if let url = URL( string: "https://github.com/\(unwrap(user))/\(repo)" ) {
            do {
                let string = try NSString( contentsOf: url, encoding: String.Encoding.utf8.rawValue )
                return string as String
            } catch let error as NSError {
                _throw( NSException( name: NSExceptionName(rawValue: "fetchURL: Could not fetch"),
                    reason: error.localizedDescription, userInfo: nil ) )
            }
        } else {
            _throw( NSException( name: NSExceptionName(rawValue: "fetchURL"), reason: "Invalid URL", userInfo: nil) )
        }
        return nil
    }
    
    func testExample() {
        // This is an example of a functional test case.

        var gotException = false
        _try {
            _ = self.fetchURL( "SwiftFlow" )
        }
        _catch {
            (exception) in
            gotException = true
        }
        XCTAssert(gotException, "Pass")

        gotException = false
        _try {
            _ = unwrap(self.user)
        }
        _catch {
            (exception) in
            gotException = true
        }
        XCTAssert(gotException, "Pass")

        user = "johnno1962"

        gotException = false
        _try {
            _ = unwrap(self.user)
        }
        _catch {
            (exception) in
            gotException = true
        }
        XCTAssert(!gotException, "Pass")

        gotException = false
        _try {
            _ = self.fetchURL( "Cabbage" )
        }
        _catch {
            (exception) in
            gotException = true
        }
        XCTAssert(gotException, "Pass")

        gotException = false
        _try {
            _ = self.fetchURL( "SwiftFlow" )
        }
        _catch {
            (exception) in
            gotException = true
        }
        XCTAssert(!gotException, "Pass")

        var exceuted = false
        _synchronized( {
            exceuted = true
        } )
        XCTAssert(exceuted, "Pass")

        exceuted = false
        _synchronized( self ) {
            exceuted = true
        }
        XCTAssert(exceuted, "Pass")

        var i = 0; //

        {
            print("Task #1")
            for _ in 0  ..< 10000000  {
            }
            print("\(i)")
            i += 1
        } & {
            print("Task #2")
            for _ in 0  ..< 20000000  {
            }
            print("\(i)")
            i += 1
        } & {
            print("Task #3")
            for _ in 0  ..< 30000000  {
            }
            print("\(i)")
            i += 1
        } | {
            print("Completed \(i)")
        };

        {
            return 99
        } | {
            (result:Int) in
            print("\(result)")
        };

        {
            return 88
        } & {
            return 99
        } | {
            (results:[Int?]) in
            print("\(results)")
        };
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
