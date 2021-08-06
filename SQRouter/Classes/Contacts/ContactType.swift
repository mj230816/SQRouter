//
//  File.swift
//  SQRouter
//
//  Created by 宋千 on 2021/8/5.
//

import Foundation

public enum MethodType {
    
    case present
    
    case push
    
    case shoot
}

public protocol ContactType {
    
    var scheme: String { get }
    
    var host: String { get }
    
    var path: String { get }
    
    var param: [String : Any]? { get }
    
    var methodType: MethodType { get }
    
    var nextTarget: ContactType? { get }
    
}

