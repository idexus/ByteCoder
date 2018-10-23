# ByteCoder

Byte (UInt8) Coder for the Swift Programming Language.

## Simple usage case

```swift
struct StructA : Codable {
    var a: UInt8
    var b: Int16
}
```

### Encoding

```swift
let encoder = ByteEncoder()

var structA = StructA(a: 7, b: 8)
try! structA.encode(to: encoder)
```

Encoded data: [UInt8]

```swift
print("data:", encoder.encodedData)
```


### Decoding

```swift
let data: [UInt8] = [7, 8, 0]
let decoder = ByteDecoder(data: data)

let structA = try! StructA(from: decoder)
```

## Decoding enums (binary flags)

https://github.com/idexus/BinaryFlags

Declaration:

```swift
enum TestFlags : UInt16, BinaryFlagBits {
    case flagA = 1
    case flagB = 2
    case flagC = 4
}

struct StructA : Codable {
    var a: UInt8
    var b: Int16
}

struct StructB : Codable {
    var stuctA: StructA
    var str: String
    var flags: BinaryFlags<TestFlags>
}
```

## Decoding arrays

Declaration:

```swift
struct StructC : Encodable {
    var count: Int
    var array: [StructA]
    var str: String
    var flags: BinaryFlags<TestFlags>
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
```
