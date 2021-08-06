//
//  SQRouter.swift
//  SQRouter
//
//  Created by 宋千 on 2021/8/1.
//

import Foundation
import UIKit

public enum SQRouterContact {
    
    case bviewController(intValue: Int, stringValue: String)
    
}

extension SQRouterContact: ContactType {
    
    public var scheme: String { "scheme" }

    public var host: String {
        switch  self {
            case .bviewController:
                return "SQRouter_Example"
        }
    }

    public var path: String {
        
        switch self {
            
        case .bviewController: return "BViewController"
            
        }
    }
    
    public var param: [String : Any]? {
        
        switch self {
            
            case let .bviewController(intValue, stringValue):
                return ["intValue": intValue,
                        "stringValue": stringValue]
                
        }
    }

    public var methodType: MethodType { .present }

    public var nextTarget: ContactType? { nil }
    
}


extension SQRouterOpenProtocol {
    
    public static func openContant<T: ContactType>(_ contant: T) {
        
        switch contant.methodType {
            
            case .present:
                presentWith(name: contant.path,
                            moduleName: contant.host,
                            params: contant.param)
            case .push:
                pushWith(name: contant.path,
                         moduleName: contant.host,
                         params: contant.param)
                
            case .shoot:
                shootWith(name: contant.path,
                          moduleName: contant.host,
                          params: contant.param)
        }
        
    }
    
    public static func openContant(_ contant: SQRouterContact) {
        
        switch contant.methodType {
            
            case .present:
                presentWith(name: contant.path,
                            moduleName: contant.host,
                            params: contant.param)
            case .push:
                pushWith(name: contant.path,
                         moduleName: contant.host,
                         params: contant.param)
                
            case .shoot:
                shootWith(name: contant.path,
                          moduleName: contant.host,
                          params: contant.param)
        }
        
    }
    
}
