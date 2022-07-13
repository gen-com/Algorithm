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
let firstPoint = Point(fileIO.readInt(), fileIO.readInt())
let secondPoint = Point(fileIO.readInt(), fileIO.readInt())
let thirdPoint = Point(fileIO.readInt(), fileIO.readInt())
print(solution(firstPoint, secondPoint, thirdPoint))

// MARK: - Solution

private func solution(_ first: Point, _ second: Point, _ third: Point) -> Int {
    let lhsVector: Point = (second.x - first.x, second.y - first.y)
    let rhsVector: Point = (third.x - first.x, third.y - first.y)
    if 0 < lhsVector.x * rhsVector.y - lhsVector.y * rhsVector.x {
        return 1
    } else if lhsVector.x * rhsVector.y - lhsVector.y * rhsVector.x < 0 {
        return -1
    } else {
        return 0
    }
}