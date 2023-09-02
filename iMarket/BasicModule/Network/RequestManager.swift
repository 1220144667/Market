//
//  RequestManager.swift
//  iMarket
//
//  Created by 洪陪 on 2023/8/31.
//

import Foundation
import SDCAlertView
import Alamofire
import Moya

//网络请求Code
enum ResponseCode: Int {
    case success = 200            //成功
    case vitoken = 401            //token失效
    case dataRequestFail = -888   //客户端自定义接口返回错误code
    case noneNetwork = -999       //无网络code
    case dataParseFail = -666     //数据解析失败code
}

struct RequestManager {
    
    static let shared = RequestManager()
    
    //私有初始化，避免在外部调用
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = Constant.timeout
        let session = Session.init(configuration: configuration, startRequestsImmediately: false)
        self.provider = MoyaProvider<RequestTarget>(session: session, plugins: [Plugin()])
    }
    
    private var provider: MoyaProvider<RequestTarget>
    
    #if DEBUG
    var environment = Environment.debug(Host.debugIP)
    #else
    var environment = Environment.release(Host.release)
    #endif
    
    struct Plugin { }
    
    /// 定义域名
    enum Host: String {
        case debugIP   = "mkt.ertix.ij0iln.top"
        case release   = "bac.new.hamkke.top"
    }
    
    private struct Constant {
        /// 协议
        static let hyperTextTransferProtocol = "http://"
        static let hyperTextTransferProtocolSecure = "https://"
                
        static let timeout: Double = 30
        
        static let requestErrorDomain = "com.iOS.mkt.requestError"
        
        struct HeaderFieldKey {
            static let tokenKey = "Mkt_token_key"
            static let Authorization = "Authorization"
            static let productVersion = "buildNumber"
            static let versionNumber = "versionNumber"
            static let channel = "channel"
            static let systemVersion = "systemVersion"
            static let lang = "lang"
        }
    }
    
    enum Environment {
        case debug(Host)
        
        case release(Host)
        
        var baseURL: String {
            switch self {
            case .debug(let host):
                return Constant.hyperTextTransferProtocol + host.rawValue
            case .release(let host):
                return Constant.hyperTextTransferProtocol + host.rawValue
            }
        }
        
        var host: String {
            switch self {
            case .debug(let host):
                return host.rawValue
            case .release(let host):
                return host.rawValue
            }
        }
    }
}

extension RequestManager {
    
    static var isNetworkConnect: Bool {
        let network = NetworkReachabilityManager()
        return network?.isReachable ?? true // 无返回就默认网络已连接
    }
    
    func httpHeader() -> [String : String] {
        //获取token
        let authorization = ""
        let productVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let systemVersion = UIDevice.current.systemVersion
        //构造header
        var header: [String: String] = [:]
        header[Constant.HeaderFieldKey.Authorization] = authorization
        header[Constant.HeaderFieldKey.channel] = "iOS"
        header[Constant.HeaderFieldKey.productVersion] = productVersion
        header[Constant.HeaderFieldKey.versionNumber] = versionNumber
        header[Constant.HeaderFieldKey.systemVersion] = systemVersion
        return header
    }
    
    func parameters() -> [String: Any] {
        //构造携带的数据
        var param: [String: String] = [:]
        param["access_token"] = "afe6fa65-f8c8-473f-88c6-805bf726e973"
        param["apiVersion"] = "2"
        param["clientVersion"] = "1.1.6"
        param["softType"] = "timi_ios"
        param["styleType"] = "1"
        return param
    }
}

extension RequestManager.Plugin: PluginType {
    //打印header参数
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        // 打印请求参数
        #if DEBUG
        print("========================================")
        if let _ = request.httpBody {
            let content = "URL: \(request.url!)" + "\n" + "Method: \(request.httpMethod ?? "")" + "\n" + "Body: " + "\(String(data: request.httpBody!, encoding: String.Encoding.utf8) ?? "")"
            print("\(content)")
        } else {
            let content = "URL: \(request.url!)" + "\n" + "Method: \(request.httpMethod ?? "")"
            print("\(content)")
        }
        if let headerView = request.allHTTPHeaderFields {
            print("Header: \(headerView)")
        }
        print("========================================")
        #endif
        return request
    }
}

//request
extension RequestManager {
    
    @discardableResult
    /// 发起网络请求（成功Block回调Data）
    /// - Parameters:
    ///   - request: 请求类
    ///   - isShow: 是否展示HUD
    ///   - success: 成功回调
    ///   - failure: 失败回调
    /// - Returns: 返回Task(可忽略)
    func request(_ request: RequestTarget,
                 showHUD isShow: Bool = true,
                 success: @escaping CompletionCallback,
                 failure: ErrorCallback?) -> Cancellable? {
        guard RequestManager.isNetworkConnect == true else {
            DispatchQueue.main {
                Mkt.makeToast("网络连接失败，请检查网络")
            }
            let domain = Bundle.main.bundleIdentifier ?? Constant.requestErrorDomain
            let error = NSError.init(domain: domain, code: ResponseCode.noneNetwork.rawValue)
            failure?(error)
            return nil
        }
        if isShow {
            ProgressHUD.show("加载中...")
        }
        let task = self.provider.request(request) { result in
            if isShow {
                ProgressHUD.dismiss()
            }
            switch result {
            case let .success(response):
                #if DEBUG
                let jsonData = Mkt.dataToDictionary(response.data)
                dlog(message: "返回结果是：\(String(describing: jsonData))")
                #endif
                success(response.data)
            case let .failure(error as NSError):
                failure?(error)
            }
        }
        return task
    }
    
