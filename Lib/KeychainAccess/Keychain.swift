//
//  Keychain.swift
//  KeychainAccess
//
//  Licensed under the MIT License. See LICENSE for details.
//

public import Foundation
import Security
import os
#if os(iOS) || os(macOS)
public import LocalAuthentication
#endif

private let logger = Logger(subsystem: "io.github.0bj.KeychainAccess", category: "Keychain")

// Immutable: every modifier returns a new instance, and SecItem APIs are thread-safe.
/// A keychain of generic or internet passwords.
///
/// Configure it with the fluent modifiers (`accessibility(_:)`, `synchronizable(_:)`, `label(_:)`, ...);
/// each returns a new `Keychain`.
public final class Keychain: @unchecked Sendable {
  private var cf: CFStringWrap { .shared }

  public var itemClass: ItemClass {
    options.itemClass
  }

  public var service: String {
    options.service
  }

  // This attribute (kSecAttrAccessGroup) applies to macOS keychain items only if you also set a value of true for the
  // kSecUseDataProtectionKeychain key, the kSecAttrSynchronizable key, or both.
  public var accessGroup: String? {
    options.accessGroup
  }

  /// The server URL of an internet password keychain, `nil` for a generic password keychain.
  public var server: URL? {
    options.server
  }

  /// The protocol of an internet password keychain, `nil` for a generic password keychain.
  public var protocolType: ProtocolType? {
    options.protocolType
  }

  public var authenticationType: AuthenticationType {
    options.authenticationType
  }

  public var accessibility: Accessibility {
    options.accessibility
  }

  public var authenticationPolicy: AuthenticationPolicy? {
    options.authenticationPolicy
  }

  public var synchronizable: Bool {
    options.synchronizable
  }

  public var label: String? {
    options.label
  }

  public var comment: String? {
    options.comment
  }

#if os(iOS) || os(macOS)
  public var authenticationContext: LAContext? {
    options.authenticationContext
  }
#endif

  fileprivate let options: Options

  // MARK: - Initializers

  /// Generic password keychain whose service is the main bundle identifier.
  public convenience init() {
    var options = Options()
    if let bundleIdentifier = Bundle.main.bundleIdentifier {
      options.service = bundleIdentifier
    }
    self.init(options)
  }

  /// Generic password keychain for the main bundle identifier, shared through `accessGroup`.
  public convenience init(accessGroup: String) {
    var options = Options()
    if let bundleIdentifier = Bundle.main.bundleIdentifier {
      options.service = bundleIdentifier
    }
    options.accessGroup = accessGroup
    self.init(options)
  }

  /// Generic password keychain for `service`, optionally shared through `accessGroup`.
  public convenience init(service: String, accessGroup: String? = nil) {
    var options = Options()
    options.service = service
    options.accessGroup = accessGroup
    self.init(options)
  }

  /// Internet password keychain for `server`.
  ///
  /// - Precondition: `server` is a valid URL string.
  public convenience init(server: String, protocolType: ProtocolType, accessGroup: String? = nil, authenticationType: AuthenticationType = .default) {
    guard let url = URL(string: server) else {
      preconditionFailure("Invalid server URL: \(server)")
    }
    self.init(server: url, protocolType: protocolType, accessGroup: accessGroup, authenticationType: authenticationType)
  }

  /// Internet password keychain for `server`.
  public convenience init(server: URL, protocolType: ProtocolType, accessGroup: String? = nil, authenticationType: AuthenticationType = .default) {
    var options = Options()
    options.itemClass = .internetPassword
    options.server = server
    options.protocolType = protocolType
    options.accessGroup = accessGroup
    options.authenticationType = authenticationType
    self.init(options)
  }

  fileprivate init(_ opts: Options) {
    options = opts
  }

  private func with(_ change: (inout Options) -> Void) -> Keychain {
    var options = self.options
    change(&options)
    return Keychain(options)
  }

  // MARK: - Configuration

  /// Returns a keychain that stores items with `accessibility`.
  public func accessibility(_ accessibility: Accessibility) -> Keychain {
    with { options in
      options.accessibility = accessibility
    }
  }

