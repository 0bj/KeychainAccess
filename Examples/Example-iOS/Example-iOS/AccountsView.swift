//
//  AccountsView.swift
//  Example
//
//  Licensed under the MIT License. See LICENSE for details.
//

import SwiftUI
import KeychainAccess

struct Account: Identifiable {
    let service: String
    let key: String
    let value: String?

    var id: String { "\(service)/\(key)" }
}

struct AccountSection: Identifiable {
    let service: String
    let accounts: [Account]

    var id: String { service }
}

struct AccountsView: View {
    @State private var sections: [AccountSection] = []
    @State private var isAddingAccount = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(sections) { section in
                    Section(section.service) {
                        ForEach(section.accounts) { account in
                            LabeledContent(account.key, value: account.value ?? "")
                        }
                        .onDelete { offsets in
                            remove(offsets.map { section.accounts[$0] })
                        }
                    }
                }
            }
            .overlay {
                if sections.isEmpty {
                    Text("No items in the keychain")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Keychain Access")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingAccount = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingAccount, onDismiss: reload) {
                AddAccountView()
            }
            .onAppear(perform: reload)
        }
    }

    private func reload() {
        let accounts = Keychain.allItems(.genericPassword).compactMap { item -> Account? in
            guard let key = item["key"] as? String else {
                return nil
            }
            return Account(service: item["service"] as? String ?? "", key: key, value: item["value"] as? String)
        }
        sections = Dictionary(grouping: accounts, by: \.service)
            .map { AccountSection(service: $0.key, accounts: $0.value.sorted { $0.key < $1.key }) }
            .sorted { $0.service < $1.service }
    }

    private func remove(_ accounts: [Account]) {
        for account in accounts {
            Keychain(service: account.service)[account.key] = nil
        }
        reload()
    }
}
