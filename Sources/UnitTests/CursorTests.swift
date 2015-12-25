//
//  CursorTests.swift
//  MongoDB
//
//  Created by Alsey Coleman Miller on 12/25/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import XCTest
import MongoDB
import BinaryJSON
import SwiftFoundation

class CursorTests: XCTestCase {

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

    func testProperties() {
        
        // insert document
        
        let databaseName = "Test\(Int(Date().timeIntervalSince1970))"
        
        let client = MongoDB.Client(URL: "mongodb://localhost:27017")
        
        let collection = MongoDB.Collection("\(__FUNCTION__)", database: databaseName, client: client)
        
        var document = BSON.Document()
        
        document["_id"] = .ObjectID(BSON.ObjectID())
        
        document["hello"] = .String("world")
        
        do { try collection.insert(document) }
            
        catch { XCTFail("\(error)"); return }
        
        // create cursor
        
        guard let cursor = collection.find(document)
            else { XCTFail("Could not create cursor"); return }
        
        print("Cursor before query:\n\(cursor)\n")
        
        // not host info
        XCTAssert(cursor.host.isEmpty)
        
        XCTAssert(cursor.isAlive)
        
        XCTAssert(cursor.more)
        
        // send query (to get host info)
        let _ = Array<BSON.Document>(GeneratorSequence(cursor.generator))
        
        print("Cursor after query:\n\(cursor)\n")
        
        // should have host info
        XCTAssert(cursor.host.isEmpty == false)
        
        XCTAssert(cursor.isAlive == false)
        
        XCTAssert(cursor.more == false)
        
        XCTAssert(cursor.host.first!.hostPort == "localhost:27017")
        
        XCTAssert(cursor.host.first!.host == "localhost")
        
        XCTAssert(cursor.host.first!.port == 27017)
        
        XCTAssert(cursor.host.count == 1)
    }
    
    func testCopying() {
        
        // insert document
        
        let databaseName = "Test\(Int(Date().timeIntervalSince1970))"
        
        let client = MongoDB.Client(URL: "mongodb://localhost:27017")
        
        let collection = MongoDB.Collection("\(__FUNCTION__)", database: databaseName, client: client)
        
        var document = BSON.Document()
        
        document["_id"] = .ObjectID(BSON.ObjectID())
        
        document["hello"] = .String("world")
        
        do { try collection.insert(document) }
            
        catch { XCTFail("\(error)"); return }
        
        // create cursor
        
        guard let cursor = collection.find(document)
            else { XCTFail("Could not create cursor"); return }
        
        let resultArray = Array<BSON.Document>(GeneratorSequence(cursor.generator))
        
        // create copy
        
        let copy = cursor.copy
        
        let copyResultArray = Array<BSON.Document>(GeneratorSequence(copy.generator))
        
        /// cursor result arrays should match
        XCTAssert(resultArray.first! == copyResultArray.first!)
        XCTAssert(resultArray.count == 1)
        XCTAssert(copyResultArray.count == 1)
    }

}
