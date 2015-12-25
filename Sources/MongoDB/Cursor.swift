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
    
    public final class Cursor {
        
        // MARK: - Internal Properties
        
        internal let internalPointer: COpaquePointer
        
        // MARK: - Initialization
        
        deinit { mongoc_cursor_destroy(internalPointer) }
        
        internal init(internalPointer: COpaquePointer) {
            
            self.internalPointer = internalPointer
        }

    }
}

