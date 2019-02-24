import Foundation
import Darwin

// Structures ///////////////////////////////////////////////////////////////////////

struct Plist {
    let filename: String
    let dict: NSDictionary
}

struct Leak {
    let name: String
    let description: String
    let debugDescription: String
    let displayAddress: String
    let isCycle: Bool
    let isRootLeak: Bool
    let allocationTimestamp: Int
    let count: Int
    let size: Int
    let possibleAppName: String?

    var id: String { return description.isEmpty ? name : description }

    init?(dict: NSDictionary) {
        guard   let name = dict["name"] as? String,
                let description = dict["description"] as? String,
                let debugDescription = dict["debugDescription"] as? String,
                let displayAddress = dict["displayAddress"] as? String,
                let isCycle = dict["isCycle"] as? Bool,
                let isRootLeak = dict["isRootLeak"] as? Bool,
                let allocationTimestamp = dict["allocationTimestamp"] as? Int,
                let count = dict["count"] as? Int,
                let size = dict["size"] as? Int
        else { return nil }
        self.name = name
        self.description = description
        self.debugDescription = debugDescription
        self.displayAddress = displayAddress
        self.isCycle = isCycle
        self.isRootLeak = isRootLeak
        self.allocationTimestamp = allocationTimestamp
        self.count = count
        self.size = size

        self.possibleAppName = description
            .components(separatedBy: " ")
            .filter { !$0.isEmpty && $0 != name && $0 != "Swift" }
            .joined(separator: " ")
    }
}

struct Report {
    let appName: String
    let createdAt: Date
    let leaks: [Leak]
    init?(plist: Plist, retainOnlyAppNameLeaks: Bool) {
        let filenameComponents = plist.filename.components(separatedBy: "-")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        guard   filenameComponents.count == 3,
                let createdAt = dateFormatter.date(from: filenameComponents[1]),
                let leaksRaw = plist.dict["com.apple.xray.instrument-type.homeleaks"] as? [NSDictionary]
        else { return nil }

        let appName = filenameComponents[0]
        self.appName = appName
        self.createdAt = createdAt
        self.leaks = leaksRaw.compactMap { leakRaw in
            let leak = Leak(dict: leakRaw)
            if retainOnlyAppNameLeaks && leak?.possibleAppName != appName { return nil }
            return leak
        }
    }
}

class Statistics {
    var leaksCountByName: [String: Int]

    init() {
        leaksCountByName = [:]
    }

    func analyze(report: Report) {
        for leak in report.leaks {
            leaksCountByName[leak.id] = (leaksCountByName[leak.id] ?? 0) + leak.count
        }
    }

    func printInfo() {
        if leaksCountByName.count == 0 {
            print("No leaks.")
        } else {
            print("Found leaks:")
            let sortedLeaks = leaksCountByName.enumerated().sorted(by: { $0.1.value >= $1.1.value }).map { $1 }
            for (key, value) in sortedLeaks {
                print(" \(value)x \(key)")
            }
        }
    }

    func save(to url: URL) {
        let out = [
            "leaksCountByName": leaksCountByName
        ]
        let dict = NSDictionary(dictionary: out)
        try! dict.write(to: url)
    }
}

// Helpers ///////////////////////////////////////////////////////////////////////

func print(error: String) {
    fputs("Error: \(error)\n", stderr)
}

func fullPathFromCurrentDirectory(for path: String) -> URL? {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    return URL(fileURLWithPath: path, relativeTo: currentDirectoryURL)
}

func loadPlists(from directoryURL: URL) -> [Plist] {
    let fileManager = FileManager.default
    do {
        let plistsFiles = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        let plists = plistsFiles.compactMap { plistFile -> Plist? in
            guard let dict = NSDictionary(contentsOf: plistFile) else { return nil }
            return Plist(filename: plistFile.lastPathComponent, dict: dict)
        }
        let sortedPlists = plists.sorted(by: { $0.filename < $1.filename })
        return sortedPlists
    } catch {
        print(error: "\(error)")
        exit(1)
    }
    return []
}

// Parse arguments ///////////////////////////////////////////////////////////////////////

guard CommandLine.arguments.count == 3 else {
    print("usage: ParsedTraceToStatistics folder_with_parsed_trace_files output_file_for_statistics")
    exit(1)
}

guard let directoryURL = fullPathFromCurrentDirectory(for: CommandLine.arguments[1]) else {
    print(error: "Invalid path \"\(CommandLine.arguments[1])\" for folder with parsed trace files.")
    exit(1)
}

guard let outputURL = fullPathFromCurrentDirectory(for: CommandLine.arguments[2]) else {
    print(error: "Invalid path \"\(CommandLine.arguments[2])\" for output file for statistics.")
    exit(1)
}

// Create statistics file ///////////////////////////////////////////////////////////////////////

let plists = loadPlists(from: directoryURL)
let reports = plists.compactMap { Report(plist: $0, retainOnlyAppNameLeaks: false) }

let stats = Statistics()
reports.forEach { stats.analyze(report: $0) }
stats.save(to: outputURL)
stats.printInfo()
