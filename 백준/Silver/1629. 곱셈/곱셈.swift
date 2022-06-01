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
let a = fileIO.readInt()
let b = fileIO.readInt()
let c = fileIO.readInt()

// MARK: - Solution

var answer = 1

private func power(of number: Int, exponent: Int, mod: Int) -> Int {
    if exponent == 0 {
        
        return 1
    } else {
        if exponent % 2 == 0 {
            let tmp = power(of: number, exponent: exponent / 2, mod: mod) % mod
            
            return tmp * tmp % mod
        } else {
            let tmp = power(of: number, exponent: exponent / 2, mod: mod) % mod
            
            return tmp * tmp % mod * (number % mod) % mod
        }
    }
}

print(power(of: a, exponent: b, mod: c))