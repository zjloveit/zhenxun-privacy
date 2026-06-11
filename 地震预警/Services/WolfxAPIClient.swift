import Foundation

/// Wolfx Open API — 日本気象庁（JMA）データ
/// https://wolfx.jp/apidoc
enum WolfxEndpoints {
    static let jmaEEW = URL(string: "https://api.wolfx.jp/jma_eew.json")!
    static let jmaEQList = URL(string: "https://api.wolfx.jp/jma_eqlist.json")!
    static let jmaEEWWebSocket = URL(string: "wss://ws-api.wolfx.jp/jma_eew")!
}

struct WolfxJMAEEWResponse: Decodable {
    let title: String?
    let eventID: String?
    let serial: Int?
    let announcedTime: String?
    let originTime: String?
    let hypocenter: String?
    let latitude: Double?
    let longitude: Double?
    let magunitude: Double?
    let depth: Double?
    let maxIntensity: String?
    let isCancel: Bool?
    let isTraining: Bool?
    let isFinal: Bool?
    let isWarn: Bool?

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case eventID = "EventID"
        case serial = "Serial"
        case announcedTime = "AnnouncedTime"
        case originTime = "OriginTime"
        case hypocenter = "Hypocenter"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case magunitude = "Magunitude"
        case depth = "Depth"
        case maxIntensity = "MaxIntensity"
        case isCancel
        case isTraining
        case isFinal
        case isWarn
    }

    func toEarlyWarning(fallbackID: String = UUID().uuidString) -> EarlyWarning? {
        if isCancel == true || isTraining == true { return nil }

        guard
            let latitude,
            let longitude,
            let magnitude = magunitude,
            let originTimeString = originTime,
            let origin = DateParser.japan.parse(originTimeString)
        else { return nil }

        let report = announcedTime.flatMap { DateParser.japan.parse($0) } ?? .now
        let intensity = JMAIntensityParser.numeric(from: maxIntensity)

        return EarlyWarning(
            id: eventID ?? fallbackID,
            eventID: eventID ?? fallbackID,
            reportNum: serial ?? 1,
            magnitude: magnitude,
            latitude: latitude,
            longitude: longitude,
            depth: depth,
            hypocenter: hypocenter ?? "震源不明",
            originTime: origin,
            reportTime: report,
            maxIntensity: intensity,
            maxShindoLabel: maxIntensity
        )
    }
}

enum JMAEQListParser {
    static func parse(data: Data) -> [EarthquakeEvent] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return []
        }

        return json.keys
            .compactMap { key -> Int? in
                if key.hasPrefix("No"), let number = Int(key.dropFirst(2)) { return number }
                return nil
            }
            .sorted()
            .compactMap { index in
                guard let item = json["No\(index)"] as? [String: Any] else { return nil }
                return parseEvent(index: index, item: item)
            }
    }

    private static func parseEvent(index: Int, item: [String: Any]) -> EarthquakeEvent? {
        guard
            let magnitudeString = item["magnitude"] as? String,
            let magnitude = Double(magnitudeString),
            let latitudeString = item["latitude"] as? String,
            let latitude = Double(latitudeString),
            let longitudeString = item["longitude"] as? String,
            let longitude = Double(longitudeString)
        else { return nil }

        let timeString = (item["time_full"] as? String) ?? (item["time"] as? String)
        guard let timeString, let originTime = DateParser.japan.parse(timeString) else { return nil }

        let depth = parseDepth(item["depth"] as? String ?? "0")
        let location = item["location"] as? String ?? "震源不明"
        let shindo = item["shindo"] as? String
        let eventID = item["EventID"] as? String ?? "jma-\(index)-\(timeString)"

        return EarthquakeEvent(
            id: eventID,
            magnitude: magnitude,
            latitude: latitude,
            longitude: longitude,
            depth: depth,
            locationName: location,
            originTime: originTime,
            reportType: .reviewed,
            maxShindo: shindo
        )
    }

    private static func parseDepth(_ raw: String) -> Double {
        let cleaned = raw
            .replacingOccurrences(of: "km", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespaces)
        return Double(cleaned) ?? 0
    }
}

enum JMAIntensityParser {
    /// "5+", "3", "震度4" などを数値化（震度階級のおおよその代表値）
    static func numeric(from raw: String?) -> Double? {
        guard let raw else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        if let value = Double(trimmed.filter { $0.isNumber || $0 == "." }) {
            if trimmed.contains("+") { return value + 0.5 }
            if trimmed.contains("-") || trimmed.contains("弱") { return max(0.5, value - 0.5) }
            return value
        }
        return nil
    }
}

enum DateParser {
    case japan

    private static let formatters: [DateFormatter] = {
        let patterns = [
            "yyyy/MM/dd HH:mm:ss",
            "yyyy/MM/dd HH:mm",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ssZ"
        ]
        return patterns.map { pattern in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ja_JP")
            formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            formatter.dateFormat = pattern
            return formatter
        }
    }()

    func parse(_ value: String) -> Date? {
        for formatter in Self.formatters {
            if let date = formatter.date(from: value) {
                return date
            }
        }
        return ISO8601DateFormatter().date(from: value)
    }
}

final class WolfxAPIClient {
    enum ClientError: LocalizedError {
        case invalidResponse
        case emptyPayload

        var errorDescription: String? {
            switch self {
            case .invalidResponse: return "サーバーからの応答が無効です"
            case .emptyPayload: return "データがありません"
            }
        }
    }

    func fetchLatestEarlyWarning() async throws -> EarlyWarning? {
        let (data, response) = try await URLSession.shared.data(from: WolfxEndpoints.jmaEEW)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw ClientError.invalidResponse
        }

        let payload = try JSONDecoder().decode(WolfxJMAEEWResponse.self, from: data)
        return payload.toEarlyWarning()
    }

    func fetchEarthquakeList() async throws -> [EarthquakeEvent] {
        let (data, response) = try await URLSession.shared.data(from: WolfxEndpoints.jmaEQList)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw ClientError.invalidResponse
        }

        return JMAEQListParser.parse(data: data)
    }
}
