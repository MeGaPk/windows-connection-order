import Testing

@Suite
struct NetworkManagerSmokeTests {
    @Test
    func testUppercasingString() {
        #expect("swift pipeline".uppercased() == "SWIFT PIPELINE")
    }

    @Test
    func testSetContainsElementAfterInsert() {
        var seen = Set<Int>()
        seen.insert(1)

        #expect(seen.contains(1))
        #expect(seen.count == 1)
    }
}
