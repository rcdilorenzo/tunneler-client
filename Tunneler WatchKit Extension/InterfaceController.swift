//
//  InterfaceController.swift
//  Tunneler WatchKit Extension
//
//  Created by Christian Di Lorenzo on 5/6/17.
//  Copyright © 2017 Christian Di Lorenzo. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, StoreListener {
    @IBOutlet var statusImage: WKInterfaceImage!
    @IBOutlet var statusText: WKInterfaceLabel!
    @IBOutlet var toggleButton: WKInterfaceButton!

    var status: TunnelStatus {
        get { return Store.shared.status }
        set(status) {
            Store.shared.status = status
            statusImage.setImage(status.imageRepresentation())
            updateStatusLabel()
            setActionButtonTitle(status: status)
        }
    }

    var port: Int {
        get { return Store.shared.port }
        set(port) {
            Store.shared.port = port
            updateStatusLabel()
        }
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        status = Store.shared.status
        TunnelerAPI.loadStatus(completion: updateStatus(status:port:))
        Store.shared.addListener(target: self)
    }

    override func willDisappear() {
        super.willDisappear()
        Store.shared.removeListener(self)
    }

    func updateStatus(status: TunnelStatus, port: Int) {
        self.status = status
        self.port = port
    }

    func updateStatusLabel() {
        guard port != 0
            else { return statusText.setText(status.rawValue) }

        statusText.setText("\(status.rawValue) on \(port)")
    }

    func setActionButtonTitle(status: TunnelStatus) {
        switch status {
        case .Running:
            toggleButton.setTitle("Stop")
            toggleButton.setEnabled(true)
        case .Stopped:
            toggleButton.setTitle("Start")
            toggleButton.setEnabled(true)
        case .InProgress:
            toggleButton.setEnabled(false)
        default:
            toggleButton.setTitle("Start")
            toggleButton.setEnabled(false)
        }
    }

    func startTunnel() {
        status = .InProgress
        port = 0
        TunnelerAPI.startTunnel { self.status = $0 }
    }

    func stopTunnel() {
        status = .InProgress
        port = 0
        TunnelerAPI.stopTunnel { self.status = $0; self.port = 0 }
    }

    @IBAction func toggleTapped() {
        switch status {
        case .Running:
            stopTunnel()
        case .Stopped:
            startTunnel()
        default:
            break;
        }
    }

    @IBAction func refreshTapped() {
        TunnelerAPI.loadStatus(completion: updateStatus(status:port:))
    }

    func storeUpdated(store: Store, key: String, rawValue: Any) {
        if status != store.status {
            status = store.status
        }
        if key == "store.base-url" {
            refreshTapped()
        }
    }
}
