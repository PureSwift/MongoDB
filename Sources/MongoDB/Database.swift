//
//  Database.swift
//  MongoDB
//
//  Created by Alsey Coleman Miller on 12/22/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import SwiftFoundation
import BinaryJSON
import CMongoC
import CBSON

public extension MongoDB {
    
    /// MongoDB database.
    public final class Database {
        
        // MARK: - Properties
        
        public let client: Client
        
        // MARK: - Internal Properties
        
        internal let internalPointer: COpaquePointer
        
        // MARK: - Initialization
        
        deinit {
            
            mongoc_database_destroy(internalPointer)
        }
        
        public init(client: Client, databaseName: String) {
            
            self.client = client
            
            self.internalPointer = mongoc_client_get_database(client.internalPointer, databaseName)
        }
        
        // MARK: - Properties
        
        public var name: String {
            
            return String.fromCString(mongoc_database_get_name(internalPointer))!
        }
    }
}
