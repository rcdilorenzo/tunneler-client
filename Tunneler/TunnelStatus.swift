//
//  TunnelStatus.swift
//  Tunneler
//
//  Created by Christian Di Lorenzo on 5/8/17.
//  Copyright © 2017 Christian Di Lorenzo. All rights reserved.
//

import Foundation
import UIKit

enum TunnelStatus: String {
    case Running = "Running"
    case Stopped = "Stopped"
    case InProgress = "In Progress"
    case Unknown = "Unknown"

    static func fromString(string: String) -> TunnelStatus {
        switch string {
        case "RUNNING":
            return .Running
        case "STOPPED":
            return .Stopped
        default:
            return .Unknown
        }
    }

    func imageRepresentation() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 30), false, 0)
        let rect = CGRect(x: 5, y: 5, width: 20, height: 20)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 10)
        fillColor.setFill()
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    private var fillColor: UIColor {
        switch self {
        case .Unknown:
            return .gray
        case .Running:
            return .green
        case .InProgress:
            return .blue
        case .Stopped:
            return .red
        }
    }
}
