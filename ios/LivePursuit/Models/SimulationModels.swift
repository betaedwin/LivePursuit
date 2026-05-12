import Foundation

enum SimulationScenario: String, CaseIterable, Identifiable {
    case normalDriving = "normal-driving"
    case pursuitPolice = "pursuit-police"
    case gpsJitter = "gps-jitter"
    case networkInterruption = "network-interruption"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pursuitPolice:
            return "Pursuit"
        case .normalDriving:
            return "Normal"
        case .gpsJitter:
            return "Jitter"
        case .networkInterruption:
            return "Network"
        }
    }

    var description: String {
        switch self {
        case .pursuitPolice:
            return "High-speed pursuit with continuous turns"
        case .normalDriving:
            return "Continuous movement with a reroute"
        case .gpsJitter:
            return "Small oscillations without reroutes"
        case .networkInterruption:
            return "Pause updates and recover"
        }
    }

    var isPursuit: Bool {
        self == .pursuitPolice
    }

    var supportsFollowMode: Bool {
        self == .pursuitPolice
    }
}

enum SimulationSpeed: Double, CaseIterable, Identifiable {
    case one = 1
    case two = 2
    case five = 5

    var id: Double { rawValue }

    var label: String {
        switch self {
        case .one:
            return "1x"
        case .two:
            return "2x"
        case .five:
            return "5x"
        }
    }
}

enum SimulationState: String, Codable {
    case running
    case paused
    case stopped
    case completed
}

struct SimulationStatus: Codable {
    let scriptId: String
    let status: SimulationState
    let speedMultiplier: Double
    let elapsedSeconds: Double
    let startedAt: Double?
    let lastEventAt: Double?
    let completedAt: Double?
}

struct ThrottleInfo: Codable {
    let intervalSeconds: Double
    let speedBucket: String
    let accuracyBucket: String
}

struct LocationUpdateResult: Codable {
    let latestLocation: LocationPoint?
    let accepted: Bool
    let nextAllowedAt: Double
    let throttle: ThrottleInfo
}

struct SessionLogEvent: Codable, Identifiable {
    let id: String
    let type: String
    let timestamp: Double
    let details: [String: JSONValue]?
}

enum JSONValue: Codable, Hashable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else {
            self = .null
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }

    var description: String {
        switch self {
        case .string(let value):
            return value
        case .number(let value):
            return String(format: "%.2f", value)
        case .bool(let value):
            return value ? "true" : "false"
        case .object:
            return "object"
        case .array:
            return "array"
        case .null:
            return "null"
        }
    }
}
