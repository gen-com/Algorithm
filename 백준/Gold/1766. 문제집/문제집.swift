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

typealias Prereq = (before: Int, after: Int)

let fileIO = FileIO()
let numberOfQuestion = fileIO.readInt()
let numberOfPrereq = fileIO.readInt()
var prereq = Array(repeating: Prereq(0, 0), count: numberOfPrereq)
for index in 0 ..< numberOfPrereq {
    prereq[index] = (fileIO.readInt(), fileIO.readInt())
}
print(solution(numberOfQuestion, prereq))

// MARK: - Solution

struct Heap<Element> {
    
    private var elements: [Element]
    private let comparator: (Element, Element) -> Bool
    
    var isEmpty: Bool {
        elements.isEmpty
    }
    
    init(comparator: @escaping (Element, Element) -> Bool) {
        elements = []
        self.comparator = comparator
    }
    
    mutating func insert(_ element: Element) {
        elements.append(element)
        if 1 < elements.count {
            compareWithParent(currentIndex: elements.endIndex - 1)
        }
    }
    
    private mutating func compareWithParent(currentIndex: Int) {
        let parentIndex = (currentIndex - 1) / 2
        if parentIndex < 0 { return }
        if comparator(elements[currentIndex], elements[parentIndex]) {
            elements.swapAt(currentIndex, parentIndex)
            compareWithParent(currentIndex: parentIndex)
        }
    }
    
    @discardableResult
    mutating func popFront() -> Element? {
        if elements.isEmpty { return nil }
        elements.swapAt(elements.startIndex, elements.endIndex - 1)
        let last = elements.popLast()
        compareWithChildren(currentIndex: elements.startIndex)
        
        return last
    }
    
    private mutating func compareWithChildren(currentIndex: Int) {
        let leftChildIndex = currentIndex * 2 + 1
        let rightChildIndex = leftChildIndex + 1
        if rightChildIndex < elements.endIndex {
            if comparator(elements[leftChildIndex], elements[currentIndex]), comparator(elements[rightChildIndex], elements[currentIndex]) {
                if comparator(elements[leftChildIndex], elements[rightChildIndex]) {
                    elements.swapAt(currentIndex, leftChildIndex)
                    compareWithChildren(currentIndex: leftChildIndex)
                } else {
                    elements.swapAt(currentIndex, rightChildIndex)
                    compareWithChildren(currentIndex: rightChildIndex)
                }
            } else if comparator(elements[leftChildIndex], elements[currentIndex]) {
                elements.swapAt(currentIndex, leftChildIndex)
                compareWithChildren(currentIndex: leftChildIndex)
            } else if comparator(elements[rightChildIndex], elements[currentIndex]) {
                elements.swapAt(currentIndex, rightChildIndex)
                compareWithChildren(currentIndex: rightChildIndex)
            }
        } else if leftChildIndex < elements.endIndex {
            if comparator(elements[leftChildIndex], elements[currentIndex]) {
                elements.swapAt(currentIndex, leftChildIndex)
                compareWithChildren(currentIndex: leftChildIndex)
            }
        }
    }
}

private func solution(_ numberOfQuestion: Int, _ prereq: [Prereq]) -> String {
    var answer = ""
    var postreqFor = Array(repeating: [Int](), count: numberOfQuestion + 1)
    var preCount = Array(repeating: 0, count: numberOfQuestion + 1)
    var heap = Heap<Int>(comparator: <)
    for prereq in prereq {
        postreqFor[prereq.before].append(prereq.after)
        preCount[prereq.after] += 1
    }
    for index in 1 ... numberOfQuestion {
        if preCount[index] == 0 {
            heap.insert(index)
        }
    }
    while heap.isEmpty == false {
        if let front = heap.popFront() {
            answer += "\(front) "
            for post in postreqFor[front] {
                preCount[post] -= 1
                if preCount[post] == 0 {
                    heap.insert(post)
                }
            }
        }
    }
    let _ = answer.popLast()
    
    return answer
}