//
//  SQRouter.swift
//  SQRouter
//
//  Created by 宋千 on 2021/8/1.
//

import Foundation
import UIKit

/**
 待解决的问题：
 
 1. 特殊初始化/依赖注入的讨论
 方案1：通过builder
 方案2：通过一个基础协议
 
 2. 调用方式：
 方案1：String
 方案2：Hashable, Equatable, ExpressibleByStringLiteral
 2.1: 适用于name 还是 将name和modular合到一起？
 /**
 // 这种方式的好处是可以直接通过 .语法补全。
 // 但是无法兼容String
 SQRouter.viewControllerWith(name: .UserCenterViewController,
 moduleName: .BusinessA)
 // 这种可以兼容String，但是调用比较长。
 // 由于兼容了String，所以自由度更高，但是也代表了会更加容易出错。
 // 而且如果是直接用String调用的话，则免去了注册流程（因为没有注册，所以更加容易方便，也更加容易出错）
 SQRouter.shared.presentViewControllerWith(name: String.ViewControllerName.UserCenterViewController,
 moduleName: String.ModularName.BusinessA)
 */
 
 3. 调用处理错误反馈
 */

/// 基于CTM的核心思想的映射路由，由于Swift中ViewController会自动调用VC的init，
/// 而不是同OC中的先alloc后init，所以无法用perform一个解决所有问题。
///

// MARK: - SQRouterNameProtocol

// * 因为在swift中String是struct，所以不能直接继承String，采用了继承String所实现的需要的协议的策略。

//public struct SQRouterName: Hashable, Equatable, ExpressibleByStringLiteral {
//
//    public var rawValue: String
//
//    public init(stringLiteral rawValue: String) {
//        self.rawValue = rawValue
//    }
//
//}

// MARK: - SQRouterBaseProtocol
/**
 基础协议
 */
public protocol SQRouterBaseProtocol: AnyObject {
    
}

extension SQRouterBaseProtocol {
    
    /// 获取当前模块的Bundle名称
    /// - Returns: 当前模块的Bundle名称
    static fileprivate func localNamespace() -> String {
        
        return Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
    }
    
    /// 通过KVC将`paramsDictionary`的属性字典赋值到`object`的对应属性上
    /// - Attention: 这里`object`上赋值的属性必须添加`@objc`
    /// - Parameters:
    ///   - object: 属性赋值的目标对象
    ///   - paramsDictionary: 目标对象的属性字典
    static fileprivate func setObject(_ object: AnyObject, by paramsDictionary: [String: Any]?) {
        
        guard let paramsDictionary = paramsDictionary else {
            return
        }
        
        paramsDictionary.forEach { (key, value) in
            
            if Self.isExistProperty(key, by: object) {
                
                object.setValue(value, forKey: key)
            } else {
                
                debugPrint("⚠️在类中\(object)未找到实例属性\(key)")
            }
        }
        
    }
    
    /// 判断实例属性是否存在
    /// - Parameters:
    ///   - name: 属性名
    ///   - object: 目标对象
    /// - Returns: 目标对象是否存在符合属性名的实例属性
    static private func isExistProperty(_ name: String, by object: AnyObject) -> Bool {
        // 通过Mirror来检测是否存在指定属性
        let mirror = Mirror(reflecting: object)
        let superMirror = mirror.superclassMirror
        
        // 本类查找
        for child in mirror.children {
            
            if child.label == name {
                
                return true
            }
        }
        
        // 父类查找
        guard let superMirror = superMirror else {
            return false
        }
        
        for child in superMirror.children {
            
            if child.label == name {
                
                return true
            }
        }
        
        return false
    }
    
}

// MARK: - SQRouterProtocol
/**
 返回指定对象的协议
 */
public protocol SQRouterReturnObjectProtocol: SQRouterBaseProtocol {
    
}

extension SQRouterReturnObjectProtocol {
    
    /// 获取指定的ViewController
    /// - Attention: 这里ViewController上对应的`params`的属性必须添加`@objc`
    /// - Parameters:
    ///   - name: 目标ViewController的名称字符串
    ///   - moduleName: 目标ViewController所在的模块名称（即前缀）
    ///   - params: 属性字典
    
    static fileprivate func viewControllerWith(name: String,
                                               moduleName: String?,
                                               params: [String: Any]?) -> UIViewController? {
        
        // 确认类名
        var viewControllerClassName = "\(Self.localNamespace()).\(name)"
        if let moduleName = moduleName {
            viewControllerClassName = "\(moduleName).\(name)"
        }
        
        // 映射类
        let viewControllerClass: AnyClass? = NSClassFromString(viewControllerClassName)
        guard let viewControllerType = viewControllerClass as? UIViewController.Type else {
            return nil
        }
        
        // 初始化
        let viewController = viewControllerType.init()
        
        // KVC赋值
        Self.setObject(viewController, by: params)
        
        return viewController
    }
    