  /// Returns a keychain that protects stored items with `authenticationPolicy` (e.g. biometry or passcode).
  public func accessibility(_ accessibility: Accessibility, authenticationPolicy: AuthenticationPolicy) -> Keychain {
    with { options in
      options.accessibility = accessibility
      options.authenticationPolicy = authenticationPolicy
    }
  }

  /// Returns a keychain whose stored items are (or are not) synchronized through iCloud Keychain.
  public func synchronizable(_ synchronizable: Bool) -> Keychain {
    with { options in
      options.synchronizable = synchronizable
    }
  }

  /// Returns a keychain that sets `label` on stored items.
  public func label(_ label: String) -> Keychain {
    with { options in
      options.label = label
    }
  }

  /// Returns a keychain that sets `comment` on stored items.
  public func comment(_ comment: String) -> Keychain {
    with { options in
      options.comment = comment
    }
  }

  /// Returns a keychain that adds raw Security framework `attributes` to stored items.
  public func attributes(_ attributes: [String: Any]) -> Keychain {
    with { options in
      attributes.forEach { options.attributes.updateValue($1, forKey: $0) }
    }
  }

#if os(iOS) || os(macOS)
  /// Returns a keychain that authenticates protected items with `authenticationContext`.
  ///
  /// Set `LAContext.localizedReason` to customize the authentication prompt.
  public func authenticationContext(_ authenticationContext: LAContext) -> Keychain {
    with { options in
      options.authenticationContext = authenticationContext
    }
  }
#endif

  // MARK: - Reading

