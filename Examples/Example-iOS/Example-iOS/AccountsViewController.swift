//
//  AccountsViewController.swift
//  Example
//
//  Created by kishikawa katsumi on 2014/12/25.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import KeychainAccess

class AccountsViewController: UITableViewController {
    private var services: [String] = []
    private var itemsByService: [String: [[String: Any]]] = [:]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadData()
        tableView.reloadData()
    }

    // MARK:

    override func numberOfSections(in tableView: UITableView) -> Int {
        return services.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items(in: section).count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return services[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let item = items(in: indexPath.section)[indexPath.row]
        cell.textLabel?.text = item["key"] as? String
        cell.detailTextLabel?.text = item["value"] as? String

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let service = services[indexPath.section]
        let items = items(in: indexPath.section)
        guard let key = items[indexPath.row]["key"] as? String else {
            return
        }

        Keychain(service: service)[key] = nil
        reloadData()

        if items.count == 1 {
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
        } else {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // MARK:

    private func items(in section: Int) -> [[String: Any]] {
        return itemsByService[services[section]] ?? []
    }

    private func reloadData() {
        let items = Keychain.allItems(.genericPassword)
        itemsByService = Dictionary(grouping: items) { $0["service"] as? String ?? "" }
        services = itemsByService.keys.sorted()
    }
}
