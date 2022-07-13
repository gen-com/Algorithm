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

typealias Point = (x: Int, y: Int)

let fileIO = FileIO()
var firstLine = (start: (x: fileIO.readInt(), y: fileIO.readInt()), end: (x: fileIO.readInt(), y: fileIO.readInt()))
var secondLine = (start: (x: fileIO.readInt(), y: fileIO.readInt()), end: (x: fileIO.readInt(), y: fileIO.readInt()))
print(solution(&firstLine, &secondLine) ? 1 : 0)

// MARK: - Solution

private func ccw(p1: Point, p2: Point, p3: Point) -> Int {
    let result = (p1.x * p2.y + p2.x * p3.y + p3.x * p1.y) - (p2.x * p1.y + p3.x * p2.y + p1.x * p3.y)
    if 0 < result {
        return 1
    } else if result < 0 {
        return -1
    } else {
        return 0
    }
}

private func solution(_ first: inout (start: Point, end: Point), _ second: inout (start: Point, end: Point)) -> Bool {
    let result1 = ccw(p1: first.start, p2: first.end, p3: second.start) * ccw(p1: first.start, p2: first.end, p3: second.end)
    let result2 = ccw(p1: second.start, p2: second.end, p3: first.start) * ccw(p1: second.start, p2: second.end, p3: first.end)
    if result1 <= 0, result2 <= 0 {
        if result1 == 0, result2 == 0 {
            if(first.end <= first.start) {
                swap(&first.start, &first.end)
            }
            if(second.end <= second.start) {
                swap(&second.start, &second.end)
            }
                        
            return first.start <= second.end && second.start <= first.end
        } else {
            return true
        }
    }
    
    return false
}