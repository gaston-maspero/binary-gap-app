import Testing
@testable import BinaryApp

struct BinaryGapCalculatorTests {

    private let subject = BinaryGapCalculator()

    @Test("Returns four for 529 (1000010001)")
    func sample_529() {
        let result = subject.calculate(for: 529)
        #expect(result.binaryRepresentation == "1000010001")
        #expect(result.binaryGap == 4)
    }

    @Test("Returns five for 1041 (10000010001)")
    func sample_1041() {
        let result = subject.calculate(for: 1041)
        #expect(result.binaryRepresentation == "10000010001")
        #expect(result.binaryGap == 5)
    }

    @Test("Returns zero for 15 (1111)")
    func sample_15() {
        let result = subject.calculate(for: 15)
        #expect(result.binaryRepresentation == "1111")
        #expect(result.binaryGap == 0)
    }

    @Test("Returns zero for trailing zeros (32 = 100000)")
    func trailing_zeros_do_not_count() {
        let result = subject.calculate(for: 32)
        #expect(result.binaryRepresentation == "100000")
        #expect(result.binaryGap == 0)
    }

    @Test("Returns zero for single bit (1)")
    func single_bit() {
        let result = subject.calculate(for: 1)
        #expect(result.binaryRepresentation == "1")
        #expect(result.binaryGap == 0)
    }

    @Test("Returns one for the smallest gap (5 = 101)")
    func smallest_gap() {
        let result = subject.calculate(for: 5)
        #expect(result.binaryRepresentation == "101")
        #expect(result.binaryGap == 1)
    }

    @Test("Picks the longest of multiple gaps (561892 has 11 bits, longest gap 8)")
    func multiple_gaps_returns_longest() {
        let value = 0b1000_0010_0000_0100_0001
        let result = subject.calculate(for: value)
        #expect(result.binaryGap == 6)
    }

    @Test("Returns zero for value zero")
    func zero_value() {
        let result = subject.calculate(for: 0)
        #expect(result.binaryGap == 0)
    }

    @Test("Computes the canonical leetcode-style example (9 = 1001 -> 2)")
    func nine() {
        let result = subject.calculate(for: 9)
        #expect(result.binaryGap == 2)
    }

    @Test("Computes 20 = 10100 -> 1")
    func twenty() {
        let result = subject.calculate(for: 20)
        #expect(result.binaryGap == 1)
    }
}
