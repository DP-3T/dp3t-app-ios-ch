// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: UserUploadPayload.proto
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

struct UserUploadPayload {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var version: Int32 = 0

  var venueInfos: [UploadVenueInfo] = []

  var userInteractionDurationMs: UInt32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct UploadVenueInfo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var preID: Data = Data()

  var timeKey: Data = Data()

  var intervalStartMs: UInt64 = 0

  var intervalEndMs: UInt64 = 0

  var notificationKey: Data = Data()

  var fake: Data = Data()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension UserUploadPayload: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "UserUploadPayload"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "version"),
    2: .same(proto: "venueInfos"),
    3: .same(proto: "userInteractionDurationMs"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt32Field(value: &self.version) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.venueInfos) }()
      case 3: try { try decoder.decodeSingularFixed32Field(value: &self.userInteractionDurationMs) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.version != 0 {
      try visitor.visitSingularInt32Field(value: self.version, fieldNumber: 1)
    }
    if !self.venueInfos.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.venueInfos, fieldNumber: 2)
    }
    if self.userInteractionDurationMs != 0 {
      try visitor.visitSingularFixed32Field(value: self.userInteractionDurationMs, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: UserUploadPayload, rhs: UserUploadPayload) -> Bool {
    if lhs.version != rhs.version {return false}
    if lhs.venueInfos != rhs.venueInfos {return false}
    if lhs.userInteractionDurationMs != rhs.userInteractionDurationMs {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension UploadVenueInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "UploadVenueInfo"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "preId"),
    2: .same(proto: "timeKey"),
    3: .same(proto: "intervalStartMs"),
    4: .same(proto: "intervalEndMs"),
    5: .same(proto: "notificationKey"),
    6: .same(proto: "fake"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.preID) }()
      case 2: try { try decoder.decodeSingularBytesField(value: &self.timeKey) }()
      case 3: try { try decoder.decodeSingularFixed64Field(value: &self.intervalStartMs) }()
      case 4: try { try decoder.decodeSingularFixed64Field(value: &self.intervalEndMs) }()
      case 5: try { try decoder.decodeSingularBytesField(value: &self.notificationKey) }()
      case 6: try { try decoder.decodeSingularBytesField(value: &self.fake) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.preID.isEmpty {
      try visitor.visitSingularBytesField(value: self.preID, fieldNumber: 1)
    }
    if !self.timeKey.isEmpty {
      try visitor.visitSingularBytesField(value: self.timeKey, fieldNumber: 2)
    }
    if self.intervalStartMs != 0 {
      try visitor.visitSingularFixed64Field(value: self.intervalStartMs, fieldNumber: 3)
    }
    if self.intervalEndMs != 0 {
      try visitor.visitSingularFixed64Field(value: self.intervalEndMs, fieldNumber: 4)
    }
    if !self.notificationKey.isEmpty {
      try visitor.visitSingularBytesField(value: self.notificationKey, fieldNumber: 5)
    }
    if !self.fake.isEmpty {
      try visitor.visitSingularBytesField(value: self.fake, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: UploadVenueInfo, rhs: UploadVenueInfo) -> Bool {
    if lhs.preID != rhs.preID {return false}
    if lhs.timeKey != rhs.timeKey {return false}
    if lhs.intervalStartMs != rhs.intervalStartMs {return false}
    if lhs.intervalEndMs != rhs.intervalEndMs {return false}
    if lhs.notificationKey != rhs.notificationKey {return false}
    if lhs.fake != rhs.fake {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