    static fileprivate func objectWith(name: String,
                                  moduleName: String?,
                                  params: [String: Any]?) -> NSObject? {
        
        // 确认类名
        var objectClassName = "\(Self.localNamespace()).\(name)"
        if let moduleName = moduleName {
            objectClassName = "\(moduleName).\(name)"
        }
        
        // 映射类
        let objectClass: AnyClass? = NSClassFromString(objectClassName)
        guard let objectType = objectClass as? NSObject.Type else {
            return nil
        }
        
        // 初始化
        let object = objectType.init()
        
        // KVC赋值
        Self.setObject(object, by: params)
        
        return object
    }
    
    static public func objectWith(url urlString: String?) -> NSObject? {
        
        let http = "http"
        let https = "https"
        
        guard let sureUrlString = urlString,
              let url = URL(string: sureUrlString) else {
            
            return nil
        }
        
        // scheme
        if let scheme = url.scheme,
           (scheme == https || scheme == http) {
            // 打开webView
            return nil
        }
        
        // host
        guard let modularName = url.host else {
            return nil
        }
        
        // path
        let path = url.path as String
        let startIndex = path.index(path.startIndex, offsetBy: 1)
        let pathArray = path.suffix(from: startIndex).components(separatedBy: "/")
        
        
        guard pathArray.count == 1 ,
              let objcName = pathArray.first else {
            
            return nil
        }
        
        return Self.objectWith(name: objcName,
                               moduleName: modularName,
                               params: url.queryDictionary)
        
    }
    
}

// MARK: - SQRouterOpenProtocol
/**
 跳转到指定VC的协议
 */
public protocol SQRouterOpenProtocol: SQRouterReturnObjectProtocol {
    
}

extension SQRouterOpenProtocol {
    
    /// 以present的形式弹出一个ViewController
    /// - Parameters:
    ///   - name: 目标ViewController的名称字符串
    ///   - moduleName: 目标ViewController所在的模块名称（即前缀）
    ///   - params: 属性字典
    ///   - animated: 是否显示动画
    ///   - fromViewController: presentingViewController
    ///   - completion: present后的回调
    static fileprivate func presentWith(name: String,
                                        moduleName: String? = nil,
                                        params: [String: Any]? = nil,
                                        animated: Bool = true,
                                        from fromViewController: UIViewController? = nil,
                                        completion: (() -> Void)? = nil) {
        
        guard let presentViewController = Self.viewControllerWith(name: name,
                                                                  moduleName: moduleName,
                                                                  params: params)  else {
            return
        }
        
        if let fromViewController = fromViewController {
            fromViewController.present(presentViewController,
                                       animated: animated,
                                       completion: completion)
            return
        }
        
        Self.currentViewController()?.present(presentViewController,
                                              animated: animated,
                                              completion: completion)
        
        
    }
    
    /// 通过URL，以present的形式弹出一个ViewController
    /// - Parameters:
    ///   - urlString: url: appscheme://moduleName/ViewControllerName?quereyParams
    ///   - params: 参数字典。这个参数字典会覆盖url中的参数。
    static public func presentWith(url urlString: String?,
                                   params: [String: Any]? = nil) {
        
        let http = "http"
        let https = "https"
        
        // url
        guard let sureUrlString = urlString,
              let url = URL(string: sureUrlString) else {
            
            return
        }
        
        // scheme
        if let scheme = url.scheme,
           (scheme == https || scheme == http) {
            // 打开webView
            
            return
        }
        
        // host
        guard let moduleName = url.host else {
            return
        }
        
        // path
        let path = url.path as String
        let startIndex = path.index(path.startIndex, offsetBy: 1)
        let pathArray = path.suffix(from: startIndex).components(separatedBy: "/")
        
        guard pathArray.count == 1 ,
              let viewControllerName = pathArray.first else {
            
            return
        }
        
        // params
        var finalParams = params
        
        if url.queryDictionary == nil,
           finalParams == nil {
            
        } else if let urlParams = url.queryDictionary {
            
            finalParams?.merge(urlParams, uniquingKeysWith: { paramsKeyValue, urlKeyValue in
                return paramsKeyValue
            })
        }
        
        Self.presentWith(name: viewControllerName,
                         moduleName: moduleName,
                         params: finalParams,
                         animated: true,
                         completion: nil)
    }
    
}

extension SQRouterOpenProtocol {
    
    /// 获取当前window的顶层NavigationController
    /// - Returns: 顶层NavigationController
    static fileprivate func currentNavigationController() -> UINavigationController? {
        
        return currentViewController()?.navigationController
    }
    
    /// 获取顶层ViewController
    /// - Returns: 顶层ViewController
    static private func currentViewController() -> UIViewController? {
        
        var keyWindow = UIApplication.shared.keyWindow
        
        if keyWindow?.windowLevel != UIWindow.Level.normal {
            
            let windows = UIApplication.shared.windows
            
            for tempWindow in windows {
                
                if tempWindow.windowLevel == UIWindow.Level.normal {
                    keyWindow = tempWindow
                    break
                }
            }
        }
        
        let viewController = keyWindow?.rootViewController
        
        return topViewController(viewController)
    }
    
