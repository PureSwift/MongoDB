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
        
        internal static func fromHostList(firstHostList: mongoc_host_list_t) -> [Host] {
            
            var hostArray = [Host]()
            
            var currentHostList: mongoc_host_list_t? = firstHostList
            
            // convert and add to array
            while var hostList = currentHostList {
                
                let hostString: String
                
                do {
                    
                    let string = withUnsafePointer(&hostList.host) { (unsafeTuplePointer) -> String in
                        
                        let charPointer = unsafeBitCast(unsafeTuplePointer, UnsafePointer<CChar>.self)
                        
                        guard let string = String.fromCString(charPointer)
                            else { fatalError("Could not create string ") }
                        
                        return string
                    }
                    
                    hostString = string
                }
                
                let hostPortString: String
                
                do {
                    
                    let string = withUnsafePointer(&hostList.host_and_port) { (unsafeTuplePointer) -> String in
                        
                        let charPointer = unsafeBitCast(unsafeTuplePointer, UnsafePointer<CChar>.self)
                        
                        guard let string = String.fromCString(charPointer)
                            else { fatalError("Could not create string ") }
                        
                        return string
                    }
                    
                    hostPortString = string
                }
                
                
                // create host and add to array
                let host = Host(host: hostString, hostPort: hostPortString, port: hostList.port)
                
                // make sure first host is not empty
                if hostArray.isEmpty {
                    
                    guard host.host.isEmpty == false && host.hostPort.isEmpty == false
                        else { return [] }
                }
                
                hostArray.append(host)
                
                // set next host in linked list
                if hostList.next != nil {
                    
                    currentHostList = hostList.next.memory
                }
                else { currentHostList = nil }
            }
            
            return hostArray
        }
    }
}