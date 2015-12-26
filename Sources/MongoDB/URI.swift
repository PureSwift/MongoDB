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
        
        // internal class is never mutated
        internal let storage: Storage
        
        // MARK: - Initialization
        
        public init?(rawValue: String) {
            
            let internalPointer = mongoc_uri_new(rawValue)
            
            guard internalPointer != nil else { return nil }
            
            self.storage = Storage(internalPointer: internalPointer)
        }
        
        // MARK: - Properties
        
        public lazy var rawValue: String = {
            
            let charBuffer = mongoc_uri_get_string(self.storage.internalPointer)
            
            return String.fromCString(charBuffer)!
        }()
        
        /// Fetches the ```authMechanism``` parameter to an URI if provided.
        public lazy var authenticationMechanism: String? = {
            
            // C string should not be freed
            return String.fromCString(mongoc_uri_get_auth_mechanism(self.storage.internalPointer))
        }()
        
        /// Fetches the ```authSource``` parameter of an URI if provided.
        public lazy var authenticationSource: String? = {
            
            // C string should not be freed
            return String.fromCString(mongoc_uri_get_auth_source(self.storage.internalPointer))
        }()
        
        /// Fetches the database portion of an URI if provided. This is the portion after the / but before the ?. 
        public lazy var database: String? = {
            
            // C string should not be freed
            return String.fromCString(mongoc_uri_get_database(self.storage.internalPointer))
        }()
        
        /// Fetches an array of hosts that were defined in the URI (the comma-separated host section).
        public lazy var hosts: [Host] = {
            
            let hostListPointer = mongoc_uri_get_hosts(self.storage.internalPointer)
            
            return Host.fromHostList(hostListPointer.memory)
        }()
        
        // MARK: - Static Methods
        
        /// Unescapes an URI encoded string. For example, "%40" would become "@".
        static func unescape(escapedString: String) -> String {
            
            let stringPointer = mongoc_uri_unescape(escapedString)
            
            defer { bson_free(stringPointer) }
            
            return String.fromCString(stringPointer)!
        }
    }
}

// MARK: - Internal

internal extension MongoDB.URI {
    
    /// Internal storage for ```MongoDB.URI```.
    internal final class Storage: Copying {
        
        let internalPointer: COpaquePointer
        
        deinit { mongoc_uri_destroy(internalPointer) }
        
        init(internalPointer: COpaquePointer) {
            
            self.internalPointer = internalPointer
        }
        
        var copy: Storage {
            
            let copyPointer = mongoc_uri_copy(internalPointer)
            
            return Storage(internalPointer: copyPointer)
        }
    }
}