//
//  InputViewController.swift
//  Example
//
//  Licensed under the MIT License. See LICENSE for details.
//

import UIKit
import KeychainAccess

class InputViewController: UITableViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var serviceField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 44.0
        tableView.estimatedRowHeight = 44.0
    }

    // MARK:

    @IBAction func cancelAction(sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction func saveAction(sender: UIBarButtonItem) {
        let keychain: Keychain
        if let service = serviceField.text, !service.isEmpty {
            keychain = Keychain(service: service)
        } else {
            keychain = Keychain()
        }
        if let username = usernameField.text {
            keychain[username] = passwordField.text
        }

        dismiss(animated: true)
    }

    @IBAction func editingChanged(sender: UITextField) {
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        saveButton.isEnabled = !username.isEmpty && !password.isEmpty
    }
}
