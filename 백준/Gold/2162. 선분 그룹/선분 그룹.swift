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
typealias Line = (lhs: Point, rhs: Point)

let fileIO = FileIO()
let numberOfLine = fileIO.readInt()
var lines = Array(repeating: Line((0, 0), (0, 0)), count: numberOfLine)
for index in lines.indices {
    lines[index] = Line((fileIO.readInt(), fileIO.readInt()), (fileIO.readInt(), fileIO.readInt()))
}
print(solution(lines))

// MARK: - Solution

private func ccw(_ firstPoint: Point, _ secondPoint: Point, _ thirdPoint: Point) -> Int {
    let lhsVector: Point = (secondPoint.x - firstPoint.x, secondPoint.y - firstPoint.y)
    let rhsVector: Point = (thirdPoint.x - firstPoint.x, thirdPoint.y - firstPoint.y)
    let result = lhsVector.x * rhsVector.y - lhsVector.y * rhsVector.x
    if result < 0 {
        return -1
    } else if 0 < result {
        return 1
    } else {
        return 0
    }
}

@discardableResult
private func findRoot(_ root: inout [Int], current: Int) -> Int {
    if root[current] == current {
        return current
    }
    root[current] = findRoot(&root, current: root[current])
    
    return root[current]
}

private func solution(_ lines: [Line]) -> String {
    var root = Array(repeating: 0, count: lines.count)
    for index in root.indices {
        root[index] = index
    }
    for outerIndex in lines.indices {
        for innerIndex in lines.indices {
            if innerIndex <= outerIndex { continue }
            let firstCCW = ccw(lines[outerIndex].lhs, lines[outerIndex].rhs, lines[innerIndex].lhs)
            let secondCCW = ccw(lines[outerIndex].lhs, lines[outerIndex].rhs, lines[innerIndex].rhs)
            if 0 < firstCCW * secondCCW { continue }
            let thirdCCW = ccw(lines[innerIndex].lhs, lines[innerIndex].rhs, lines[outerIndex].lhs)
            let fourthCCW = ccw(lines[innerIndex].lhs, lines[innerIndex].rhs, lines[outerIndex].rhs)
            if 0 < thirdCCW * fourthCCW { continue }
            if firstCCW * secondCCW == 0, thirdCCW * fourthCCW == 0 {
                var firstSmall: Point = (0, 0)
                var firstLarge: Point = (0, 0)
                var secondSmall: Point = (0, 0)
                var secondLarge: Point = (0, 0)
                if lines[outerIndex].rhs <= lines[outerIndex].lhs {
                    firstSmall = lines[outerIndex].rhs
                    firstLarge = lines[outerIndex].lhs
                } else {
                    firstSmall = lines[outerIndex].lhs
                    firstLarge = lines[outerIndex].rhs
                }
                if lines[innerIndex].rhs <= lines[innerIndex].lhs {
                    secondSmall = lines[innerIndex].rhs
                    secondLarge = lines[innerIndex].lhs
                } else {
                    secondSmall = lines[innerIndex].lhs
                    secondLarge = lines[innerIndex].rhs
                }
                if secondLarge < firstSmall { continue }
                if firstLarge < secondSmall { continue }
            }
            let outerRoot = findRoot(&root, current: outerIndex)
            let innerRoot = findRoot(&root, current: innerIndex)
            if outerRoot == innerRoot { continue }
            if outerRoot < innerRoot {
                root[innerRoot] = outerRoot
            } else {
                root[outerRoot] = innerRoot
            }
        }
    }
    var dict: [Int: Int] = [:]
    for index in root.indices {
        findRoot(&root, current: index)
    }
    for root in root {
        if let count = dict[root] {
            dict[root] = count + 1
        } else {
            dict[root] = 1
        }
    }
    
    return "\(dict.count)\n\(dict.sorted { $1.value < $0.value }.first!.value)"
}