//
//  SetupViewController.swift
//  Tunneler
//
//  Created by Christian Di Lorenzo on 5/9/17.
//  Copyright © 2017 Christian Di Lorenzo. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var serverField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!

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
        if isValidServerName(serverName) {
            errorMessage.text = ""
        } else {
            errorMessage.text = "Invalid server name."
        }
        return true
    }

    func isValidServerName(_ serverName: String) -> Bool {
        let expression = try? NSRegularExpression(pattern: "^https?\\:\\/\\/[\\w\\.]+$", options: .useUnicodeWordBoundaries)
        let range = NSRange(location: 0, length: (serverName as NSString).length)
        let matchCount = expression?.numberOfMatches(in: serverName, options: .reportCompletion, range: range)
        return (matchCount != nil && matchCount! > 0)
    }

    @IBAction func save(_ sender: Any) {
        guard isValidServerName(serverField.text ?? "")
            else { return errorMessage.text = "Invalid server name." }

        guard let username = usernameField.text
            else { return errorMessage.text = "Username required." }
        guard let password = passwordField.text
            else { return errorMessage.text = "Password required." }

        errorMessage.text = ""

        let tempStore = Store.shared.tempCopy()
        Store.shared.username = username
        Store.shared.password = password
        Store.shared.baseUrl = serverField.text!

        TunnelerAPI.loadStatus { (status, _port) in
            if status == .Running || status == .Stopped {
                self.setupIsComplete(animated: true)
            } else {
                Store.shared.updateFrom(tempStore)
                self.errorMessage.text = "Error: \(status.rawValue)"
            }
        }
    }

    func setupIsComplete(animated: Bool) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "root")
        self.present(controller, animated: animated, completion: nil)
    }
}
