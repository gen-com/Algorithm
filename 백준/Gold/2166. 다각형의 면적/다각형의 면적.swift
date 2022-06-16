import Foundation

// MARK: - Thanks to Wapas

final class FileIO {
    
    private let buffer:[UInt8]
    private var index: Int = 0

    init(fileHandle: FileHandle = FileHandle.standardInput) {
        buffer = Array(try! fileHandle.readToEnd()!)+[UInt8(0)]
    }

    @inline(__always) private func read() -> UInt8 {
        defer { index += 1 }

        return buffer[index]
    }

    @inline(__always) func readInt() -> Int {
        var sum = 0
        var now = read()
        var isPositive = true
        while now == 10 || now == 32 { now = read() }
        if now == 45 { isPositive.toggle(); now = read() }
        while now >= 48, now <= 57 {
            sum = sum * 10 + Int(now-48)
            now = read()
        }

        return sum * (isPositive ? 1 : -1)
    }

    @inline(__always) func readString() -> String {
        var now = read()
        while now == 10 || now == 32 { now = read() }
        let beginIndex = index-1
        while now != 10, now != 32, now != 0 { now = read() }

        return String(bytes: Array(buffer[beginIndex ..< (index-1)]), encoding: .ascii)!
    }
    
    @inline(__always) func readStirngSum() -> Int {
        var byte = read()
        while byte == 10 || byte == 32 { byte = read() }
        var sum = Int(byte)
        while byte != 10 && byte != 32 && byte != 0 { byte = read(); sum += Int(byte) }
        
        return sum - Int(byte)
    }
}

// MARK: - Input

let fileIO = FileIO()
let numberOfAngle = fileIO.readInt()

// MARK: - Solution

typealias Point = (x: Int, y: Int)
var pivot: Point = (0, 0)

func product(lhs: Point, rhs: Point) -> Double {
    Double((lhs.x - pivot.x) * (rhs.y - pivot.y) - (lhs.y - pivot.y) * (rhs.x - pivot.x)) / 2.0
}

var answer = 0.0
var prevPoint: Point = (0, 0)
for count in 0 ..< numberOfAngle {
    let x = fileIO.readInt()
    let y = fileIO.readInt()
    if count == 0 {
        pivot = (x, y)
    } else if count == 1 {
        prevPoint = (x, y)
    } else {
        answer += product(lhs: prevPoint, rhs: (x, y))
        prevPoint = (x, y)
    }
}
print(String(format: "%.1f", round(abs(answer) * 10) / 10))
