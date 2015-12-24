//
//  ClientTests.swift
//  MongoDB
//
//  Created by Alsey Coleman Miller on 12/24/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import XCTest
import MongoDB
import BinaryJSON
import SwiftFoundation

class ClientTests: XCTestCase {
    
    #if os(OSX)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        setupMongo
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    #endif

    func testPing() {
        
        let client = MongoDB.Client(URL: "mongodb://localhost:27017")
        
        let command: BSON.Document = ["ping": .Number(.Integer32(1))]
        
        let response: BSON.Document
        
        do { response = try client.command(command, databaseName: "test") }
        catch { XCTFail("\(error)"); return }
        
        print("Response: \n\(response)")
        
        // response should always be ["ok": 1.0]
        XCTAssert(response.toJSON() == .Object(["ok": .Number(.Double(1.0))]))
    }

}
