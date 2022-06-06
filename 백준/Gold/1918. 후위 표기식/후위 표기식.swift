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
let inorderNotation = fileIO.readString()

// MARK: - Solution

var postfixNotation = ""
var operatorStack: [String] = []

for element in inorderNotation {
    if element.isLetter {
        postfixNotation.append(element)
    } else {
        if operatorStack.isEmpty {
            operatorStack.append(String(element))
        } else {
            while operatorStack.isEmpty == false {
                if let top = operatorStack.last {
                    if ((top == "+" || top == "-") && (element == "*" || element == "/")) || element == "(" {
                        break
                    } else if top == "(" {
                        if element == ")" {
                            let _ = operatorStack.popLast()
                            break
                        } else {
                            break
                        }
                    } else {
                        if let top = operatorStack.popLast() {
                            postfixNotation += top
                        }
                    }
                }
            }
            if element != ")" {
                operatorStack.append(String(element))
            }
        }
    }
}
while operatorStack.isEmpty == false {
    if let top = operatorStack.popLast(), top != ")"  {
        postfixNotation += top
    }
}
print(postfixNotation)