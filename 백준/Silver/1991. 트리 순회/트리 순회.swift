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
let numberOfNodes = fileIO.readInt()
var tree: [String: [String]] = [:]
for _ in 0 ..< numberOfNodes {
    let currentNode = fileIO.readString()
    let leftChildNode = fileIO.readString()
    let rightChildNode = fileIO.readString()
    tree[currentNode] = [leftChildNode, rightChildNode]
}

// MARK: - Solution

private func preorderTraversal(of tree: [String: [String]], current: String) -> String {
    var result = current
    if tree[current]!.first! != "." {
        result += preorderTraversal(of: tree, current: tree[current]!.first!)
    }
    if tree[current]!.last! != "." {
        result += preorderTraversal(of: tree, current: tree[current]!.last!)
    }
    
    return result
}

private func inorderTraversal(of tree: [String: [String]], current: String) -> String {
    var result = ""
    if tree[current]!.first! != "." {
        result += inorderTraversal(of: tree, current: tree[current]!.first!)
    }
    result += current
    if tree[current]!.last! != "." {
        result += inorderTraversal(of: tree, current: tree[current]!.last!)
    }
    
    return result
}

private func postorderTraversal(of tree: [String: [String]], current: String) -> String {
    var result = ""
    if tree[current]!.first! != "." {
        result += postorderTraversal(of: tree, current: tree[current]!.first!)
    }
    if tree[current]!.last! != "." {
        result += postorderTraversal(of: tree, current: tree[current]!.last!)
    }
    result += current
    
    return result
}

print(preorderTraversal(of: tree, current: "A"))
print(inorderTraversal(of: tree, current: "A"))
print(postorderTraversal(of: tree, current: "A"))