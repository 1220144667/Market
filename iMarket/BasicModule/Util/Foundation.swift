//
//  Foundation.swift
//  iMarket
//
//  Created by 洪陪 on 2023/8/30.
//

import Foundation
import UIKit
import Toast_Swift
import Moya

//打印行...
func dlog<T>(message: T, file: String = #file, function: String = #function, lineNumber: Int = #line) {
    if !Mkt.isDebug {
        return
    }
    var fileName = (file as NSString).lastPathComponent
    if fileName.hasSuffix(".swift") {
        fileName.removeLast(".swift".count)
    }
    print("\(fileName).\(function):\(lineNumber)\n\(message)")
}

public struct Mkt {
    /// app名字
    public static var appName: String {
        if let bundleDisplayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return bundleDisplayName
        } else if let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
            return bundleName
        }
        return "村超"
    }
    /// iMarket: 返回是否是DEBUG模式
    public static var isDebug: Bool {
    #if DEBUG
        return true
    #else
        return false
    #endif
    }
    /// iMarket: 返回是否是真机
    public static var isDevice: Bool {
    #if targetEnvironment(simulator)
        return false
    #else
        return true
    #endif
    }
    #if os(iOS)
    /// iMarket: 返回屏幕旋转方向
    public static var screenOrientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    #endif
    /// iMarket: 返回屏幕宽度
    public static var screenWidth: CGFloat {
        #if os(iOS)
        if screenOrientation.isPortrait {
            return UIScreen.main.bounds.size.width
        } else {
            return UIScreen.main.bounds.size.height
        }
        #elseif os(tvOS)
        return UIScreen.main.bounds.size.width
        #endif
    }
    /// iMarket: 返回屏幕高度
    public static var screenHeight: CGFloat {
        #if os(iOS)
        if screenOrientation.isPortrait {
            return UIScreen.main.bounds.size.height
        } else {
            return UIScreen.main.bounds.size.width
        }
        #elseif os(tvOS)
        return UIScreen.main.bounds.size.height
        #endif
    }
    
    /// 顶部导航栏高度（包括安全区）
    public static var topBarHeight: CGFloat {
        return safe_top + 44.0
    }
    
    /// iMarket: 屏幕顶部安全距离
    public static var safe_top: CGFloat {
        let scene = UIApplication.shared.connectedScenes.first
        guard let windowScene = scene as? UIWindowScene else { return 0 }
        guard let statusBarManager = windowScene.statusBarManager else { return 0 }
        let statusBarHeight = statusBarManager.statusBarFrame.height
        return statusBarHeight
    }
    /// iMarket: 屏幕底部安全距离
    public static var safe_bottom: CGFloat {
        if #available(iOS 11.0, *) {
            return self.keyWindow?.safeAreaInsets.bottom ?? 0.0
        } else {
            return 0
        }
    }
    /// 底部导航栏高度（包括安全区）
    public static var KV_tabBarFullHeight: CGFloat {
        return safe_bottom + 49.0
    }
    ///获取国际化文字
    static func localized(_ name: String) -> String {
        return NSLocalizedString(name, comment: "")
    }
    /// 默认头像
    public static var defaultToAvatar: UIImage? {
        return UIImage(named: "avatar")
    }
    
    /// iMarket: 返回底部bottom边距
    public static var bottomMargin: CGFloat {
        let scene = UIApplication.shared.connectedScenes.first
        guard let windowScene = scene as? UIWindowScene else { return 0 }
        guard let window = windowScene.windows.first else { return 0 }
        return window.safeAreaInsets.bottom
    }
    
    public static var safeAreaInsets: UIEdgeInsets {
        let scene = UIApplication.shared.connectedScenes.first
        guard let windowScene = scene as? UIWindowScene else { return .zero }
        guard let window = windowScene.windows.first else { return .zero }
        let safeAreaInsets = window.safeAreaInsets
        return safeAreaInsets
    }
}

extension Mkt {
    
    /// 发起网络请求（GET）
    /// - Parameters:
    ///   - path: 接口
    ///   - query: 参数
    ///   - type: 泛型
    ///   - showHUD: 是否显示
    ///   - success: 成功
    ///   - failure: 失败
    /// - Returns: 网络请求Task
    @discardableResult static func requestToGet<T: Codable>(path: RequestPath, query: [String: Any] = [:], type: T.Type = MktNull.self, showHUD: Bool = true, success: @escaping ElementCallback<T>, failure: ErrorCallback?) -> Cancellable? {
        return RequestTarget.get(path, query).send(showHUD: showHUD, type: type, success: success, failure: failure)
    }
    
    /// 发起网络请求（POST）
    /// - Parameters:
    ///   - path: 接口
    ///   - query: 参数
    ///   - type: 泛型
    ///   - showHUD: 是否显示
    ///   - success: 成功
    ///   - failure: 失败
    /// - Returns: 网络请求Task
    @discardableResult static func requestToPost<T: Codable>(path: RequestPath, body: [String: Any] = [:], type: T.Type = MktNull.self, showHUD: Bool = true, success: @escaping ElementCallback<T>, failure: ErrorCallback?) -> Cancellable? {
        return RequestTarget.post(path, body).send(showHUD: showHUD, type: type, success: success, failure: failure)
    }
    
    /// 上传图片
    /// - Parameters:
    ///   - path: 接口
    ///   - image: 图片
    ///   - type: 泛型
    ///   - showHUD: 是否显示 
    ///   - success: 成功
    ///   - failure: 失败
    /// - Returns: 网络请求Task
    @discardableResult static func requestToUpload<T: Codable>(path: RequestPath, images: [UIImage], type: T.Type = MktNull.self, showHUD: Bool = true, success: @escaping ElementCallback<T>, failure: ErrorCallback?) -> Cancellable? {
        return RequestTarget.upload(path, images).send(showHUD: showHUD, type: type, success: success, failure: failure)
    }
    
