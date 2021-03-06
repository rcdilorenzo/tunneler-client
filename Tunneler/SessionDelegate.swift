//
//  SessionDelegate.swift
//  Tunneler
//
//  Created by Christian Di Lorenzo on 5/10/17.
//  Copyright © 2017 Christian Di Lorenzo. All rights reserved.
//

import UIKit
import WatchConnectivity

class SessionDelegate: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let storeInfo = userInfo["Store"] as? [String: Any] {
            Store.shared.updateFromUserInfoTransfer(userInfo: storeInfo)
        }
        if let storeInfo = userInfo["SecureStore"] as? [String: Any] {
            Store.shared.updateFromSecureUserInfoTransfer(userInfo: storeInfo)
        }
    }
}
