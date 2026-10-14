//
//  Options.swift
//  KeychainAccess
//
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation
import Security
#if os(iOS) || os(macOS)
import LocalAuthentication
#endif

struct Options {
  var cf: CFStringWrap { .shared }

  var itemClass: ItemClass = .genericPassword

  var service: String = ""
  var accessGroup: String? = nil

  var server: URL?
  var protocolType: ProtocolType?
  var authenticationType: AuthenticationType = .default

  var accessibility: Accessibility = .afterFirstUnlock
  var authenticationPolicy: AuthenticationPolicy?

  var synchronizable: Bool = false

  var label: String?
  var comment: String?

#if os(iOS) || os(macOS)
  var authenticationContext: LAContext?
#endif

  var attributes = [String: Any]()
}

struct CFStringWrap: @unchecked Sendable {
  static let shared = CFStringWrap()

  // Class Key Constant
  let Class = String(kSecClass)

  // Attribute Key Constants
  let AttributeAccessible = String(kSecAttrAccessible)

  let AttributeAccessControl = String(kSecAttrAccessControl)

  let AttributeAccessGroup = String(kSecAttrAccessGroup)
  let AttributeSynchronizable = String(kSecAttrSynchronizable)
  let AttributeCreationDate = String(kSecAttrCreationDate)
  let AttributeModificationDate = String(kSecAttrModificationDate)
  let AttributeDescription = String(kSecAttrDescription)
  let AttributeComment = String(kSecAttrComment)
  let AttributeCreator = String(kSecAttrCreator)
  let AttributeType = String(kSecAttrType)
  let AttributeLabel = String(kSecAttrLabel)
  let AttributeIsInvisible = String(kSecAttrIsInvisible)
  let AttributeIsNegative = String(kSecAttrIsNegative)
  let AttributeAccount = String(kSecAttrAccount)
  let AttributeService = String(kSecAttrService)
  let AttributeGeneric = String(kSecAttrGeneric)
  let AttributeSecurityDomain = String(kSecAttrSecurityDomain)
  let AttributeServer = String(kSecAttrServer)
  let AttributeProtocol = String(kSecAttrProtocol)
  let AttributeAuthenticationType = String(kSecAttrAuthenticationType)
  let AttributePort = String(kSecAttrPort)
  let AttributePath = String(kSecAttrPath)

  let SynchronizableAny = kSecAttrSynchronizableAny

  // Search Constants
  let MatchLimit = String(kSecMatchLimit)
  let MatchLimitOne = kSecMatchLimitOne
  let MatchLimitAll = kSecMatchLimitAll

  // Return Type Key Constants
  let ReturnData = String(kSecReturnData)
  let ReturnAttributes = String(kSecReturnAttributes)
  let ReturnRef = String(kSecReturnRef)
  let ReturnPersistentRef = String(kSecReturnPersistentRef)

  // Value Type Key Constants
  let ValueData = String(kSecValueData)
  let ValueRef = String(kSecValueRef)
  let ValuePersistentRef = String(kSecValuePersistentRef)

  let UseAuthenticationContext = String(kSecUseAuthenticationContext)
}
extension Options {
  func query(ignoringAttributeSynchronizable: Bool = true) -> [String: Any] {
    var query = [String: Any]()

    query[cf.Class] = itemClass.rawValue
    if let accessGroup = self.accessGroup {
      query[cf.AttributeAccessGroup] = accessGroup
    }
    if ignoringAttributeSynchronizable {
      query[cf.AttributeSynchronizable] = cf.SynchronizableAny
    } else {
      query[cf.AttributeSynchronizable] = synchronizable ? kCFBooleanTrue : kCFBooleanFalse
    }

    switch itemClass {
    case .genericPassword:
      query[cf.AttributeService] = service
    case .internetPassword:
      query[cf.AttributeServer] = server?.host
      query[cf.AttributePort] = server?.port
      query[cf.AttributeProtocol] = protocolType?.rawValue
      query[cf.AttributeAuthenticationType] = authenticationType.rawValue
    }

#if os(iOS) || os(macOS)
    if authenticationContext != nil {
      query[cf.UseAuthenticationContext] = authenticationContext
    }
#endif

    return query
  }

  /// Attributes to add (`key` set) or to update (`key` nil) an item with `value`, including custom `attributes`.
  func attributes(key: String?, value: Data) throws -> [String: Any] {
    var attributes: [String: Any]

    if key != nil {
      attributes = query()
      attributes[cf.AttributeAccount] = key
    } else {
      attributes = [String: Any]()
    }

    attributes[cf.ValueData] = value

    if label != nil {
      attributes[cf.AttributeLabel] = label
    }
    if comment != nil {
      attributes[cf.AttributeComment] = comment
    }

    if let policy = authenticationPolicy {
      var error: Unmanaged<CFError>?
      guard let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, accessibility.rawValue as CFTypeRef, SecAccessControlCreateFlags(rawValue: CFOptionFlags(policy.rawValue)), &error) else {
        if let error = error?.takeRetainedValue() {
          throw error
        }
        throw Status.unexpectedError
      }
      attributes[cf.AttributeAccessControl] = accessControl
    } else {
      attributes[cf.AttributeAccessible] = accessibility.rawValue
    }

    attributes[cf.AttributeSynchronizable] = synchronizable ? kCFBooleanTrue : kCFBooleanFalse
    attributes.merge(self.attributes) { $1 }

    return attributes
  }
}
