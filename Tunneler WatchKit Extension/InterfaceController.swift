//
//  InterfaceController.swift
//  Tunneler WatchKit Extension
//
//  Created by Christian Di Lorenzo on 5/6/17.
//  Copyright © 2017 Christian Di Lorenzo. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet var statusImage: WKInterfaceImage!
    @IBOutlet var statusText: WKInterfaceLabel!
    @IBOutlet var toggleButton: WKInterfaceButton!

    var status: TunnelStatus {
        get { return Store.shared.status }
        set(status) {
            statusImage.setImage(status.imageRepresentation())
            statusText.setText(status.rawValue)
            setActionButtonTitle(status: status)
            Store.shared.status = status
        }
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        status = Store.shared.status
        TunnelerAPI.loadStatus { self.status = $0 }
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
        self.status = .InProgress
        TunnelerAPI.startTunnel { self.status = $0 }
    }

    func stopTunnel() {
        self.status = .InProgress
        TunnelerAPI.stopTunnel { self.status = $0 }
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
        TunnelerAPI.loadStatus { self.status = $0 }
    }
}