    /// 递归获取顶层控制器
    /// - Parameter viewController: 目标ViewController
    /// - Returns: 目标ViewController的最上层ViewController
    static private func topViewController(_ viewController :UIViewController?) -> UIViewController? {
        
        guard let viewController = viewController else {
            print("❌ 未找到控制器")
            return nil
        }
        
        //modal出来的 控制器
        if let presentViewController = viewController.presentedViewController {
            
            return topViewController(presentViewController)
        }
        // UISplitViewController 的根控制器
        else if let splitViewController = viewController as? UISplitViewController {
            
            if splitViewController.viewControllers.count > 0 {
                return topViewController(splitViewController.viewControllers.last)
            }
            
            return viewController
        }
        // tabBar 的跟控制器
        else if let tabViewController = viewController as? UITabBarController {
            
            if tabViewController.viewControllers != nil {
                return topViewController(tabViewController.selectedViewController)
            }
            
            return viewController
        }
        // navigation 控制器
        else if let naiViewController = viewController as? UINavigationController {
            
            if naiViewController.viewControllers.count > 0 {
                
                return topViewController(naiViewController.visibleViewController)
            }
            
            return viewController
        }
        
        return viewController
    }
    
}

// MARK: - SQRouterPerformProtocol
/**
 利用runtime直接调用方法的协议
 */
public protocol SQRouterPerformProtocol: SQRouterBaseProtocol {
    
}

extension SQRouterPerformProtocol {
    
    static public func performTarget(_ object: AnyObject?,
                                     action: String,
                                     with param1: Any? = nil,
                                     with param2: Any? = nil) -> Unmanaged<AnyObject>? {
        
        guard let object = object else {
            return nil
        }
        
        let mateType: AnyObject.Type = type(of: object)
        let selector = NSSelectorFromString(action)
        
        // 验证方法是否存在
        guard class_getInstanceMethod(mateType, selector) != nil else {
            
            debugPrint("❌，\(object)不存在实例方法\(action)")
            
            return nil
        }
        
        // 验证参数
        // 如果方法需要的参数数量大于所给的参数数量，则会造成崩溃
        let actionComponents = action.components(separatedBy: ":")
        
        if actionComponents.count == 3,
           (param1 != nil && param2 != nil) {
            return nil
        }
        
        if actionComponents.count == 2,
           (param1 != nil) {
            return nil
        }
        
        return object.perform(selector, with: param1, with: param2)
    }
    
    public func performTarget(_ object: AnyObject?,
                                     action: String,
                                     with param1: Any? = nil,
                                     with param2: Any? = nil) -> Unmanaged<AnyObject>? {
        
        return Self.performTarget(object,
                                  action: action,
                                  with: param1,
                                  with: param2)
    }
    
    static public func performClass(_ className: String,
                                    moduleName: String? = nil,
                                    action: String,
                                    with param1: Any? = nil,
                                    with param2: Any? = nil) -> Unmanaged<AnyObject>? {
        
        // 确认类名
        var viewControllerClassName = "\(Self.localNamespace()).\(className)"
        if let moduleName = moduleName {
            viewControllerClassName = "\(moduleName).\(className)"
        }
        
        // 验证类
        guard let mateType: AnyObject = NSClassFromString(viewControllerClassName) else {
            
            print("❌，模块\(String(describing: moduleName))不存在类\(className)")
            
            return nil
        }
        
        // 验证方法是否存在
        let selector = NSSelectorFromString(action)
        guard let mateClass = mateType as? AnyClass,
              class_getClassMethod(mateClass, selector) != nil else {
            
            print("❌，模块\(String(describing: moduleName))的\(className)不存在类方法\(action)")
            
            return nil
        }
        
        return mateType.perform(selector, with: param1, with: param2)
    }
    
    public func performClass(_ className: String,
                                    moduleName: String? = nil,
                                    action: String,
                                    with param1: Any? = nil,
                                    with param2: Any? = nil) -> Unmanaged<AnyObject>? {
        
        return Self.performClass(className,
                                 moduleName: moduleName,
                                 action: action,
                                 with: param1,
                                 with: param2)
    }
    
}

// MARK: - Extension URL

extension URL {
    
    // URL转字典
    fileprivate var queryDictionary: [String: Any]? {
        
        guard let query = self.query else {
            
            return nil
        }
        
        var queryStrings = [String: String]()
        
        for pair in query.components(separatedBy: "&") {
            
            let key = pair.components(separatedBy: "=")[0]
            
            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            
            queryStrings[key] = value
        }
        
        return queryStrings
    }
    
}

// MARK: - Extension UIViewController

extension UIViewController: SQRouterOpenProtocol {
    
}

extension NSObject: SQRouterPerformProtocol, SQRouterReturnObjectProtocol {
    
}
