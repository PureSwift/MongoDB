//
//  MongoDB.swift
//  MongoDB
//
//  Created by Alsey Coleman Miller on 12/13/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import SwiftFoundation
import CMongoC

/// [MongoDB](https://www.mongodb.org)
public final class MongoDB {
    
    public static func initializeLibrary() {
        
        mongoc_init()
    }
    
    public static func cleanupLibrary() {
        
        mongoc_cleanup()
    }
}