//
//  MongoDB.swift
//  MongoDB
//
//  Created by Alsey Coleman Miller on 12/13/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import SwiftFoundation
import CMongoC

public final class MongoDB {
    
    static func initializeLibrary() {
        
        mongoc_client_new(<#T##uri_string: UnsafePointer<Int8>##UnsafePointer<Int8>#>)
    }
}