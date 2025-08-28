//
//  NetworkService.swift
//  siren
//
//  Created by danqin chu on 2020/3/16.
//  Copyright © 2020 danqin chu. All rights reserved.
//

import Foundation
import Alamofire
import SmartCodable

typealias APIModel = SmartCodable

struct AnyAPIModel: APIModel {
}

extension Encodable {
    var JSON: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

extension AFDataResponse {
    var mError: Error {
        if let e = error {
            return e
        }
        return MErrorCode.error(rawCode: response?.statusCode ?? MErrorCode.response.rawValue, userInfo: data.map {
            return ["msg": String(data: $0, encoding: .utf8) as Any]
        })
    }
}

struct Response<D: APIModel>: SmartCodable {
//    var result: String = ""
    var status: Int?
    var success: Bool = false
    var message: String = ""
    var data: D?
    
    var mError: Error {
        return MErrorCode.error(rawCode: MErrorCode.response.rawValue, userInfo: ["msg": message, "result": "\(success)"])
    }
    
    var isSuccessful: Bool {
        return success
    }
    
    static func parse(from data: Data) -> Response? {
        return Response.deserialize(from: data)
    }
}

enum MErrorCode: Int {
    case response = -1
    case parameter = -2
    case auth = -3
    
    static let DOMAIN = "foo.bar"
    
    static func parameterError(_ params: Parameters...) -> Error {
        var i = 0
        var userInfo = Dictionary<String, Parameters>()
        for p in params {
            userInfo["\(i)"] = p
            i = i + 1
        }
        return error(rawCode: MErrorCode.parameter.rawValue, userInfo: userInfo)
    }
    
    static func error(rawCode: Int, userInfo: [String: Any]?) -> Error {
        return NSError(domain: DOMAIN, code: rawCode, userInfo: userInfo)
    }
    
}

struct NetworkService {
    
    typealias Success<T> = (T?) -> Void
    
    typealias Failure = (Error) -> Void
    
    static var login = Login.lastLogin()
    
    static var authErrorHandler: ((Error) -> Void)?
    
    private static func handle<T: APIModel>(resp: AFDataResponse<Data>, success: Success<T>?, failure: Failure?) {
        switch resp.result {
        case .success(let data):
            if let r = Response<T>.parse(from: data) {
                if r.isSuccessful {
                    success?(r.data)
                } else {
                    failure?(r.mError)
                }
            }
        case .failure(let error):
            failure?(error)
        }
//        if let value = resp.value as? Parameters, let r = Response<T>.parse(from: value) {
//            if r.isSuccessful {
//                success?(r.data)
//            } else {
//                failure?(r.mError)
//            }
//        } else {
//            failure?(resp.mError)
//        }
    }
    
    private static func start<T: SmartCodable>(request: Request, success: Success<T>?, failure: Failure?) {
        guard login.isValid else {
            let error = MErrorCode.error(rawCode: MErrorCode.auth.rawValue, userInfo: nil)
            DispatchQueue.main.async {
                authErrorHandler?(error)
            }
            return
        }
        AF.request(request).responseData { (resp) in
            handle(resp: resp, success: success, failure: failure)
        }
    }
    
    static func queryOrders(success: Success<[PayInfo]>?, failure: Failure?) {
        let req = Request.def(path: "/api/orders")
        start(request: req, success: success, failure: failure)
    }
    
    static func updateOrder(with orderId: String, status: PayInfo.OrderStatus, success: Success<AnyAPIModel>?, failure: Failure?) {
        var req = Request.def(path: "/api/order/status")
        req.method = .post
        req.queryEncoding = JSONEncoding.default
        req.queryParams = ["order_id": orderId, "status": status.rawValue]
        start(request: req, success: success, failure: failure)
    }
    
    static func getFoobar(completion: @escaping (AFDataResponse<Data?>?) -> Void) {
        AF.request(URL(string: "https://jsj.top/f/VXex16")!).response { (resp) in
            completion(resp)
        }
    }
    
}

extension NetworkService {
    
    struct Request: URLRequestConvertible {
        
        private static let BASE_URL = URL(string: "http://119.91.70.141:5000")!
    
        static func def(path: String) -> Request {
            let url = BASE_URL.appendingPathComponent(path)
            return Request(url: url, auth: NetworkService.login)
        }
        
        let url: URL
        
        let auth: Login
        
        var method: HTTPMethod = .get
        
        var httpHeaders: [String: String]? = nil
        
        var queryParams: Parameters? = nil
        
        var queryEncoding: ParameterEncoding = URLEncoding.default
        
        var bodyParams: Parameters? = nil
        
        var bodyEncoding: ParameterEncoding = JSONEncoding.default
        
        func asURLRequest() throws -> URLRequest {
            var request = URLRequest(url: url)
            request.method = method
            httpHeaders?.forEach({ (key, value) in
                request.addValue(value, forHTTPHeaderField: key)
            })
            request.addValue("application/json", forHTTPHeaderField: "accept")
            var params = queryParams ?? [:]
            if let JSON = auth.toJSON() {
                params.merge(JSON) { (v0, v1) -> Any in
                    return v0
                }
            }
            request = try queryEncoding.encode(request, with: params)
            return try bodyEncoding.encode(request, with: bodyParams)
        }
        
    }
    
}
