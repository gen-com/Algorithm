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

// MARK: - Trie

class TrieNode {
    
    var key: String
    weak var parent: TrieNode?
    var children: [String: TrieNode]
    var isLast: Bool
    
    init(key: String, parent: TrieNode?) {
        self.key = key
        self.parent = parent
        children = [:]
        isLast = false
    }
}

struct Trie {
    
    // MARK: Property(ies)
    
    let root = TrieNode(key: "", parent: nil)
    var traversalResult = ""
    
    // MARK: Method(s)
    
    func insert(_ elements: [String]) {
        var current = root
        for element in elements {
            if let childNode = current.children[element] {
                current = childNode
            } else {
                let newNode = TrieNode(key: element, parent: current)
                current.children[element] = newNode
                current = newNode
            }
        }
        current.isLast = true
    }
    
    private mutating func next(_ current: TrieNode, prefix: String) {
        traversalResult += "\(prefix + current.key)\n"
        let keys = current.children.keys.sorted()
        for key in keys {
            if let children = current.children[key] {
                next(children, prefix: prefix + "--")
            }
        }
    }
    
    mutating func traversal() -> String {
        traversalResult = ""
        let keys = root.children.keys.sorted()
        for key in keys {
            if let children = root.children[key] {
                next(children, prefix: "")
            }
        }
        let _ = traversalResult.popLast()
        
        return traversalResult
    }
}

// MARK: - Input

typealias Edge = (lhs: Int, rhs: Int)

let fileIO = FileIO()
let numberOfLayer = fileIO.readInt()
var trie = Trie()
for _ in 0 ..< numberOfLayer {
    var elements: [String] = []
    for _ in 0 ..< fileIO.readInt() {
        elements.append(fileIO.readString())
    }
    trie.insert(elements)
}

// MARK: - Solution

private func solution(_ trie: inout Trie) -> String {
    trie.traversal()
}
print(solution(&trie))