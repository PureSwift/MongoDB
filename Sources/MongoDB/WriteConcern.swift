//
//  WriteConcern.swift
//  MongoDB
//
//  Created by Alsey Coleman Miller on 12/25/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import SwiftFoundation
import BinaryJSON
import CMongoC

public extension MongoDB {
    
    /// Tells the driver what level of acknowledgment to await from the server. 
    ///
    /// You can specify a write concern on connection objects, database objects, collection objects, or per-operation.
    ///
    /// - SeeAlso: See [Write Concern](http://docs.mongodb.org/manual/core/write-concern/) on the MongoDB website for more information.
    public struct WriteConcern {
        
        // MARK: - Internal Properties
        
        internal var storage: Storage
        
        // MARK: - Initialization
        
        /// Initializes a new ```MongoDB.WriteConcern``` with the default values.
        public init() {
            
            let internalPointer = mongoc_write_concern_new()
            
            self.storage = Storage(internalPointer: internalPointer)
        }
        
        // MARK: - Properties
        
        /// If an fsync should be performed before returning success on a write operation. 
        ///
        /// - Returns: Returns ```true``` if ```fsync``` is set as part of the write concern.
        public var fsync: Bool {
            
            get { return mongoc_write_concern_get_fsync(storage.internalPointer) }
            
            mutating set {
                ensureUnique()
                mongoc_write_concern_set_fsync(storage.internalPointer, newValue)
            }
        }
        
        /// If the write should be journaled before indicating success.
        ///
        /// - Returns: Returns ```true``` if the write should be journaled.
        public var journal: Bool {
            
            get { return mongoc_write_concern_get_journal(storage.internalPointer) }
            
            mutating set {
                ensureUnique()
                mongoc_write_concern_set_journal(storage.internalPointer, newValue)
            }
        }
        
        /// The ```w``` parameter of the write concern.
        ///
        /// - Returns: Returns an integer containing the ```w``` value.
        /// If ```wmajority``` is set, this would be ```MONGOC_WRITE_CONCERN_W_MAJORITY```.
        public var write: Int32 {
            
            get { return mongoc_write_concern_get_w(storage.internalPointer) }
            
            mutating set {
                ensureUnique()
                mongoc_write_concern_set_w(storage.internalPointer, newValue)
            }
        }
        
        /// Sets if the write must have been propagated to a majority of nodes before 
        /// indicating write success.
        ///
        /// - Parameter value: The timeout specifies how long, in milliseconds, 
        /// the server should wait before
        /// indicating that the write has failed. 
        /// This is not the same as a socket timeout. 
        /// A value of zero may be used to indicate no timeout.
        public mutating func setWriteMajority(value: Int32) {
            
            ensureUnique()
            mongoc_write_concern_set_wmajority(storage.internalPointer, value)
        }
        
        /// If the write should be written to a majority of nodes before indicating success.
        ///
        /// - Returns: Returns ```true``` if ```wmajority``` is set.
        public var writeMajority: Bool {
            
            return mongoc_write_concern_get_wmajority(storage.internalPointer)
        }
        
        /// Sets the write tag that must be satistified for the write to indicate success. 
        /// Write tags are preset write concerns configured on your MongoDB server. 
        /// See mongoc_write_concern_t for more information on this setting.
        ///
        /// - Returns: A string containing the ```wtag``` setting if it has been set. 
        /// Otherwise returns ```nil```.
        ///
        /// - SeeAlso: See [```mongoc_write_concern_t```](http://api.mongodb.org/c/current/mongoc_write_concern_t.html) for more information on this setting.
        public var writeTag: String {
            
            get {
                
                // dont need to free string buffer.
                let charBuffer = mongoc_write_concern_get_wtag(storage.internalPointer)
                
                guard charBuffer != nil else { return "" }
                
                return String.fromCString(charBuffer)!
            }
            
            mutating set {
                ensureUnique()
                mongoc_write_concern_set_wtag(storage.internalPointer, newValue)
            }
        }
        
        /// Set the timeout in milliseconds that the server should wait before indicating that
        /// the write has failed. This is not the same as a socket timeout. 
        /// A value of zero may be used to indicate no timeout.
        ///
        /// - Returns: Returns an 32-bit signed integer containing the timeout.
        public var writeTimeout: Int32 {
            
            get { return mongoc_write_concern_get_wtimeout(storage.internalPointer) }
            
            mutating set {
                ensureUnique()
                mongoc_write_concern_set_wtimeout(storage.internalPointer, newValue)
            }
        }
    }
}

// MARK: - Internal

internal extension MongoDB.WriteConcern {
    
    mutating func ensureUnique() {
        if !isUniquelyReferencedNonObjC(&storage) {
            storage = storage.copy
        }
    }
}

internal extension MongoDB.WriteConcern {
    
    /// Internal storage for ```MongoDB.WriteConcern```.
    internal final class Storage: Copying {
        
        let internalPointer: COpaquePointer
        
        deinit { mongoc_write_concern_destroy(internalPointer) }
        
        init(internalPointer: COpaquePointer) {
            
            self.internalPointer = internalPointer
        }
        
        var copy: Storage {
            
            let copyPointer = mongoc_write_concern_copy(internalPointer)
            
            return Storage(internalPointer: copyPointer)
        }
    }
}
