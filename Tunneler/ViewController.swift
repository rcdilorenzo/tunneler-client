//
//  ViewController.swift
//  Tunneler
//
//  Created by Christian Di Lorenzo on 5/6/17.
//  Copyright © 2017 Christian Di Lorenzo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, StoreListener {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!

    let redColor = UIColor(red:0.64, green:0.28, blue:0.30, alpha:1.00)
    let greenColor = UIColor(red:0.11, green:0.57, blue:0.09, alpha:1.00)
    let blueColor = UIColor(red:0.08, green:0.49, blue:0.98, alpha:1.00)

    var status = TunnelStatus.Unknown {
        didSet {
            Store.shared.status = status
            updateStatusLabel()
            switch status {
            case .Unknown:
                view.backgroundColor = .lightGray
                actionButton.setTitle("Start", for: .normal)
                actionButton.setTitleColor(greenColor, for: .normal)
                actionButton.isEnabled = false
                break;
            case .Unauthorized:
                view.backgroundColor = redColor
                actionButton.setTitle("Start", for: .normal)
                actionButton.setTitleColor(greenColor, for: .normal)
                actionButton.isEnabled = false
                break;
            case .InProgress:
                view.backgroundColor = blueColor
                actionButton.setTitle("Loading...", for: .normal)
                actionButton.setTitleColor(blueColor, for: .normal)
                actionButton.isEnabled = false
                break;
            case .Stopped:
                view.backgroundColor = redColor
                actionButton.setTitle("Start", for: .normal)
                actionButton.setTitleColor(greenColor, for: .normal)
                actionButton.isEnabled = true
                break;
            case .Running:
                view.backgroundColor = greenColor
                actionButton.setTitle("Stop", for: .normal)
                actionButton.setTitleColor(redColor, for: .normal)
                actionButton.isEnabled = true
                break;
            }
        }
    }

    var port: Int {
        get { return Store.shared.port }
        set(port) {
            Store.shared.port = port
            updateStatusLabel()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        status = Store.shared.status
        Store.shared.addListener(target: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TunnelerAPI.loadStatus(completion: updateStatus(status:port:))
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func updateStatus(status: TunnelStatus, port: Int) {
        self.status = status
        self.port = port
    }

    func updateStatusLabel() {
        guard port != 0
            else { return statusLabel.text = status.rawValue }

        statusLabel.text = "\(status.rawValue) on \(port)"
    }

    @IBAction func logout(_ sender: Any) {
        Store.shared.logout()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func performAction(_ sender: Any) {
        switch status {
        case .Stopped:
            status = .InProgress
            port = 0
            TunnelerAPI.startTunnel { self.status = $0 }
            break;
        case .Running:
            status = .InProgress
            port = 0
            TunnelerAPI.stopTunnel { self.status = $0 }
            break;
        default:
            break;
        }
    }

    @IBAction func refresh(_ sender: Any) {
        status = .InProgress
        port = 0
        TunnelerAPI.loadStatus(completion: updateStatus(status:port:))
    }

    func storeUpdated(store: Store, key: String, rawValue: Any) {
        if key == "store.status" && status != store.status {
            status = store.status
        } else if key == "store.port" && port != store.port {
            port = store.port
        }
    }
}