    @discardableResult
    /// 发起网络请求（成功Block回调泛型）
    /// - Parameters:
    ///   - request: 请求类
    ///   - type: 泛型
    ///   - isShow: 是否展示HUD
    ///   - successHandler: 成功回调
    ///   - failureHandler: 失败回调
    /// - Returns: 返回Task(可忽略)
    func request<T: Codable>(_ request: RequestTarget,
                             type: T.Type,
                             showHUD isShow: Bool = true,
                             successHandler: @escaping ElementCallback<T>,
                             failureHandler: ErrorCallback?) -> Cancellable? {
        let task = self.request(request, showHUD: isShow) { data in
            if let model = Mkt.jsonToModel(Response<T>.self, data) {
                let code = model.code
                let message = model.msg
                if let error = self.filterResponseCode(code, message: message, showHUD: isShow) {
                    failureHandler?(error)
                } else {
                    successHandler(model)
                }
            } else {
                DispatchQueue.main {
                    Mkt.makeToast("数据解析失败")
                }
                let domain = Bundle.main.bundleIdentifier ?? Constant.requestErrorDomain
                let error = NSError.init(domain: domain, code: ResponseCode.dataParseFail.rawValue)
                failureHandler?(error)
            }
        } failure: { error in
            failureHandler?(error)
        }
        return task
    }
    
    @discardableResult
    /// 发起请求（成功Block回调字典）
    /// - Parameters:
    ///   - request: 请求类
    ///   - isShow: 是否展示HUD
    ///   - success: 成功
    ///   - failure: 失败
    /// - Returns: 返回Task(可忽略)
    func dictionaryRequest(_ request: RequestTarget, showHUD isShow: Bool = true, success: @escaping DictionaryCallback, failure: ErrorCallback?) -> Cancellable? {
        self.request(request, showHUD: isShow, success: { data in
            let responseDic = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
            if let responseDic = responseDic {
                success(responseDic)
            } else {
                DispatchQueue.main {
                    #if DEBUG
                    Mkt.makeToast("数据解析失败")
                    #else
                    Mkt.makeToast("网络连接失败，请检查网络")
                    #endif
                }
                let domain = Bundle.main.bundleIdentifier ?? Constant.requestErrorDomain
                let error = NSError.init(domain: domain, code: ResponseCode.dataParseFail.rawValue)
                failure?(error)
            }
        }, failure: failure)
    }
    
    @discardableResult
    /// 发起请求（成功Block回调JSON字符串）
    /// - Parameters:
    ///   - request: 请求类
    ///   - isShow: 是否展示HUD
    ///   - success: 成功
    ///   - failure: 失败
    /// - Returns: 返回Task(可忽略)
    func stringRequest(_ request: RequestTarget, showHUD isShow: Bool = true, success: @escaping StringCallback, failure: ErrorCallback?) -> Cancellable? {
        self.request(request, showHUD: isShow, success: { data in
            if let result = String(data: data, encoding: .utf8) {
                success(result)
            } else {
                DispatchQueue.main {
                    #if DEBUG
                    Mkt.makeToast("数据解析失败")
                    #else
                    Mkt.makeToast("网络连接失败，请检查网络")
                    #endif
                }
                let domain = Bundle.main.bundleIdentifier ?? Constant.requestErrorDomain
                let error = NSError.init(domain: domain, code: ResponseCode.dataParseFail.rawValue)
                failure?(error)
            }
        }, failure: failure)
    }
}

extension RequestManager {
    /// 网络请求错误处理
    /// - Parameters:
    ///   - code: 错误码
    ///   - message: 错误提示
    ///   - isShow: 是否展示Toast
    /// - Returns: 返回错误信息
    private func filterResponseCode(_ code: Int, message: String, showHUD isShow: Bool = true) -> NSError? {
        var error: NSError?
        switch code {
        case ResponseCode.success.rawValue://成功
            break
        case ResponseCode.vitoken.rawValue://token已过期
            error = NSError.init(domain: Bundle.main.bundleIdentifier ?? Constant.requestErrorDomain, code: ResponseCode.vitoken.rawValue)
            let title = "提醒"
            let message = "授权已过期，请重新登录"
            let alert = AlertController(title: title, message: message)
            let style = AlertVisualStyle(alertStyle: .alert)
            style.preferredTextColor = .themColor
            alert.visualStyle = style
            alert.addAction(AlertAction(title: "取消", style: .normal))
            alert.addAction(AlertAction(title: "去登录", style: .preferred, handler: { action in
                //IHLLoginViewModel.shared.removeUserInfo()
                //KV.APP.pushLoginViewController()
            }))
            alert.present()
        default://这里判断是否需要弹出toast提示框
            if isShow {
                DispatchQueue.main {
                    Mkt.makeToast(message)
                }
            }
            let domain = Bundle.main.bundleIdentifier ?? Constant.requestErrorDomain
            error = NSError.init(domain: domain, code: ResponseCode.dataRequestFail.rawValue)
        }
        return error
    }
}
