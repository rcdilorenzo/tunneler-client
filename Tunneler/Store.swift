//
//  Store.swift
//  Tunneler
//
//  Created by Christian Di Lorenzo on 5/9/17.
//  Copyright © 2017 Christian Di Lorenzo. All rights reserved.
//

import Foundation
import WatchConnectivity
import KeychainSwift

protocol StoreListener: NSObjectProtocol {
    func storeUpdated(store: Store, key: String, rawValue: Any)
}

class Store {
    static var shared = Store(backingStore: .standard)

    private var middleBacking = Dictionary<String, Any>()
    private var backingStore: UserDefaults?
    private var listeners = [StoreListener]()
    private var keychain = KeychainSwift()

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

    func updateFromSecureUserInfoTransfer(userInfo: [String: Any]) {
        for key in userInfo.keys {
            guard let value = userInfo[key] as? String
                else { continue }
            setSecureValueOnly(value: value, forKey: key)
        }
    }

    fileprivate func setSecureValue(value: String, forKey key: String) {
        setSecureValueOnly(value: value, forKey: key)
        for listener in listeners {
            listener.storeUpdated(store: self, key: key, rawValue: value)
        }
        WCSession.default.transferUserInfo(["SecureStore": [key: value]])
    }

    fileprivate func setSecureValueOnly(value: String, forKey key: String) {
        keychain.set(value, forKey: key)
    }

    fileprivate func setValue<T>(value: T, forKey key: String) {
        setValueOnly(value: value, forKey: key)
        for listener in listeners {
            listener.storeUpdated(store: self, key: key, rawValue: value)
        }
        WCSession.default.transferUserInfo(["Store": [key: value]])
    }

    fileprivate func setValueOnly<T>(value: T, forKey key: String) {
        middleBacking[key] = value
        backingStore?.set(value, forKey: key)
        self.backingStore?.synchronize()
    }

    fileprivate func secureValueForKey(_ key: String, defaultValue: String) -> String {
        guard let backingValue = keychain.get(key)
            else { return defaultValue }

        return backingValue
    }

    fileprivate func valueForKey<T>(_ key: String, defaultValue: T) -> T {
        guard let backingValue = backingStore?.value(forKey: key) as? T else {
            guard let middleValue = middleBacking[key] as? T
                else { return defaultValue }
            return middleValue
        }

        return backingValue
    }
}

extension Store {
    var canAuthenticate: Bool {
        return !baseUrl.isEmpty && !username.isEmpty && !password.isEmpty
    }

    func logout() {
        username = ""
        password = ""
        broadcastCredentials()
    }

    func broadcastCredentials() {
        setValue(value: baseUrl, forKey: "store.base-url")
        setValue(value: username, forKey: "store.username")
        setSecureValue(value: password, forKey: "store.password")
    }
    
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

    var username: String {
        get { return valueForKey("store.username", defaultValue: "") }
        set(username) { setValue(value: username, forKey: "store.username") }
    }

    var password: String {
        get { return secureValueForKey("store.password", defaultValue: "") }
        set(password) { setSecureValue(value: password, forKey: "store.password") }
    }

    var port: Int {
        get { return valueForKey("store.port", defaultValue: 0) }
        set(username) { setValue(value: username, forKey: "store.port") }
    }

    func tempCopy() -> Store {
        let store = Store(backingStore: nil)
        store.username = username
        store.password = password
        store.baseUrl = baseUrl
        store.status = status
        store.port = port
        return store
    }

    func updateFrom(_ store: Store) {
        username = store.username
        password = store.password
        baseUrl = store.baseUrl
        status = store.status
        port = store.port
    }
}
