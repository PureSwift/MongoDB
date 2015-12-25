//
//  Cursor.swift
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
    
    /// Provides access to a MongoDB query cursor. 
    /// It wraps up the wire protocol negotiation required to initiate a query and retrieve an unknown number of documents. 
    /// Cursors are lazy, meaning that no network traffic occurs until the first call to ```next()```.
    /// 
    /// - Note: Is NOT thread safe. It may only be used from the thread it was created from.
    public final class Cursor {
        
        // MARK: - Internal Properties
        
        internal let internalPointer: COpaquePointer
        
        // MARK: - Initialization
        
        deinit { mongoc_cursor_destroy(internalPointer) }
        
        internal init(internalPointer: COpaquePointer) {
            
            assert(internalPointer != nil)
            
            self.internalPointer = internalPointer
        }
        
        // MARK: - Computed Properties
        
        /// Fetches the MongoDB host that the cursor is communicating with
        public var host: [Host] {
            
            var hostList = mongoc_host_list_t()
            
            mongoc_cursor_get_host(internalPointer, &hostList)
            
            return Host.fromHostList(hostList)
        }
        
        /// Checks to see if a cursor is in a state that allows for more documents to be queried.
        ///
        /// This is primarily useful with tailable cursors.
        ///
        /// - Returns: ```true``` if there may be more content to retrieve from the cursor.
        public var isAlive: Bool {
            
            return mongoc_cursor_is_alive(internalPointer)
        }
        
        /// Indicates if there is more data to be read from the cursor.
        public var more: Bool {
            
            return mongoc_cursor_more(internalPointer)
        }
        
        /* Swift compiler cant find declaration.
        
        /// The maximum waiting time in miliseconds.
        ///
        /// - Note: The maximum amount of time for the server to wait on new documents to satisfy a tailable cursor query. 
        /// Only applies if the is cursor created from ```mongoc_collection_find``` with the query flags 
        /// ```MONGOC_QUERY_TAILABLE_CURSOR``` and ```MONGOC_QUERY_AWAIT_DATA```, and the server is MongoDB 3.2 or later.
        ///
        /// - SeeAlso: [Tailable Cursors](http://api.mongodb.org/c/current/cursors.html#tailable)
        public var maxAwaitTime: UInt32 {
            
            get { return mongoc_cursor_get_max_await_time_ms(internalPointer) }
            
            set { mongoc_cursor_set_max_await_time_ms(internalPointer, newValue) }
        }
        */
        
        // MARK: - Methods
        
        public func next() throws -> BSON.Document? {
            
            // The bson objects set in mongoc_cursor_next are ephemeral and good until the next call.
            let bsonPointer = UnsafeMutablePointer<UnsafePointer<bson_t>>.alloc(1)
            defer { bsonPointer.dealloc(1) }
            
            guard mongoc_cursor_next(internalPointer, bsonPointer) else {
                
                if let error = currentError { throw error }
                else { return nil }
            }
            
            guard let document = BSON.documentFromUnsafePointer(UnsafeMutablePointer(bsonPointer.memory))
                else { fatalError("Could not create document from unsafe pointer") }
            
            return document
        }
        
        public func currentDocument() throws -> BSON.Document {
            
            let bsonPointer = mongoc_cursor_current(internalPointer)
            
            guard bsonPointer != nil else { throw currentError! }
            
            guard let document = BSON.documentFromUnsafePointer(UnsafeMutablePointer(bsonPointer))
                else { fatalError("Could not create document from unsafe pointer") }
            
            return document
        }
        
        // MARK: - Private
        
        private var currentError: BSON.Error? {
            
            var error = bson_error_t()
            
            guard mongoc_cursor_error(internalPointer, &error) == false
                else { return BSON.Error(unsafePointer: &error) }
            
            return nil
        }
    }
}

// MARK: - Copying

extension MongoDB.Cursor: Copying {
    
    /// Creates a copy of the cursor.
    ///
    /// - Note: The cloned cursor will be reset to the beginning of the query,
    /// and therefore the query will be re-executed on the MongoDB server when ```next()``` is called.
    public var copy: MongoDB.Cursor {
        
        let clonePointer = mongoc_cursor_clone(internalPointer)
        
        return MongoDB.Cursor(internalPointer: clonePointer)
    }
}

// MARK: - CustomStringConvertible

extension MongoDB.Cursor: CustomStringConvertible {
    
    public var description: String {
        
        return "MongoDB.MongoDB.Cursor(host: \(host), isAlive: \(isAlive), more: \(more))"
    }
}

// MARK: - GeneratorType

public extension MongoDB.Cursor {
    
    public var generator: Generator {
        
        return Generator(cursor: self)
    }
    
    public final class Generator: GeneratorType {
        
        public let cursor: MongoDB.Cursor
        
        public func next() -> BSON.Document? {
            
            var document: BSON.Document?
            
            do { document = try cursor.next() }
            
            catch { return nil }
            
            return document
        }
        
        public init(cursor: MongoDB.Cursor) {
            
            self.cursor = cursor
        }
    }
}

