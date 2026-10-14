//
//  KeychainTypes.swift
//  KeychainAccess
//
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation
import Security

public enum ItemClass: Sendable {
  case genericPassword
  case internetPassword
}

public enum ProtocolType: Sendable {
  case ftp
  case ftpAccount
  case http
  case irc
  case nntp
  case pop3
  case smtp
  case socks
  case imap
  case ldap
  case appleTalk
  case afp
  case telnet
  case ssh
  case ftps
  case https
  case httpProxy
  case httpsProxy
  case ftpProxy
  case smb
  case rtsp
  case rtspProxy
  case daap
  case eppc
  case ipp
  case nntps
  case ldaps
  case telnetS
  case imaps
  case ircs
  case pop3S
}

public enum AuthenticationType: Sendable {
  case ntlm
  case msn
  case dpa
  case rpa
  case httpBasic
  case httpDigest
  case htmlForm
  case `default`
}

public enum Accessibility: Sendable {
  /// Item data can only be accessed
  /// while the device is unlocked. This is recommended for items that only
  /// need be accessible while the application is in the foreground. Items
  /// with this attribute will migrate to a new device when using encrypted
  /// backups.
  case whenUnlocked

  /// Item data can only be
  /// accessed once the device has been unlocked after a restart. This is
  /// recommended for items that need to be accessible by background
  /// applications. Items with this attribute will migrate to a new device
  /// when using encrypted backups.
  case afterFirstUnlock

  /// Item data can
  /// only be accessed while the device is unlocked. This class is only
  /// available if a passcode is set on the device. This is recommended for
  /// items that only need to be accessible while the application is in the
  /// foreground. Items with this attribute will never migrate to a new
  /// device, so after a backup is restored to a new device, these items
  /// will be missing. No items can be stored in this class on devices
  /// without a passcode. Disabling the device passcode will cause all
  /// items in this class to be deleted.
  case whenPasscodeSetThisDeviceOnly

  /// Item data can only
  /// be accessed while the device is unlocked. This is recommended for items
  /// that only need be accessible while the application is in the foreground.
  /// Items with this attribute will never migrate to a new device, so after
  /// a backup is restored to a new device, these items will be missing.
  case whenUnlockedThisDeviceOnly

  /// Item data can
  /// only be accessed once the device has been unlocked after a restart.
  /// This is recommended for items that need to be accessible by background
  /// applications. Items with this attribute will never migrate to a new
  /// device, so after a backup is restored to a new device these items will
  /// be missing.
  case afterFirstUnlockThisDeviceOnly
}

public struct AuthenticationPolicy: Sendable, OptionSet {
  /// User presence policy using Touch ID or Passcode. Touch ID does not
  /// have to be available or enrolled. Item is still accessible by Touch ID
  /// even if fingers are added or removed.
  public static let userPresence = AuthenticationPolicy(rawValue: 1 << 0)

  /// Constraint: Touch ID (any finger) or Face ID. Touch ID or Face ID must be available. With Touch ID
  /// at least one finger must be enrolled. With Face ID user has to be enrolled. Item is still accessible by Touch ID even
  /// if fingers are added or removed. Item is still accessible by Face ID if user is re-enrolled.
  public static let biometryAny = AuthenticationPolicy(rawValue: 1 << 1)

  /// Constraint: Touch ID from the set of currently enrolled fingers. Touch ID must be available and at least one finger must
  /// be enrolled. When fingers are added or removed, the item is invalidated. When Face ID is re-enrolled this item is invalidated.
  public static let biometryCurrentSet = AuthenticationPolicy(rawValue: 1 << 3)

  /// Constraint: Device passcode
  public static let devicePasscode = AuthenticationPolicy(rawValue: 1 << 4)

  /// Constraint: Watch
  @available(iOS, unavailable)
  @available(watchOS, unavailable)
  @available(tvOS, unavailable)
  public static let watch = AuthenticationPolicy(rawValue: 1 << 5)

  /// Constraint logic operation: when using more than one constraint,
  /// at least one of them must be satisfied.
  public static let or = AuthenticationPolicy(rawValue: 1 << 14)

  /// Constraint logic operation: when using more than one constraint,
  /// all must be satisfied.
  public static let and = AuthenticationPolicy(rawValue: 1 << 15)

  /// Create access control for private key operations (i.e. sign operation)
  public static let privateKeyUsage = AuthenticationPolicy(rawValue: 1 << 30)

  /// Security: Application provided password for data encryption key generation.
  /// This is not a constraint but additional item encryption mechanism.
  public static let applicationPassword = AuthenticationPolicy(rawValue: 1 << 31)

  public let rawValue: UInt

  public init(rawValue: UInt) {
    self.rawValue = rawValue
  }
}
extension ItemClass: RawRepresentable, CustomStringConvertible {
  public init?(rawValue: String) {
    switch rawValue {
    case String(kSecClassGenericPassword):
      self = .genericPassword
    case String(kSecClassInternetPassword):
      self = .internetPassword
    default:
      return nil
    }
  }

