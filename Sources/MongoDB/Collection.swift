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
        
        /// Inserts a document into the collection.
        public func insert(document: BSON.Document, flags: mongoc_insert_flags_t = MONGOC_INSERT_NONE) throws {
            
            guard let documentPointer = BSON.unsafePointerFromDocument(document)
                else { fatalError("Could not convert BSON document to bson_t") }
            
            defer { bson_destroy(documentPointer) }
            
            var errorBSON = bson_error_t()
            
            guard mongoc_collection_insert(internalPointer, flags, documentPointer, nil, &errorBSON)
                else { throw BSON.Error(unsafePointer: &errorBSON) }
        }
        
        /// Queries the collection.
        ///
        /// Loads all documents by default. 
        public func find(query: BSON.Document = [:], flags: mongoc_query_flags_t = MONGOC_QUERY_NONE, skip: Int = 0, limit: Int = 0, batchSize: Int = 0) -> Cursor? {
            
            guard let documentPointer = BSON.unsafePointerFromDocument(query)
                else { fatalError("Could not convert BSON document to bson_t") }
            
            defer { bson_destroy(documentPointer) }
            
            // TODO: Implement fetching fields
            
            let cursorPointer = mongoc_collection_find(internalPointer, flags, UInt32(skip), UInt32(limit), UInt32(batchSize), documentPointer, nil, nil)
            
            guard cursorPointer != nil else { return nil }
            
            return Cursor(internalPointer: cursorPointer)
        }
        
        /// Update a document in the collection.
        public func update(query: BSON.Document, update: BSON.Document, flags: mongoc_update_flags_t = MONGOC_UPDATE_NONE, writeConcern: WriteConcern? = nil) throws {
            
            guard let updateDocumentPointer = BSON.unsafePointerFromDocument(update)
                else { fatalError("Could not convert BSON document to bson_t") }
            
            defer { bson_destroy(updateDocumentPointer) }
            
            guard let queryDocumentPointer = BSON.unsafePointerFromDocument(query)
                else { fatalError("Could not convert BSON document to bson_t") }
            
            defer { bson_destroy(queryDocumentPointer) }
            
            var errorBSON = bson_error_t()
            
            guard mongoc_collection_update(internalPointer, flags, queryDocumentPointer, updateDocumentPointer, writeConcern?.storage.internalPointer ?? nil, &errorBSON)
                else { throw BSON.Error(unsafePointer: &errorBSON) }
        }
        
        /// Deletes a document in the collection. 
        public func delete(query: BSON.Document, flags: mongoc_remove_flags_t = MONGOC_REMOVE_NONE, writeConcern: WriteConcern? = nil) throws {
            
            guard let queryDocumentPointer = BSON.unsafePointerFromDocument(query)
                else { fatalError("Could not convert BSON document to bson_t") }
            
            defer { bson_destroy(queryDocumentPointer) }
            
            var errorBSON = bson_error_t()
            
            guard mongoc_collection_remove(internalPointer, flags, queryDocumentPointer, writeConcern?.storage.internalPointer ?? nil, &errorBSON)
                else { throw BSON.Error(unsafePointer: &errorBSON) }
        }
        
        /// Returns the number of documents in the collection that match the query.
        public func count(query: BSON.Document, flags: mongoc_query_flags_t = MONGOC_QUERY_NONE, skip: Int = 0, limit: Int = 0) throws -> Int64 {
            
            guard let queryDocumentPointer = BSON.unsafePointerFromDocument(query)
                else { fatalError("Could not convert BSON document to bson_t") }
            
            defer { bson_destroy(queryDocumentPointer) }
            
            var errorBSON = bson_error_t()
            
            let count = mongoc_collection_count(internalPointer, flags, queryDocumentPointer, Int64(skip), Int64(limit), nil, &errorBSON)
            
            guard count >= 0 else { throw BSON.Error(unsafePointer: &errorBSON) }
            
            return count
        }
    }
}