    @discardableResult static func requestToFiles<T: Codable>(path: RequestPath, files: [URL], type: T.Type = MktNull.self, showHUD: Bool = true, success: @escaping ElementCallback<T>, failure: ErrorCallback?) -> Cancellable? {
        return RequestTarget.uploadFiles(path, files).send(showHUD: showHUD, type: type, success: success, failure: failure)
    }
}

//Toast
extension Mkt {
    /// 在window上展示toast
    /// - Parameters:
    ///   - message: 提示信息
    ///   - position: 位置：顶部，居中，底部（默认居中）
    static func makeToast(_ message: String, _ position: ToastPosition = .center) {
        Mkt.keyWindow?.makeToast(message, duration: 1, position: position)
    }
}

extension Mkt {
    static func openWifi() {
        let urlStr:String = "App-Prefs:root=WIFI"
        let url = NSURL.init(string: urlStr)
        if UIApplication.shared.canOpenURL(url! as URL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url! as URL)
            }
        }
    }
}

//json解析
extension Mkt {
    //JSON解析为模型
    static func jsonToModel<T: Codable>(_ modelType: T.Type, _ response: Data) -> T? {
        var modelObject: T?
        do {
            let jsonDecoder = JSONDecoder()
            modelObject = try jsonDecoder.decode(modelType, from: response)
        } catch {
            dlog(message: error)
        }
        return modelObject
    }
    //Data转为JSON dictionary
    static func dataToDictionary(_ data: Data?) -> Any? {
        if let d = data {
            var error: NSError?
            let json: Any?
            do {
                json = try JSONSerialization.jsonObject(with:d)
            } catch let error1 as NSError {
                error = error1
                json = nil
            }

            if error != nil {
                return nil
            } else {
                return json
            }
        } else {
            return nil
        }
    }
}

//获取当前window
extension Mkt {
    // 获取当前window
    public static var keyWindow: UIWindow? {
        return self.getCurrentWindow()
    }
    
    //current window
    public static func getCurrentWindow() -> UIWindow? {
        if #available(iOS 14.0, *){
            if let window = UIApplication.shared.connectedScenes.compactMap({$0 as? UIWindowScene}).first?.windows.first{
                return window
            }else{
                return nil
            }
        }else{
            if let window = UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive}).compactMap({$0 as? UIWindowScene}).first?.windows.filter({$0.isKeyWindow}).first{
                return window
            }else if let window = UIApplication.shared.delegate?.window {
                return window
            }else{
                return nil
            }
        }
    }
}

//快捷获取主队列以及单次执行
extension DispatchQueue {
    //once
    private static var onceTokens = [String]()
    class func once(_ token: String, block: () -> Void) {
        defer {
            objc_sync_exit(self)
        }
        objc_sync_enter(self)
        if DispatchQueue.onceTokens.contains(token) {
            return
        }
        DispatchQueue.onceTokens.append(token)
        block()
    }
    //main
    class func main(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
}

//延迟函数
extension Mkt {
    /// iMarket: 延迟执行
    public static func runThisAfterDelay(seconds: Double, after: @escaping () -> Void) {
        runThisAfterDelay(seconds: seconds, queue: DispatchQueue.main, after: after)
    }
    
    /// iMarket: 在x秒后运行函数
    public static func runThisAfterDelay(seconds: Double, queue: DispatchQueue, after: @escaping () -> Void) {
        let time = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        queue.asyncAfter(deadline: time, execute: after)
    }
}

//通过文字计算Label
extension Mkt {
    /// iMarket: 通过文字计算label的宽度（单行文字的情况）
    public static func labelWithWidth(text: String, font: UIFont) -> CGFloat {
        let statusLabelText: NSString = text as NSString
        let size = CGSize(width: 500000, height: 500000)
        let attr = [NSAttributedString.Key.font: font]
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attr, context: nil).size
        return strSize.width
    }
    
    /// iMarket: 通过文字计算label的高度（宽度固定的情况）
    public static func labelWithHeight(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let statusLabelText: NSString = text as NSString
        let size = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let attr = [NSAttributedString.Key.font: font]
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attr, context: nil).size
        return strSize.height
    }
    
    /// iMarket: 通过文字计算label的高度（宽度固定的情况）
    public static func labelWithWidth(text: String, font: UIFont, height: CGFloat) -> CGFloat {
        let statusLabelText: NSString = text as NSString
        let size = CGSize(width: CGFloat(MAXFLOAT), height: height)
        let attr = [NSAttributedString.Key.font: font]
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attr, context: nil).size
        return strSize.width
    }
    
    /// iMarket: 通过文字计算label的高度（带有富文本的情况）
    public static func labelWithSpaceHeight(text: String, attr: [NSAttributedString.Key : Any], width: CGFloat) -> CGFloat {
        
        let size = text.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: attr, context: nil).size
        
        return size.height;
    }

    //计算label的行数
    public static func getRealLabelTextLines(labelText: String, width: CGFloat, font: UIFont) -> Int {
        //计算理论上显示所有文字需要的尺寸
        let rect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let labelTextSize = (labelText as NSString)
            .boundingRect(with: rect, options: .usesFontLeading,attributes: [NSAttributedString.Key.font: font], context: nil)
        //计算理论上需要的行数
        let labelTextLines = Int(ceil(CGFloat(labelTextSize.height) / font.lineHeight))
        return labelTextLines
    }
}
