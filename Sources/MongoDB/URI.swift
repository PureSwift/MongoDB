//
//  URI.swift
//  MongoDB
//
//  Created by Alsey Coleman Miller on 12/25/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import SwiftFoundation
import BinaryJSON
import CMongoC

public extension MongoDB {
    
    /// Provides an abstraction on top of the MongoDB connection URI format. 
    /// It provides standardized parsing as well as convenience methods for extracting useful information 
    /// such as replica hosts or authorization information.
    /// 
    /// - SeeAlso: See [Connection String URI Reference](http://docs.mongodb.org/manual/reference/connection-string/) 
    /// on the MongoDB website for more information.
    public struct URI: RawRepresentable {
        
        // MARK: - Internal Properties
        
        internal var storage: Storage
        
        // MARK: - Initialization
        
        public init?(rawValue: String) {
            
            let internalPointer = mongoc_uri_new(rawValue)
            
            guard internalPointer != nil else { return nil }
            
            self.storage = Storage(internalPointer: internalPointer)
        }
        
        // MARK: - Properties
        
        public var rawValue: String {
            
            let charBuffer = mongoc_uri_get_string(storage.internalPointer)
            
            return String.fromCString(charBuffer)!
        }
    }
}

// MARK: - Internal

internal extension MongoDB.URI {
    
    mutating func ensureUnique() {
        if !isUniquelyReferencedNonObjC(&storage) {
            storage = storage.copy
        }
    }
}

internal extension MongoDB.URI {
    
    /// Internal storage for ```MongoDB.URI```.
    internal final class Storage: Copying {
        
        let internalPointer: COpaquePointer
        
        deinit { mongoc_uri_destroy(internalPointer) }
        
        init(internalPointer: COpaquePointer) {
            
            self.internalPointer = internalPointer
        }
        
        var copy: Storage {
            
            let copyPointer = mongoc_write_concern_copy(internalPointer)
            
            return Storage(internalPointer: copyPointer)
        }
    }
}