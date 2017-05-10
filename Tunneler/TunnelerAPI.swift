//
//  TunnelerAPI.swift
//  Tunneler
//
//  Created by Christian Di Lorenzo on 5/6/17.
//  Copyright © 2017 Christian Di Lorenzo. All rights reserved.
//

import Foundation
import Alamofire
import Unbox
import SwiftyJSON

typealias FailureBlock = ((String) -> ())?
typealias EmptyBlock = () -> ()

enum HTTPStatusCode: Int {
    case ok = 200
}

enum HTTPError: String {
    case Serialize = "The model could not be serialized from json"
    case BadRequest = "The body of the request was not properly formed"
    case Unauthorized = "The user is not authenticated"
    case Unknown = "An unknown error occurred with the request"
}

class TunnelerAPI {
    static func loadStatus(completion: @escaping (TunnelStatus) -> ()) {
        sendRequest(Router.status(), successCode: .ok, failure: { (_error) in
            completion(.Unknown)
        }, success: { json in
            completion(TunnelStatus.fromString(string: json["status"].stringValue))
        })
    }

    static func startTunnel(completion: @escaping (TunnelStatus) -> ()) {
        sendRequest(Router.start(), successCode: .ok, failure: { (_error) in
            completion(.Unknown)
        }, success: { json in
            completion(.Running)
        })
    }

    static func stopTunnel(completion: @escaping (TunnelStatus) -> ()) {
        sendRequest(Router.stop(), successCode: .ok, failure: { (_error) in
            completion(.Unknown)
        }, success: { json in
            completion(.Stopped)
        })
    }

    fileprivate static func sendRequest(_ request: Router, successCode: HTTPStatusCode, failure: FailureBlock, success: @escaping (JSON) -> ()) {
        try? print("Sending request: \(request.asURLRequest())")
        Alamofire.request(request).responseJSON { (response) -> Void in
            if let objectResponse = response.result.value {
                let json = JSON(objectResponse)
                return self.handleStatusCodes(json,
                                              statusCode: response.response!.statusCode,
                                              successCode: successCode.rawValue,
                                              failure: failure,
                                              success: success)
            }

            guard let data = response.data
                else { return self.failedWithError(failure, error: .Unknown, caughtError: nil) }

            guard let httpResponse = response.response
                else { return self.failedWithError(failure, error: .Unknown, caughtError: nil) }

            let response = NSString(data: data, encoding: String.Encoding.utf8.rawValue) ?? "<unknown>"
            print("Status Code: \(httpResponse.statusCode), response: \(response)")
            self.failedWithError(failure, error: .Unknown, caughtError: nil)
        }
    }

    fileprivate static func handleStatusCodes(_ json: JSON, statusCode: Int, successCode: Int, failure: FailureBlock, success: (JSON) -> ()) {
        switch statusCode {
        case successCode:
            success(json)
        case 400:
            print(json)
            self.failedWithError(failure, error: .BadRequest, caughtError: nil)
        case 401:
            self.failedWithError(failure, error: .Unauthorized, caughtError: nil)
        default:
            self.failedWithError(failure, error: .Unknown, caughtError: nil)
        }
    }

    fileprivate static func failedWithError(_ failure: ((String) -> ())?, error: HTTPError, caughtError: Error?) {
        if let thrownError = caughtError {
            print("Caught Error: \(thrownError)")
        }
        self.callFailure(failure, message: error.rawValue)
    }

    fileprivate static func callFailure(_ failure: ((String) -> ())?, message: String) {
        print("Request failure: \(message)")
        if let failureBlock = failure {
            failureBlock(message)
        }
    }
}
