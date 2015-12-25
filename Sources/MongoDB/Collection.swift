//
//  Collection.swift
//  MongoDB
//
//  Created by Alsey Coleman Miller on 12/24/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import SwiftFoundation
import BinaryJSON
import CMongoC
import CBSON

public extension MongoDB {
    
    /// MongoDB collection. Similar to a table in a relational database.
    public final class Collection {
        
        // MARK: - Properties
        
        public let client: Client
        
        // MARK: - Internal Properties
        
        internal let internalPointer: COpaquePointer
        
        // MARK: - Initialization
        
        deinit { mongoc_collection_destroy(internalPointer) }
        
        public init(_ collectionName: String, database: String, client: Client) {
            
            self.client = client
            
            self.internalPointer = mongoc_client_get_collection(client.internalPointer, database, collectionName)
        }
        
        // MARK: - Computed Properties
        
        public lazy var name: String = {
            
            return String.fromCString(mongoc_collection_get_name(self.internalPointer))!
        }()
        
        // MARK: - Methods
        
        public func insert(document: BSON.Document, flags: mongoc_insert_flags_t = MONGOC_INSERT_NONE) throws {
            
            guard let documentPointer = BSON.unsafePointerFromDocument(document)
                else { fatalError("Could not convert BSON document to bson_t") }
            
            defer { bson_destroy(documentPointer) }
            
            var errorBSON = bson_error_t()
            
            guard mongoc_collection_insert(internalPointer, flags, documentPointer, nil, &errorBSON)
                else { throw BSON.Error(unsafePointer: &errorBSON) }
        }
    }
}