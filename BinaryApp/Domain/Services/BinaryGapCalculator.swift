import Foundation

protocol BinaryGapCalculating {
    func calculate(for value: Int) -> BinaryCalculation
}

struct BinaryGapCalculator: BinaryGapCalculating {

    func calculate(for value: Int) -> BinaryCalculation {
        let representation = Self.binaryString(for: value)
        let gap = Self.longestBinaryGap(in: value)
        return BinaryCalculation(
            value: value,
            binaryRepresentation: representation,
            binaryGap: gap
        )
    }

    // MARK: - Algorithm

    /// Scans the binary representation bit by bit, tracking the longest run of zeros
    /// that has been closed by a trailing one. Runs in O(log n) without converting
    /// the number to a string.
    private static func longestBinaryGap(in value: Int) -> Int {
        guard value > 0 else { return 0 }

        var remaining = value
        var longest = 0
        var currentRun = 0
        var hasSeenLeadingOne = false

        while remaining > 0 {
            let bit = remaining & 1
            if bit == 1 {
                if hasSeenLeadingOne {
                    longest = max(longest, currentRun)
                }
                hasSeenLeadingOne = true
                currentRun = 0
            } else if hasSeenLeadingOne {
                currentRun += 1
            }
            remaining >>= 1
        }

        return longest
    }

    private static func binaryString(for value: Int) -> String {
        guard value > 0 else { return "0" }
        return String(value, radix: 2)
    }
}
