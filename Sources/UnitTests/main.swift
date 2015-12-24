//
//  main.swift
//  MongoDB
//
//  Created by Alsey Coleman Miller on 12/24/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import XCTest
import MongoDB

/// Will setup MongoDB exactly once
let setupMongo: Void = { MongoDB.initializeLibrary() }()

#if os(Linux)
    
    setupMongo
    
    
    
#endif