//
//  Client.swift
//  MongoDB
//
//  Created by Alsey Coleman Miller on 12/13/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import SwiftFoundation
import CMongoC
import struct BinaryJSON.BSON

#if os(OSX)
    import bson
#elseif os(Linux)
    import CBSON
#endif

public extension MongoDB {
    
    public final class Client {
        
        // MARK: - Internal Properties
        
        internal let internalPointer: COpaquePointer
        
        // MARK: - Initialization
        
        deinit {
            
            mongoc_client_destroy(internalPointer)
        }
        
        public init(URL: String) {
            
            self.internalPointer = mongoc_client_new(URL)
        }
        
        // MARK: - Public Properties
        
        public var maximumBSONSize: Int32 {
            
            return mongoc_client_get_max_bson_size(internalPointer)
        }
        
        // MARK: - Methods
        
        /// Sends a simple command to the server.
        public func command(command: BSON.Value, databaseName: String) {
            
            
            
            mongoc_client_command_simple(internalPointer, databaseName, commandPointer, readPreferences, &reply, &error)
        }
    }
}