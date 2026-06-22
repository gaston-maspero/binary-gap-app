import Foundation

struct BinaryCalculation: Equatable, Codable, Identifiable {

    let id: UUID
    let value: Int
    let binaryRepresentation: String
    let binaryGap: Int
    let createdAt: Date

    init(
        id: UUID = UUID(),
        value: Int,
        binaryRepresentation: String,
        binaryGap: Int,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.value = value
        self.binaryRepresentation = binaryRepresentation
        self.binaryGap = binaryGap
        self.createdAt = createdAt
    }
}
