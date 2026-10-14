//
//  AddAccountView.swift
//  Example
//
//  Licensed under the MIT License. See LICENSE for details.
//

import SwiftUI
import KeychainAccess

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var password = ""
    @State private var service = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Username", text: $username)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Password", text: $password)
                    .textContentType(.password)
                TextField("Service", text: $service, prompt: Text(Bundle.main.bundleIdentifier ?? "Service"))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(username.isEmpty || password.isEmpty)
                }
            }
        }
    }

    private func save() {
        let keychain = service.isEmpty ? Keychain() : Keychain(service: service)
        keychain[username] = password
        dismiss()
    }
}
