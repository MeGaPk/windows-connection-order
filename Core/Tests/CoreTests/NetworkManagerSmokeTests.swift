import Domain
import Testing

@Suite
struct NetworkManagerSmokeTests {
    @Test
    func ipv4AddressPreservesItsValue() {
        let address = IPv4Address("192.168.1.1")

        #expect(address.rawValue == "192.168.1.1")
        #expect(address.description == "192.168.1.1")
    }

    @Test
    func networkAdapterIdentityUsesLuid() {
        let first = NetworkAdapter.ID(luid: 42)
        let second = NetworkAdapter.ID(luid: 42)

        #expect(first == second)
        #expect(first.luid == 42)
    }
}
