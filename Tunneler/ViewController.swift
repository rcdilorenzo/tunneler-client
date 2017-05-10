//
//  ViewController.swift
//  Tunneler
//
//  Created by Christian Di Lorenzo on 5/6/17.
//  Copyright © 2017 Christian Di Lorenzo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!

    let redColor = UIColor(red:0.64, green:0.28, blue:0.30, alpha:1.00)
    let greenColor = UIColor(red:0.11, green:0.57, blue:0.09, alpha:1.00)
    let blueColor = UIColor(red:0.08, green:0.49, blue:0.98, alpha:1.00)

    var status = TunnelStatus.Unknown {
        didSet {
            Store.shared.status = status
            statusLabel.text = status.rawValue
            switch status {
            case .Unknown:
                view.backgroundColor = .lightGray
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

    override func viewDidLoad() {
        super.viewDidLoad()
        status = Store.shared.status
        UIApplication.shared.statusBarStyle = .lightContent
    }

    @IBAction func performAction(_ sender: Any) {
        switch status {
        case .Stopped:
            status = .InProgress
            TunnelerAPI.startTunnel { self.status = $0 }
            break;
        case .Running:
            status = .InProgress
            TunnelerAPI.stopTunnel { self.status = $0 }
            break;
        default:
            break;
        }
    }

    @IBAction func refresh(_ sender: Any) {
        status = .InProgress
        TunnelerAPI.loadStatus { self.status = $0 }
    }
}