  public var rawValue: String {
    switch self {
    case .genericPassword:
      return String(kSecClassGenericPassword)
    case .internetPassword:
      return String(kSecClassInternetPassword)
    }
  }

  public var description: String {
    switch self {
    case .genericPassword:
      return "GenericPassword"
    case .internetPassword:
      return "InternetPassword"
    }
  }
}

extension ProtocolType: RawRepresentable, CustomStringConvertible {
  public init?(rawValue: String) {
    switch rawValue {
    case String(kSecAttrProtocolFTP):
      self = .ftp
    case String(kSecAttrProtocolFTPAccount):
      self = .ftpAccount
    case String(kSecAttrProtocolHTTP):
      self = .http
    case String(kSecAttrProtocolIRC):
      self = .irc
    case String(kSecAttrProtocolNNTP):
      self = .nntp
    case String(kSecAttrProtocolPOP3):
      self = .pop3
    case String(kSecAttrProtocolSMTP):
      self = .smtp
    case String(kSecAttrProtocolSOCKS):
      self = .socks
    case String(kSecAttrProtocolIMAP):
      self = .imap
    case String(kSecAttrProtocolLDAP):
      self = .ldap
    case String(kSecAttrProtocolAppleTalk):
      self = .appleTalk
    case String(kSecAttrProtocolAFP):
      self = .afp
    case String(kSecAttrProtocolTelnet):
      self = .telnet
    case String(kSecAttrProtocolSSH):
      self = .ssh
    case String(kSecAttrProtocolFTPS):
      self = .ftps
    case String(kSecAttrProtocolHTTPS):
      self = .https
    case String(kSecAttrProtocolHTTPProxy):
      self = .httpProxy
    case String(kSecAttrProtocolHTTPSProxy):
      self = .httpsProxy
    case String(kSecAttrProtocolFTPProxy):
      self = .ftpProxy
    case String(kSecAttrProtocolSMB):
      self = .smb
    case String(kSecAttrProtocolRTSP):
      self = .rtsp
    case String(kSecAttrProtocolRTSPProxy):
      self = .rtspProxy
    case String(kSecAttrProtocolDAAP):
      self = .daap
    case String(kSecAttrProtocolEPPC):
      self = .eppc
    case String(kSecAttrProtocolIPP):
      self = .ipp
    case String(kSecAttrProtocolNNTPS):
      self = .nntps
    case String(kSecAttrProtocolLDAPS):
      self = .ldaps
    case String(kSecAttrProtocolTelnetS):
      self = .telnetS
    case String(kSecAttrProtocolIMAPS):
      self = .imaps
    case String(kSecAttrProtocolIRCS):
      self = .ircs
    case String(kSecAttrProtocolPOP3S):
      self = .pop3S
    default:
      return nil
    }
  }

  public var rawValue: String {
    switch self {
    case .ftp:
      return String(kSecAttrProtocolFTP)
    case .ftpAccount:
      return String(kSecAttrProtocolFTPAccount)
    case .http:
      return String(kSecAttrProtocolHTTP)
    case .irc:
      return String(kSecAttrProtocolIRC)
    case .nntp:
      return String(kSecAttrProtocolNNTP)
    case .pop3:
      return String(kSecAttrProtocolPOP3)
    case .smtp:
      return String(kSecAttrProtocolSMTP)
    case .socks:
      return String(kSecAttrProtocolSOCKS)
    case .imap:
      return String(kSecAttrProtocolIMAP)
    case .ldap:
      return String(kSecAttrProtocolLDAP)
    case .appleTalk:
      return String(kSecAttrProtocolAppleTalk)
    case .afp:
      return String(kSecAttrProtocolAFP)
    case .telnet:
      return String(kSecAttrProtocolTelnet)
    case .ssh:
      return String(kSecAttrProtocolSSH)
    case .ftps:
      return String(kSecAttrProtocolFTPS)
    case .https:
      return String(kSecAttrProtocolHTTPS)
    case .httpProxy:
      return String(kSecAttrProtocolHTTPProxy)
    case .httpsProxy:
      return String(kSecAttrProtocolHTTPSProxy)
    case .ftpProxy:
      return String(kSecAttrProtocolFTPProxy)
    case .smb:
      return String(kSecAttrProtocolSMB)
    case .rtsp:
      return String(kSecAttrProtocolRTSP)
    case .rtspProxy:
      return String(kSecAttrProtocolRTSPProxy)
    case .daap:
      return String(kSecAttrProtocolDAAP)
    case .eppc:
      return String(kSecAttrProtocolEPPC)
    case .ipp:
      return String(kSecAttrProtocolIPP)
    case .nntps:
      return String(kSecAttrProtocolNNTPS)
    case .ldaps:
      return String(kSecAttrProtocolLDAPS)
    case .telnetS:
      return String(kSecAttrProtocolTelnetS)
    case .imaps:
      return String(kSecAttrProtocolIMAPS)
    case .ircs:
      return String(kSecAttrProtocolIRCS)
    case .pop3S:
      return String(kSecAttrProtocolPOP3S)
    }
  }

