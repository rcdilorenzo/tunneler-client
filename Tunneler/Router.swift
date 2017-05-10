//
//  Router.swift
//  Tunneler
//
//  Created by Christian Di Lorenzo on 5/8/17.
//  Copyright © 2017 Christian Di Lorenzo. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    case start()
    case stop()
    case status()

    var method: HTTPMethod {
        switch self {
        case .start:
            return .post
        case .stop:
            return .post
        case .status:
            return .get
        }
    }

    var path: String {
        switch self {
        case .start:
            return "/actions/start"
        case .stop:
            return "/actions/stop"
        case .status:
            return "/actions/status"
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try Store.shared.baseUrl.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        return urlRequest
    }
}
