//
//  Attributes.swift
//  KeychainAccess
//
//  Licensed under the MIT License. See LICENSE for details.
//

public import Foundation
public import Security

// Holds an immutable snapshot of Security framework attribute values (property-list types).
public struct Attributes: @unchecked Sendable {
  private var cf: CFStringWrap { .shared }

  public var `class`: String? {
    value(cf.Class)
  }
  public var data: Data? {
    value(cf.ValueData)
  }
  /// The item reference (`kSecValueRef`), if the keychain returned one.
  public var ref: AnyObject? {
    attributes[cf.ValueRef].map { $0 as AnyObject }
  }
  public var persistentRef: Data? {
    value(cf.ValuePersistentRef)
  }

  public var accessible: String? {
    value(cf.AttributeAccessible)
  }
  public var accessControl: SecAccessControl? {
    if let accessControl = attributes[cf.AttributeAccessControl] {
      return (accessControl as! SecAccessControl)
    }
    return nil
  }
  public var accessGroup: String? {
    value(cf.AttributeAccessGroup)
  }
  public var synchronizable: Bool? {
    value(cf.AttributeSynchronizable)
  }
  public var creationDate: Date? {
    value(cf.AttributeCreationDate)
  }
  public var modificationDate: Date? {
    value(cf.AttributeModificationDate)
  }
  public var attributeDescription: String? {
    value(cf.AttributeDescription)
  }
  public var comment: String? {
    value(cf.AttributeComment)
  }
  public var creator: String? {
    value(cf.AttributeCreator)
  }
  public var type: String? {
    value(cf.AttributeType)
  }
  public var label: String? {
    value(cf.AttributeLabel)
  }
  public var isInvisible: Bool? {
    value(cf.AttributeIsInvisible)
  }
  public var isNegative: Bool? {
    value(cf.AttributeIsNegative)
  }
  public var account: String? {
    value(cf.AttributeAccount)
  }
  public var service: String? {
    value(cf.AttributeService)
  }
  public var generic: Data? {
    value(cf.AttributeGeneric)
  }
  public var securityDomain: String? {
    value(cf.AttributeSecurityDomain)
  }
  public var server: String? {
    value(cf.AttributeServer)
  }
  public var `protocol`: String? {
    value(cf.AttributeProtocol)
  }
  public var authenticationType: String? {
    value(cf.AttributeAuthenticationType)
  }
  public var port: Int? {
    value(cf.AttributePort)
  }
  public var path: String? {
    value(cf.AttributePath)
  }

  private let attributes: [String: Any]

  init(attributes: [String: Any]) {
    self.attributes = attributes
  }

  private func value<T>(_ key: String) -> T? {
    attributes[key] as? T
  }

  public subscript(key: String) -> Any? {
    get {
      attributes[key]
    }
  }
}

extension Attributes: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    "\(attributes)"
  }

  public var debugDescription: String {
    description
  }
}
