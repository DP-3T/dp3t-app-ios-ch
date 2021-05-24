// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: SwissCovid.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

enum VenueType: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case userQrCode // = 0
  case contactTracingQrCode // = 1
  case UNRECOGNIZED(Int)

  init() {
    self = .userQrCode
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .userQrCode
    case 1: self = .contactTracingQrCode
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .userQrCode: return 0
    case .contactTracingQrCode: return 1
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension VenueType: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [VenueType] = [
    .userQrCode,
    .contactTracingQrCode,
  ]
}

#endif  // swift(>=4.2)

enum EventCriticality: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case low // = 0
  case high // = 1
  case UNRECOGNIZED(Int)

  init() {
    self = .low
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .low
    case 1: self = .high
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .low: return 0
    case .high: return 1
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension EventCriticality: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [EventCriticality] = [
    .low,
    .high,
  ]
}

#endif  // swift(>=4.2)

struct SwissCovidLocationData {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var version: UInt32 = 0

  var type: VenueType = .userQrCode

  var room: String = String()

  var checkoutWarningDelayMs: Int64 = 0

  var automaticCheckoutDelaylMs: Int64 = 0

  var reminderDelayOptionsMs: [Int64] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct SwissCovidAssociatedData {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var version: Int32 = 0

  var room: String = String()

  var criticality: EventCriticality = .low

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension VenueType: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "USER_QR_CODE"),
    1: .same(proto: "CONTACT_TRACING_QR_CODE"),
  ]
}

extension EventCriticality: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "LOW"),
    1: .same(proto: "HIGH"),
  ]
}

extension SwissCovidLocationData: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "SwissCovidLocationData"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "version"),
    2: .same(proto: "type"),
    3: .same(proto: "room"),
    4: .same(proto: "checkoutWarningDelayMs"),
    5: .same(proto: "automaticCheckoutDelaylMs"),
    6: .same(proto: "reminderDelayOptionsMs"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt32Field(value: &self.version) }()
      case 2: try { try decoder.decodeSingularEnumField(value: &self.type) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.room) }()
      case 4: try { try decoder.decodeSingularInt64Field(value: &self.checkoutWarningDelayMs) }()
      case 5: try { try decoder.decodeSingularInt64Field(value: &self.automaticCheckoutDelaylMs) }()
      case 6: try { try decoder.decodeRepeatedInt64Field(value: &self.reminderDelayOptionsMs) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.version != 0 {
      try visitor.visitSingularUInt32Field(value: self.version, fieldNumber: 1)
    }
    if self.type != .userQrCode {
      try visitor.visitSingularEnumField(value: self.type, fieldNumber: 2)
    }
    if !self.room.isEmpty {
      try visitor.visitSingularStringField(value: self.room, fieldNumber: 3)
    }
    if self.checkoutWarningDelayMs != 0 {
      try visitor.visitSingularInt64Field(value: self.checkoutWarningDelayMs, fieldNumber: 4)
    }
    if self.automaticCheckoutDelaylMs != 0 {
      try visitor.visitSingularInt64Field(value: self.automaticCheckoutDelaylMs, fieldNumber: 5)
    }
    if !self.reminderDelayOptionsMs.isEmpty {
      try visitor.visitPackedInt64Field(value: self.reminderDelayOptionsMs, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SwissCovidLocationData, rhs: SwissCovidLocationData) -> Bool {
    if lhs.version != rhs.version {return false}
    if lhs.type != rhs.type {return false}
    if lhs.room != rhs.room {return false}
    if lhs.checkoutWarningDelayMs != rhs.checkoutWarningDelayMs {return false}
    if lhs.automaticCheckoutDelaylMs != rhs.automaticCheckoutDelaylMs {return false}
    if lhs.reminderDelayOptionsMs != rhs.reminderDelayOptionsMs {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SwissCovidAssociatedData: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "SwissCovidAssociatedData"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "version"),
    2: .same(proto: "room"),
    3: .same(proto: "criticality"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt32Field(value: &self.version) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.room) }()
      case 3: try { try decoder.decodeSingularEnumField(value: &self.criticality) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.version != 0 {
      try visitor.visitSingularInt32Field(value: self.version, fieldNumber: 1)
    }
    if !self.room.isEmpty {
      try visitor.visitSingularStringField(value: self.room, fieldNumber: 2)
    }
    if self.criticality != .low {
      try visitor.visitSingularEnumField(value: self.criticality, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SwissCovidAssociatedData, rhs: SwissCovidAssociatedData) -> Bool {
    if lhs.version != rhs.version {return false}
    if lhs.room != rhs.room {return false}
    if lhs.criticality != rhs.criticality {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}