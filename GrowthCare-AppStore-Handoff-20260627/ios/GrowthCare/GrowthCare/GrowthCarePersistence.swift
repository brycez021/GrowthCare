import Foundation

struct GrowthCareSnapshot: Equatable, Codable {
    var activeChildID: String
    var children: [ChildProfile]
    var childData: [String: ChildData]
    var clinics: [Clinic]
    var parentProfile: ParentProfile
    var reminderSettings: ReminderSettings
    var sharedMembers: [SharedMember]
}

protocol GrowthCarePersistence {
    func loadSnapshot() -> GrowthCareSnapshot?
    func saveSnapshot(_ snapshot: GrowthCareSnapshot)
}

final class InMemoryGrowthCarePersistence: GrowthCarePersistence {
    private var snapshot: GrowthCareSnapshot?

    func loadSnapshot() -> GrowthCareSnapshot? {
        snapshot
    }

    func saveSnapshot(_ snapshot: GrowthCareSnapshot) {
        self.snapshot = snapshot
    }
}

final class FileGrowthCarePersistence: GrowthCarePersistence {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(fileManager: FileManager = .default, fileName: String = "growthcare-state-v1.json") {
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        self.fileURL = directory.appendingPathComponent(fileName)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func loadSnapshot() -> GrowthCareSnapshot? {
        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(GrowthCareSnapshot.self, from: data)
        } catch {
            #if DEBUG
            if (error as NSError).code != NSFileReadNoSuchFileError {
                print("GrowthCare persistence load failed: \(error)")
            }
            #endif
            return nil
        }
    }

    func saveSnapshot(_ snapshot: GrowthCareSnapshot) {
        do {
            let data = try encoder.encode(snapshot)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            #if DEBUG
            print("GrowthCare persistence save failed: \(error)")
            #endif
        }
    }
}