  public var description: String {
    switch self {
    case .ftp:
      return "FTP"
    case .ftpAccount:
      return "FTPAccount"
    case .http:
      return "HTTP"
    case .irc:
      return "IRC"
    case .nntp:
      return "NNTP"
    case .pop3:
      return "POP3"
    case .smtp:
      return "SMTP"
    case .socks:
      return "SOCKS"
    case .imap:
      return "IMAP"
    case .ldap:
      return "LDAP"
    case .appleTalk:
      return "AppleTalk"
    case .afp:
      return "AFP"
    case .telnet:
      return "Telnet"
    case .ssh:
      return "SSH"
    case .ftps:
      return "FTPS"
    case .https:
      return "HTTPS"
    case .httpProxy:
      return "HTTPProxy"
    case .httpsProxy:
      return "HTTPSProxy"
    case .ftpProxy:
      return "FTPProxy"
    case .smb:
      return "SMB"
    case .rtsp:
      return "RTSP"
    case .rtspProxy:
      return "RTSPProxy"
    case .daap:
      return "DAAP"
    case .eppc:
      return "EPPC"
    case .ipp:
      return "IPP"
    case .nntps:
      return "NNTPS"
    case .ldaps:
      return "LDAPS"
    case .telnetS:
      return "TelnetS"
    case .imaps:
      return "IMAPS"
    case .ircs:
      return "IRCS"
    case .pop3S:
      return "POP3S"
    }
  }
}

extension AuthenticationType: RawRepresentable, CustomStringConvertible {
  public init?(rawValue: String) {
    switch rawValue {
    case String(kSecAttrAuthenticationTypeNTLM):
      self = .ntlm
    case String(kSecAttrAuthenticationTypeMSN):
      self = .msn
    case String(kSecAttrAuthenticationTypeDPA):
      self = .dpa
    case String(kSecAttrAuthenticationTypeRPA):
      self = .rpa
    case String(kSecAttrAuthenticationTypeHTTPBasic):
      self = .httpBasic
    case String(kSecAttrAuthenticationTypeHTTPDigest):
      self = .httpDigest
    case String(kSecAttrAuthenticationTypeHTMLForm):
      self = .htmlForm
    case String(kSecAttrAuthenticationTypeDefault):
      self = .`default`
    default:
      return nil
    }
  }

  public var rawValue: String {
    switch self {
    case .ntlm:
      return String(kSecAttrAuthenticationTypeNTLM)
    case .msn:
      return String(kSecAttrAuthenticationTypeMSN)
    case .dpa:
      return String(kSecAttrAuthenticationTypeDPA)
    case .rpa:
      return String(kSecAttrAuthenticationTypeRPA)
    case .httpBasic:
      return String(kSecAttrAuthenticationTypeHTTPBasic)
    case .httpDigest:
      return String(kSecAttrAuthenticationTypeHTTPDigest)
    case .htmlForm:
      return String(kSecAttrAuthenticationTypeHTMLForm)
    case .`default`:
      return String(kSecAttrAuthenticationTypeDefault)
    }
  }

  public var description: String {
    switch self {
    case .ntlm:
      return "NTLM"
    case .msn:
      return "MSN"
    case .dpa:
      return "DPA"
    case .rpa:
      return "RPA"
    case .httpBasic:
      return "HTTPBasic"
    case .httpDigest:
      return "HTTPDigest"
    case .htmlForm:
      return "HTMLForm"
    case .`default`:
      return "Default"
    }
  }
}

extension Accessibility: RawRepresentable, CustomStringConvertible {
  public init?(rawValue: String) {
    switch rawValue {
    case String(kSecAttrAccessibleWhenUnlocked):
      self = .whenUnlocked
    case String(kSecAttrAccessibleAfterFirstUnlock):
      self = .afterFirstUnlock
    case String(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly):
      self = .whenPasscodeSetThisDeviceOnly
    case String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly):
      self = .whenUnlockedThisDeviceOnly
    case String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly):
      self = .afterFirstUnlockThisDeviceOnly
    default:
      return nil
    }
  }

  public var rawValue: String {
    switch self {
    case .whenUnlocked:
      return String(kSecAttrAccessibleWhenUnlocked)
    case .afterFirstUnlock:
      return String(kSecAttrAccessibleAfterFirstUnlock)
    case .whenPasscodeSetThisDeviceOnly:
      return String(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
    case .whenUnlockedThisDeviceOnly:
      return String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
    case .afterFirstUnlockThisDeviceOnly:
      return String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
    }
  }

  public var description: String {
    switch self {
    case .whenUnlocked:
      return "WhenUnlocked"
    case .afterFirstUnlock:
      return "AfterFirstUnlock"
    case .whenPasscodeSetThisDeviceOnly:
      return "WhenPasscodeSetThisDeviceOnly"
    case .whenUnlockedThisDeviceOnly:
      return "WhenUnlockedThisDeviceOnly"
    case .afterFirstUnlockThisDeviceOnly:
      return "AfterFirstUnlockThisDeviceOnly"
    }
  }
}
