import XCTest
@testable import ByteCoder

struct FlagsOptionSet : OptionSet, Codable {
    let rawValue: Int16
    
    static let flagA   = FlagsOptionSet(rawValue: 1 << 0)
    static let flagB   = FlagsOptionSet(rawValue: 1 << 1)
    static let flagC   = FlagsOptionSet(rawValue: 1 << 2)
}

struct StructA : Codable {
    var a: UInt8
    var b: Int16
}

struct StructB : Codable {
    var stuctA: StructA
    var str: String
    var flags: FlagsOptionSet
}

struct StructC : Encodable {
    var count: Int
    var array: [StructA]
    var str: String
    var flags: FlagsOptionSet
}

extension StructC : Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        self.count = try container.decode()
        self.array = [StructA]()
        for _ in 0..<self.count {
            self.array.append(try container.decode())
        }
        
        self.str = try container.decode()
        self.flags = try container.decode()
    }
}

final class ByteCoderTests: XCTestCase {
    
    func testByteEncoder() {
        
        let encoder = ByteEncoder()
        
        let structB = StructB(stuctA: StructA(a: 7, b: 8),
                              str: "012",
                              flags: [.flagA, .flagC])
        
        var structC = StructC(count: 0,
                              array: [],
                              str: "0123",
                              flags: [.flagB])
        
        structC.array.append(StructA(a: 1, b: 2))
        structC.array.append(StructA(a: 3, b: 4))

        // needed for decoding
        structC.count = structC.array.count
        
        try! structB.encode(to: encoder)
        
        //print("data:", encoder.encodedData)
        XCTAssertEqual(encoder.encodedData, [7, 8, 0, 48, 49, 50, 0, 5, 0])
        
        encoder.removeEncodedData()
        
        try! structC.encode(to: encoder)

        //print("data:", encoder.encodedData)
        XCTAssertEqual(encoder.encodedData, [2, 0, 0, 0, 0, 0, 0, 0, 1, 2, 0, 3, 4, 0, 48, 49, 50, 51, 0, 2, 0])
    }

    func testByteDecoder() {
        
        var data: [UInt8] = [7, 8, 0, 48, 49, 50, 0, 5, 0]
        var decoder = ByteDecoder(data: data)
        
        let structB = try! StructB(from: decoder)
        
        XCTAssertEqual(structB.stuctA.a, 7)
        XCTAssertEqual(structB.stuctA.b, 8)
        XCTAssertEqual(structB.str, "012")
        XCTAssert(structB.flags == [.flagA, .flagC])
        
        data = [2, 0, 0, 0, 0, 0, 0, 0, 1, 2, 0, 3, 4, 0, 48, 49, 50, 51, 0, 2, 0]
        decoder = ByteDecoder(data: data)
        
        let structC = try! StructC(from: decoder)
        
        XCTAssertEqual(structC.count, 2)
        XCTAssertEqual(structC.array[0].a, 1)
        XCTAssertEqual(structC.array[0].b, 2)
        XCTAssertEqual(structC.array[1].a, 3)
        XCTAssertEqual(structC.array[1].b, 4)
        XCTAssertEqual(structC.str, "0123")
        XCTAssert(structC.flags == .flagB)
    }
    
    static var allTests = [
        ("testByteEncoder", testByteEncoder),
        ("testByteDecoder", testByteDecoder),
    ]
}
