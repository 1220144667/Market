//
//  RequestTarget.swift
//  iMarket
//
//  Created by 洪陪 on 2023/8/31.
//

import Foundation
import Alamofire
import Moya

/// 网络错误的回调
typealias ErrorCallback = ((_ error: Swift.Error) -> Void)

//泛型callback
typealias ElementCallback<T: Codable> = ((_ response: Response<T>) -> Void)

//Datacallback
typealias CompletionCallback = ((_ data: Data) -> Void)

//字典callback
typealias DictionaryCallback = ((_ response: NSDictionary) -> Void)

//json callback
typealias StringCallback = ((_ response: String) -> Void)

//请求结果
struct Response<T: Codable>: Codable {
    var retCode: String = "0000"
    var retMsg: String = ""
    var retData: T?
}

//空数据
struct MktNull: Codable {}

//网络请求协议
protocol NetworkTarget: TargetType {
    var headers: [String : String]? { get }
}

//接口协议，外部定义接口必须实现此协议
protocol RequestPath {
    var path: String { get }
}

extension NetworkTarget {
    var baseURL: URL {
        URL.init(string: RequestManager.shared.environment.baseURL)!
    }
    
    var headers: [String : String]? {
        var headers = RequestManager.shared.httpHeader()
        if let tempHeaders = self.headers {
            headers.merge(tempHeaders) { _, value in
                return value
            }
        }
        return headers
    }
}

struct RequestTarget: NetworkTarget {
    
    var path: String
    
    enum Method {
        case get
        case post
        case put
        case delete
        case uploadFiles([URL])
        case uploadFileDatas(([Data]))
    }
    
    var headers: [String : String]?
    
    //请求方式
    private let requestMethod: Method
    //请求参数
    private let parameters: [String : Any]?
    //编码方式
    var bodyEncoding: ParameterEncoding = JSONEncoding.default
    
    //初始化
    init(_ method: Method, _ path: RequestPath, _ parameters: [String : Any]? = nil, _ encoding: ParameterEncoding) {
        self.requestMethod = method
        self.path = path.path
        self.parameters = parameters
        self.bodyEncoding = encoding
    }
    
    var method: Moya.Method {
        var method: Moya.Method
        switch requestMethod {
        case .get:
            method = .get
        case .post:
            method = .post
        case .put:
            method = .put
        case .delete:
            method = .delete
        case .uploadFiles, .uploadFileDatas:
            method = .post
        }
        return method
    }
    
    var task: Task {
        var task: Task
        let parameters: [String : Any] = parameters ?? [:]
        switch requestMethod {
        case .get:
            task = .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .post, .put, .delete:
            task = .requestParameters(parameters: parameters, encoding: bodyEncoding)
        case .uploadFiles(let files):
            let datas: [Moya.MultipartFormData] = files.map { url in
                MultipartFormData(provider: .file(url),
                                  name: "file",
                                  fileName: "pictrue.png",
                                  mimeType: "image/jpg/png/jpeg/gif")
            }
            task = .uploadCompositeMultipart(datas, urlParameters: parameters)
        case .uploadFileDatas(let datas):
            let datas: [Moya.MultipartFormData] = datas.map { data in
                MultipartFormData(provider: .data(data),
                                  name: "file",
                                  fileName: "pictrue.png",
                                  mimeType: "image/jpg/png/jpeg/gif")
            }
            task = .uploadCompositeMultipart(datas, urlParameters: parameters)
        }
        return task
    }
}

//构造请求类
extension RequestTarget {
    /// 构造get请求
    /// - Parameters:
    ///   - path: 接口
    ///   - query: 参数
    /// - Returns: 请求类
    static func get(_ path: RequestPath, _ query: [String: Any] = [:]) -> Self {
        return Self.init(.get, path, query, URLEncoding.queryString)
    }
    
    /// 构造post请求
    /// - Parameters:
    ///   - path: 接口
    ///   - body: 参数
    /// - Returns: 请求类
    static func post(_ path: RequestPath, _ body: [String: Any] = [:], _ encoding: ParameterEncoding = JSONEncoding.default) -> Self {
        return Self.init(.post, path, body, encoding)
    }
    
    /// 构造put请求
    /// - Parameters:
    ///   - path: 接口
    ///   - body: 参数
    /// - Returns: 请求类
    static func put(_ path: RequestPath, _ body: [String : Any] = [:], _ encoding: ParameterEncoding = JSONEncoding.default) -> Self {
        Self.init(.put, path, body, encoding)
    }
    
    /// 构造delete请求
    /// - Parameters:
    ///   - path: 接口
    ///   - body: 参数
    /// - Returns: 请求类
    static func delete(_ path: RequestPath, _ body: [String : Any] = [:], _ encoding: ParameterEncoding = JSONEncoding.default) -> Self {
        Self.init(.delete, path, body, encoding)
    }
    
    /// 构造图片上传请求（单张图片）
    /// - Parameters:
    ///   - path: 接口
    ///   - image: 图片
    /// - Returns: 请求类
    static func upload(_ path: RequestPath, _ images: [UIImage]) -> Self {
        var datas: [Data] = []
        for image in images {
            let data = image.jpegData(compressionQuality: 0.1)!
            datas.append(data)
        }
        let upload = Method.uploadFileDatas(datas)
        return Self.init(upload, path, nil, JSONEncoding.default)
    }
    
    /// 构造图片上传请求（多张图片URL）
    /// - Parameters:
    ///   - path: 接口
    ///   - files: 文件url列表
    /// - Returns: 请求类
    static func uploadFiles(_ path: RequestPath, _ files: [URL]) -> Self {
        let uploadFileURLs = Method.uploadFiles(files)
        return Self.init(uploadFileURLs, path, nil, JSONEncoding.default)
    }
}

//发送请求
extension RequestTarget {
    @discardableResult
    func send(showHUD: Bool, success: @escaping ElementCallback<MktNull>, failure: ErrorCallback?) -> Cancellable? {
        return RequestManager.shared.request(self, type: MktNull.self, showHUD: showHUD, successHandler: success, failureHandler: failure)
    }
    
    @discardableResult
    func send<T: Codable>(showHUD: Bool, type: T.Type, success: @escaping ElementCallback<T>, failure: ErrorCallback?) -> Cancellable? {
        return RequestManager.shared.request(self, type: T.self, showHUD: showHUD, successHandler: success, failureHandler: failure)
    }
    
    @discardableResult
    func sendDictionary(_ showHUD: Bool = true, completion: @escaping DictionaryCallback, failure: ErrorCallback?) -> Cancellable? {
        RequestManager.shared.dictionaryRequest(self, showHUD: showHUD, success: completion, failure: failure)
    }
    
    @discardableResult
    func sendString(_ showHUD: Bool = true, completion: @escaping StringCallback, failure: ErrorCallback?) -> Cancellable? {
        RequestManager.shared.stringRequest(self, showHUD: showHUD, success: completion, failure: failure)
    }
}
