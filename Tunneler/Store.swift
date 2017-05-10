//
//  Store.swift
//  Tunneler
//
//  Created by Christian Di Lorenzo on 5/9/17.
//  Copyright © 2017 Christian Di Lorenzo. All rights reserved.
//

import Foundation
import WatchConnectivity

protocol StoreListener: NSObjectProtocol {
    func storeUpdated(store: Store, key: String, rawValue: Any)
}

class Store {
    static var shared = Store(backingStore: .standard)

    private var middleBacking = Dictionary<String, Any>()
    private var backingStore: UserDefaults?
    private var listeners = [StoreListener]()

    var status: TunnelStatus {
        get {
            let value: String = valueForKey("store.status", defaultValue: "")
            guard let status = TunnelStatus(rawValue: value)
                else { return .Unknown }

            return status
        }
        set(status) {
            setValue(value: status.rawValue, forKey: "store.status")
        }
    }

    var baseUrl: String {
        get { return valueForKey("store.base-url", defaultValue: "") }
        set(baseUrl) { setValue(value: baseUrl, forKey: "store.base-url") }
    }

    init(backingStore: UserDefaults?) {
        self.backingStore = backingStore
    }

    func addListener(target: StoreListener) {
        listeners.append(target)
    }

    func removeListener(_ target: StoreListener) {
        listeners = listeners.filter { $0.isEqual(target) }
    }

    func updateFromUserInfoTransfer(userInfo: [String: Any]) {
        for key in userInfo.keys {
            setValueOnly(value: userInfo[key], forKey: key)
        }
    }

    private func setValue<T>(value: T, forKey key: String) {
        setValueOnly(value: value, forKey: key)
        for listener in listeners {
            listener.storeUpdated(store: self, key: key, rawValue: value)
        }
        WCSession.default().transferUserInfo(["Store": [key: value]])
    }

    private func setValueOnly<T>(value: T, forKey key: String) {
        middleBacking[key] = value
        backingStore?.set(value, forKey: key)
        self.backingStore?.synchronize()
    }

    private func valueForKey<T>(_ key: String, defaultValue: T) -> T {
        guard let backingValue = backingStore?.value(forKey: key) as? T else {
            guard let middleValue = middleBacking[key] as? T
                else { return defaultValue }
            return middleValue
        }

        return backingValue
    }
}
