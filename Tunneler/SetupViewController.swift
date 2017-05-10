//
//  SetupViewController.swift
//  Tunneler
//
//  Created by Christian Di Lorenzo on 5/9/17.
//  Copyright © 2017 Christian Di Lorenzo. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var serverField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    var valid = false {
        didSet {
            errorMessage.text = valid ? "" : "Invalid server name."
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        serverField.delegate = self
        UIApplication.shared.statusBarStyle = .default
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !Store.shared.baseUrl.isEmpty {
            setupIsComplete(animated: false)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let serverName = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        let expression = try? NSRegularExpression(pattern: "^https?\\:\\/\\/[\\w\\.]+$", options: .useUnicodeWordBoundaries)
        let range = NSRange(location: 0, length: (serverName as NSString).length)
        let matchCount = expression?.numberOfMatches(in: serverName, options: .reportCompletion, range: range)
        valid = (matchCount != nil && matchCount! > 0)
        return true
    }

    @IBAction func save(_ sender: Any) {
        guard valid else { return }
        verifyServer {
            Store.shared.baseUrl = self.serverField.text!
            self.setupIsComplete(animated: true)
        }
    }

    func setupIsComplete(animated: Bool) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "root")
        self.present(controller, animated: animated, completion: nil)
    }

    func verifyServer(success: @escaping () -> ()) {
        let baseUrl = Store.shared.baseUrl
        Store.shared.baseUrl = serverField.text!
        TunnelerAPI.loadStatus { (status) in
            Store.shared.baseUrl = baseUrl
            if status == .Running || status == .Stopped {
                success()
            } else {
                self.valid = false
            }
        }
    }
}
