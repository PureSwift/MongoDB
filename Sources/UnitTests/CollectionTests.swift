//
//  CollectionTests.swift
//  MongoDB
//
//  Created by Alsey Coleman Miller on 12/24/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import XCTest
import MongoDB
import BinaryJSON
import SwiftFoundation

class CollectionTests: XCTestCase {

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
        
        let collectionName = "TestNameCollection"
        
        let databaseName = "Test\(Int(Date().timeIntervalSince1970))"
        
        let client = MongoDB.Client(URL: "mongodb://localhost:27017")
        
        let collection = MongoDB.Collection(collectionName, database: databaseName, client: client)
        
        XCTAssert(collection.name == collection.name)
    }
    
    func testInsert() {
        
        let collectionName = "TestInsertCollection"
        
        let databaseName = "Test\(Int(Date().timeIntervalSince1970))"
        
        let client = MongoDB.Client(URL: "mongodb://localhost:27017")
        
        let collection = MongoDB.Collection(collectionName, database: databaseName, client: client)
        
        var document = BSON.Document()
        
        document["_id"] = .ObjectID(BSON.ObjectID())
        
        document["hello"] = .String("world")
        
        do { try collection.insert(document) }
        
        catch { XCTFail("\(error)"); return }
    }
    
    func testFind() {
        
        // insert document
        
        let databaseName = "Test\(Int(Date().timeIntervalSince1970))"
        
        let client = MongoDB.Client(URL: "mongodb://localhost:27017")
        
        let collection = MongoDB.Collection("TestFindCollection", database: databaseName, client: client)
        
        var document = BSON.Document()
        
        document["_id"] = .ObjectID(BSON.ObjectID())
        
        document["hello"] = .String("world")
        
        do { try collection.insert(document) }
            
        catch { XCTFail("\(error)"); return }
        
        // find that document
        
        guard let cursor = collection.find(document)
            else { XCTFail("Could not create cursor"); return }
        
        let resultArray = Array<BSON.Document>(GeneratorSequence(cursor.generator))
        
        guard let firstResult = resultArray.first
            else { XCTFail("Empty results cursor"); return }
        
        XCTAssert(firstResult == document)
        XCTAssert(resultArray.count == 1)
        
        print("Cursor result:\n\(resultArray)")
    }
    
    func testUpdate() {
        
        // insert document
        
        let databaseName = "Test\(Int(Date().timeIntervalSince1970))"
        
        let client = MongoDB.Client(URL: "mongodb://localhost:27017")
        
        let collection = MongoDB.Collection("TestUpdateCollection", database: databaseName, client: client)
        
        var document = BSON.Document()
        
        let objectID = BSON.ObjectID()
        
        document["_id"] = .ObjectID(objectID)
        
        document["key"] = .String("originalValue")
        
        do { try collection.insert(document) }
            
        catch { XCTFail("\(error)"); return }
        
        // update that document
        
        let newValueDocument: BSON.Document = ["key": .String("newValue")]
        
        do { try collection.update(["_id": .ObjectID(objectID)], update: ["$set": .Document(newValueDocument)]) }
        
        catch { XCTFail("\(error)"); return }
        
        // find updated document
        
        guard let cursor = collection.find(newValueDocument)
            else { XCTFail("Could not create cursor"); return }
        
        let resultArray = Array<BSON.Document>(GeneratorSequence(cursor.generator))
        
        guard let firstResult = resultArray.first
            else { XCTFail("Empty results cursor"); return }
        
        // verify final document value
        XCTAssert(firstResult == ["_id": .ObjectID(objectID), "key": .String("newValue")])
        XCTAssert(resultArray.count == 1)
        
        print("Cursor result:\n\(resultArray)")
    }
    
    func testDelete() {
        
        // insert document
        
        let databaseName = "Test\(Int(Date().timeIntervalSince1970))"
        
        let client = MongoDB.Client(URL: "mongodb://localhost:27017")
        
        let collection = MongoDB.Collection("TestDeleteCollection", database: databaseName, client: client)
        
        var document = BSON.Document()
        
        let objectID = BSON.ObjectID()
        
        document["_id"] = .ObjectID(objectID)
        
        document["key"] = .String("value")
        
        do {
            try collection.insert(document)
            
            try collection.delete(document)
        }
            
        catch { XCTFail("\(error)"); return }
    }
    
    func testCount() {
        
        let databaseName = "Test\(Int(Date().timeIntervalSince1970))"
        
        let client = MongoDB.Client(URL: "mongodb://localhost:27017")
        
        let collection = MongoDB.Collection("TestCountCollection", database: databaseName, client: client)
        
        // insert documents
        
        let key = "key"
        
        let value = BSON.Value.String("value")
        
        let insertCount: Int64 = 10
        
        for _ in 0 ..< insertCount {
            
            var document = BSON.Document()
            
            let objectID = BSON.ObjectID()
            
            document["_id"] = .ObjectID(objectID)
            
            document[key] = value
            
            do { try collection.insert(document) }
            
            catch { XCTFail("\(error)"); return }
        }
        
        // get count
        
        let fetchedCount: Int64
        
        do { fetchedCount = try collection.count([key: value]) }
        
        catch { XCTFail("\(error)"); return }
        
        XCTAssert(fetchedCount == insertCount)
    }
}

