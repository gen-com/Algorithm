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
let numberOfGate = fileIO.readInt()
let numberOfPlane = fileIO.readInt()
var planes = Array(repeating: 0, count: numberOfPlane)
for index in planes.indices {
    planes[index] = fileIO.readInt()
}
print(solution(numberOfGate, planes))

// MARK: - Solution

private func findGate(_ gates: inout [Int], _ current: Int) -> Int {
    if gates[current] == current { return current }
    gates[current] = findGate(&gates, gates[current])
    
    return gates[current]
}

private func solution(_ numberOfGate: Int, _ planes: [Int]) -> Int {
    var answer = 0
    var gatesClosed = Array(repeating: false, count: numberOfGate + 1)
    var gates = Array(repeating: 0, count: numberOfGate + 1)
    gatesClosed[0] = true
    for index in 1 ... numberOfGate {
        gates[index] = index
    }
    for plane in planes {
        let candidate = findGate(&gates, plane)
        if gatesClosed[candidate] { break }
        gatesClosed[candidate] = true
        gates[candidate] = 1 < candidate ? candidate - 1 : 1
        answer += 1
    }
    
    return answer
}