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

typealias EdgeInformation = (lhsNode: Int, rhsNode: Int, weight: Int)

let fileIO = FileIO()
let firstStringArray = fileIO.readString().map { String($0) }
let secondStringArray = fileIO.readString().map { String($0) }
    
// MARK: - Solution

private func solution(_ first: [String], _ second: [String]) {
    var lcs = Array(repeating: Array(repeating: 0, count: second.count + 1), count: first.count + 1)
    for firstIndex in 1 ... first.count {
        for secondIndex in 1 ... second.count {
            if first[firstIndex - 1] == second[secondIndex - 1] {
                lcs[firstIndex][secondIndex] = lcs[firstIndex - 1][secondIndex - 1] + 1
            } else {
                lcs[firstIndex][secondIndex] = max(lcs[firstIndex - 1][secondIndex], lcs[firstIndex][secondIndex - 1])
            }
        }
    }
    
    var firstIndex = first.endIndex
    var secondIndex = second.endIndex
    var lcsString = ""
    while lcs[firstIndex][secondIndex] != 0 {
        if lcs[firstIndex][secondIndex] == lcs[firstIndex - 1][secondIndex] {
            firstIndex -= 1
        } else if lcs[firstIndex][secondIndex] == lcs[firstIndex][secondIndex - 1] {
            secondIndex -= 1
        } else {
            firstIndex -= 1
            secondIndex -= 1
            lcsString += first[firstIndex]
        }
    }
    print(lcs[first.endIndex][second.endIndex])
    if lcsString.isEmpty == false {
        print(String(lcsString.reversed()))
    }
}
solution(firstStringArray, secondStringArray)