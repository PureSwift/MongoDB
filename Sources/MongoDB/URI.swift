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
        
        public var rawValue: String { return storage.stringValue }
        
        /// Fetches the ```authMechanism``` parameter to an URI if provided.
        public var authenticationMechanism: String? { return storage.authenticationMechanism }
        
        /// Fetches the ```authSource``` parameter of an URI if provided.
        public var authenticationSource: String? { return storage.authenticationSource }
        
        /// Fetches the database portion of an URI if provided. This is the portion after the / but before the ?. 
        public var database: String? { return storage.database }
        
        /// Fetches an array of hosts that were defined in the URI (the comma-separated host section).
        public var hosts: [Host] { return storage.hosts }
        
        /// Fetches a bson document containing all of the options provided after the ```?``` of a URI.
        public var options: BSON.Document { return storage.options }
        
        /// Fetches the password portion of an URI.
        public var password: String? { return storage.password }
        
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
        
        // MARK: Getters
        
        lazy var stringValue: String = {
            
            let charBuffer = mongoc_uri_get_string(self.internalPointer)
            
            return String.fromCString(charBuffer)!
        }()
        
        lazy var authenticationMechanism: String? = {
            
            // C string should not be freed
            return String.fromCString(mongoc_uri_get_auth_mechanism(self.internalPointer))
        }()
        
        lazy var authenticationSource: String? = {
            
            // C string should not be freed
            return String.fromCString(mongoc_uri_get_auth_source(self.internalPointer))
        }()
        
        lazy var database: String? = {
            
            // C string should not be freed
            return String.fromCString(mongoc_uri_get_database(self.internalPointer))
        }()
        
        lazy var hosts: [MongoDB.Host] = {
            
            let hostListPointer = mongoc_uri_get_hosts(self.internalPointer)
            
            return MongoDB.Host.fromHostList(hostListPointer.memory)
        }()
        
        lazy var options: BSON.Document = {
            
            // get BSON pointer (should not be freed)
            let unsafePointer = mongoc_uri_get_options(self.internalPointer)
            
            guard let document = BSON.documentFromUnsafePointer(UnsafeMutablePointer(unsafePointer))
                else { fatalError("Could not create BSON document from unsafe pointer") }
            
            return document
        }()
        
        lazy var password: String? = {
            
            return String.fromCString(mongoc_uri_get_password(self.internalPointer))
        }()
    }
}