  /// Returns the string stored for `key`, or `nil` if there is none.
  ///
  /// - Parameter ignoringAttributeSynchronizable: When `true`, matches both synchronizable and local items;
  ///   otherwise only items matching `synchronizable`.
  public func get(_ key: String, ignoringAttributeSynchronizable: Bool = true) throws -> String? {
    try getString(key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
  }

  /// Returns the UTF-8 string stored for `key`, or `nil` if there is none.
  ///
  /// - Throws: `Status.conversionError` if the stored data isn't UTF-8.
  public func getString(_ key: String, ignoringAttributeSynchronizable: Bool = true) throws -> String? {
    guard let data = try getData(key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable) else {
      return nil
    }
    guard let string = String(data: data, encoding: .utf8) else {
      throw Status.conversionError
    }
    return string
  }

  /// Returns the data stored for `key`, or `nil` if there is none.
  public func getData(_ key: String, ignoringAttributeSynchronizable: Bool = true) throws -> Data? {
    var query = itemQuery(key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
    query[cf.MatchLimit] = cf.MatchLimitOne
    query[cf.ReturnData] = kCFBooleanTrue

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)

    switch status {
    case errSecSuccess:
      guard let data = result as? Data else {
        throw Status.unexpectedError
      }
      return data
    case errSecItemNotFound:
      return nil
    default:
      throw securityError(status: status)
    }
  }

  /// Reads the item for `key` with all its attributes and returns `handler`'s result (`nil` attributes if there is no item).
  public func get<T>(_ key: String, ignoringAttributeSynchronizable: Bool = true, handler: (Attributes?) -> T) throws -> T {
    var query = itemQuery(key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
    query[cf.MatchLimit] = cf.MatchLimitOne
    query[cf.ReturnData] = kCFBooleanTrue
    query[cf.ReturnAttributes] = kCFBooleanTrue
    query[cf.ReturnRef] = kCFBooleanTrue
    query[cf.ReturnPersistentRef] = kCFBooleanTrue

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)

    switch status {
    case errSecSuccess:
      guard let attributes = result as? [String: Any] else {
        throw Status.unexpectedError
      }
      return handler(Attributes(attributes: attributes))
    case errSecItemNotFound:
      return handler(nil)
    default:
      throw securityError(status: status)
    }
  }

  // MARK: - Writing

  /// Stores `value` as UTF-8 for `key`, adding or updating the item.
  public func set(_ value: String, key: String, ignoringAttributeSynchronizable: Bool = true) throws {
    guard let data = value.data(using: .utf8, allowLossyConversion: false) else {
      throw Status.conversionError
    }
    try set(data, key: key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
  }

  /// Stores `value` for `key`, adding or updating the item.
  public func set(_ value: Data, key: String, ignoringAttributeSynchronizable: Bool = true) throws {
    let query = itemQuery(key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)

    let status = SecItemCopyMatching(query as CFDictionary, nil)
    switch status {
    case errSecSuccess, errSecInteractionNotAllowed:
      let attributes = try options.attributes(key: nil, value: value)
      try check(SecItemUpdate(query as CFDictionary, attributes as CFDictionary))
    case errSecItemNotFound:
      let attributes = try options.attributes(key: key, value: value)
      try check(SecItemAdd(attributes as CFDictionary, nil))
    default:
      throw securityError(status: status)
    }
  }

  /// The string stored for `key`. Assigning `nil` removes the item. Errors are ignored; use `get`/`set` to handle them.
  public subscript(key: String) -> String? {
    get {
      try? get(key)
    }

    set {
      if let newValue {
        try? set(newValue, key: key)
      } else {
        try? remove(key)
      }
    }
  }

  /// The string stored for `key`. Same as `subscript(_:)`.
  public subscript(string key: String) -> String? {
    get {
      self[key]
    }

    set {
      self[key] = newValue
    }
  }

  /// The data stored for `key`. Assigning `nil` removes the item. Errors are ignored.
  public subscript(data key: String) -> Data? {
    get {
      try? getData(key)
    }

    set {
      if let newValue {
        try? set(newValue, key: key)
      } else {
        try? remove(key)
      }
    }
  }

  /// The attributes of the item for `key`, or `nil` if there is none or reading failed.
  public subscript(attributes key: String) -> Attributes? {
    get {
      try? get(key) { $0 }
    }
  }

  // MARK: - Removing

  /// Removes the item for `key`. Does nothing if there is none.
  public func remove(_ key: String, ignoringAttributeSynchronizable: Bool = true) throws {
    let query = itemQuery(key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)

    let status = SecItemDelete(query as CFDictionary)
    if status != errSecSuccess && status != errSecItemNotFound {
      throw securityError(status: status)
    }
  }

  /// Removes all items of this keychain's service (or server).
  public func removeAll() throws {
    var query = options.query()
#if !os(iOS) && !os(watchOS) && !os(tvOS)
    query[cf.MatchLimit] = cf.MatchLimitAll
#endif

    let status = SecItemDelete(query as CFDictionary)
    if status != errSecSuccess && status != errSecItemNotFound {
      throw securityError(status: status)
    }
  }

  // MARK: - Querying

  /// Returns whether an item exists for `key`.
  ///
  /// Throws `Status.interactionNotAllowed` when the keychain can't be queried right now
  /// (for example, the device is locked), instead of reporting the item as missing.
  public func contains(_ key: String, ignoringAttributeSynchronizable: Bool = true) throws -> Bool {
    let query = itemQuery(key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)

    let status = SecItemCopyMatching(query as CFDictionary, nil)
    switch status {
    case errSecSuccess:
      return true
    case errSecItemNotFound:
      return false
    default:
      throw securityError(status: status)
    }
  }

  // MARK: - Listing

  /// Returns `(service or server, key)` pairs of all items of `itemClass` the app can access.
  public class func allKeys(_ itemClass: ItemClass) -> [(String, String)] {
    let cf = CFStringWrap.shared
    var query = [String: Any]()
    query[cf.Class] = itemClass.rawValue
    query[cf.AttributeSynchronizable] = cf.SynchronizableAny
    query[cf.MatchLimit] = cf.MatchLimitAll
    query[cf.ReturnAttributes] = kCFBooleanTrue

    return prettify(itemClass: itemClass, items: copyItems(query)).map {
      switch itemClass {
      case .genericPassword:
        return ($0["service"] as? String ?? "", $0["key"] as? String ?? "")
      case .internetPassword:
        return ($0["server"] as? String ?? "", $0["key"] as? String ?? "")
      }
    }
  }

  /// Returns the keys of all items of this keychain.
  public func allKeys() -> [String] {
    type(of: self).prettify(itemClass: itemClass, items: items()).compactMap { $0["key"] as? String }
  }

  /// Returns a readable description of all items of `itemClass` the app can access.
  public class func allItems(_ itemClass: ItemClass) -> [[String: Any]] {
    let cf = CFStringWrap.shared
    var query = [String: Any]()
    query[cf.Class] = itemClass.rawValue
    query[cf.AttributeSynchronizable] = cf.SynchronizableAny
    query[cf.MatchLimit] = cf.MatchLimitAll
    query[cf.ReturnAttributes] = kCFBooleanTrue
#if os(iOS) || os(watchOS) || os(tvOS)
    query[cf.ReturnData] = kCFBooleanTrue
#endif

    return prettify(itemClass: itemClass, items: copyItems(query))
  }

  /// Returns a readable description of all items of this keychain.
  public func allItems() -> [[String: Any]] {
    type(of: self).prettify(itemClass: itemClass, items: items())
  }

  // MARK: - Private

  fileprivate func items() -> [[String: Any]] {
    var query = options.query()
    query[cf.MatchLimit] = cf.MatchLimitAll
    query[cf.ReturnAttributes] = kCFBooleanTrue
#if os(iOS) || os(watchOS) || os(tvOS)
    query[cf.ReturnData] = kCFBooleanTrue
#endif

    return type(of: self).copyItems(query)
  }

  /// Returns the items matching `query`, or `[]` if there are none or the query failed (failures are logged).
  fileprivate class func copyItems(_ query: [String: Any]) -> [[String: Any]] {
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    switch status {
    case errSecSuccess:
      return result as? [[String: Any]] ?? []
    case errSecItemNotFound:
      return []
    default:
      securityError(status: status)
      return []
    }
  }

  fileprivate class func prettify(itemClass: ItemClass, items: [[String: Any]]) -> [[String: Any]] {
    let cf = CFStringWrap.shared
    let items = items.map { attributes -> [String: Any] in
      var item = [String: Any]()

      item["class"] = itemClass.description

      if let accessGroup = attributes[cf.AttributeAccessGroup] as? String {
        item["accessGroup"] = accessGroup
      }

      switch itemClass {
      case .genericPassword:
        if let service = attributes[cf.AttributeService] as? String {
          item["service"] = service
        }
      case .internetPassword:
        if let server = attributes[cf.AttributeServer] as? String {
          item["server"] = server
        }
        if let proto = attributes[cf.AttributeProtocol] as? String, let protocolType = ProtocolType(rawValue: proto) {
          item["protocol"] = protocolType.description
        }
        if let auth = attributes[cf.AttributeAuthenticationType] as? String, let authenticationType = AuthenticationType(rawValue: auth) {
          item["authenticationType"] = authenticationType.description
        }
      }

      if let key = attributes[cf.AttributeAccount] as? String {
        item["key"] = key
      }
      if let data = attributes[cf.ValueData] as? Data {
        item["value"] = String(data: data, encoding: .utf8) ?? data
      }

      if let accessible = attributes[cf.AttributeAccessible] as? String, let accessibility = Accessibility(rawValue: accessible) {
        item["accessibility"] = accessibility.description
      }
      if let synchronizable = attributes[cf.AttributeSynchronizable] as? Bool {
        item["synchronizable"] = synchronizable ? "true" : "false"
      }

      return item
    }
    return items
  }

  // MARK: - Errors

  /// Maps an `OSStatus` to `Status`, or to an `NSOSStatusErrorDomain` error that keeps the original code
  /// when `Status` has no matching case.
  @discardableResult
  fileprivate class func securityError(status: OSStatus) -> any Error {
    let error: any Error
    if let known = Status(rawValue: status) {
      error = known
    } else {
      let message = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error."
      error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: message])
    }
    if (error as? Status) != .userCanceled {
      logger.error("OSStatus error:[\(status)] \(error.localizedDescription, privacy: .public)")
    }

    return error
  }

  @discardableResult
  fileprivate func securityError(status: OSStatus) -> any Error {
    type(of: self).securityError(status: status)
  }

  /// Query matching the item stored for `key`.
  fileprivate func itemQuery(_ key: String, ignoringAttributeSynchronizable: Bool) -> [String: Any] {
    var query = options.query(ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
    query[cf.AttributeAccount] = key
    return query
  }

  fileprivate func check(_ status: OSStatus) throws {
    if status != errSecSuccess {
      throw securityError(status: status)
    }
  }
}
extension Keychain: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    let items = allItems()
    if items.isEmpty {
      return "[]"
    }
    return "[\n" + items.map { "  \($0)\n" }.joined() + "]"
  }

  public var debugDescription: String {
    "\(items())"
  }
}
