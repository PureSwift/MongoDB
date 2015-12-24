//
//  DatabaseTests.swift
//  MongoDB
//
//  Created by Alsey Coleman Miller on 12/24/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import XCTest
import MongoDB
import BinaryJSON
import SwiftFoundation

class DatabaseTests: XCTestCase {

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

    func testName() {
        
        let databaseName = "Test\(Int(Date().timeIntervalSince1970))"
        
        let client = MongoDB.Client(URL: "mongodb://localhost:27017")
        
        let database = MongoDB.Database(databaseName, client: client)
        
        XCTAssert(database.name == databaseName)
    }

}
