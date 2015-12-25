//
//  HostList.swift
//  MongoDB
//
//  Created by Alsey Coleman Miller on 12/25/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import SwiftFoundation
import BinaryJSON
import CMongoC
import CBSON

public extension MongoDB {
    
    public struct Host {
        
        public let host: String
        
        public let hostPort: String
        
        public let port: UInt16
        
        internal static func fromHostList(hostList: mongoc_host_list_t) -> [Host] {
            
            var hostArray = [Host]()
            
            var currentHostList: mongoc_host_list_t? = hostList
            
            while let hostList = currentHostList {
                
                let hostString = String.fromCString(hostList.host)
                
                //hostArray.append(<#T##newElement: MongoDB.Host##MongoDB.Host#>)
            }
        }
    }
}