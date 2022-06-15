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

typealias EdgeInformation = (town: Int, distance: Int)

let fileIO = FileIO()
let numberOfTown = fileIO.readInt()
let numberOfEdge = fileIO.readInt()
let partyTown = fileIO.readInt()
var edgeFor = Array(repeating: [EdgeInformation](), count: numberOfTown + 1)
for _ in 0 ..< numberOfEdge {
    let startingPoint = fileIO.readInt()
    let destination = fileIO.readInt()
    let distance = fileIO.readInt()
    edgeFor[startingPoint].append((destination, distance))
}

// MARK: - Solution

// MARK: Heap

struct Heap<Element> {
    
    // MARK: Property(ies)
    
    private var elements: [Element] = []
    private var comparator: (Element, Element) -> Bool
    var isEmpty: Bool {
        elements.isEmpty
    }
    
    // MARK: Initializer(s)
    
    init(comparator: @escaping (Element, Element) -> Bool) {
        self.comparator = comparator
    }
    
    // MARK: Method(s)
    
    mutating func removeAll() {
        elements.removeAll()
    }
    
    mutating func insert(_ value: Element) {
        elements.append(value)
        compareWithParent(of: elements.endIndex - 1)
    }
    
    private mutating func compareWithParent(of currentIndex: Int) {
        let parentIndex = (currentIndex - 1) / 2
        if 0 <= parentIndex, comparator(elements[currentIndex], elements[parentIndex]) {
            elements.swapAt(parentIndex, currentIndex)
            compareWithParent(of: parentIndex)
        }
    }
    
    mutating func popFront() -> Element? {
        if elements.isEmpty == false {
            elements.swapAt(elements.startIndex, elements.endIndex - 1)
            let element = elements.popLast()
            compareWithChilds(of: elements.startIndex)
            
            return element
        }
        
        return nil
    }
    
    private mutating func compareWithChilds(of currentIndex: Int) {
        let leftChildIndex = currentIndex * 2 + 1
        let rightChildIndex = leftChildIndex + 1
        if rightChildIndex < elements.endIndex {
            if comparator(elements[rightChildIndex], elements[currentIndex]), comparator(elements[leftChildIndex], elements[currentIndex]) {
                if comparator(elements[leftChildIndex], elements[rightChildIndex]) {
                    elements.swapAt(currentIndex, leftChildIndex)
                    compareWithChilds(of: leftChildIndex)
                } else {
                    elements.swapAt(currentIndex, rightChildIndex)
                    compareWithChilds(of: rightChildIndex)
                }
            } else if comparator(elements[rightChildIndex], elements[currentIndex]) {
                elements.swapAt(currentIndex, rightChildIndex)
                compareWithChilds(of: rightChildIndex)
            } else if comparator(elements[leftChildIndex], elements[currentIndex]) {
                elements.swapAt(currentIndex, leftChildIndex)
                compareWithChilds(of: leftChildIndex)
            }
        } else if leftChildIndex < elements.endIndex {
            if comparator(elements[leftChildIndex], elements[currentIndex]) {
                elements.swapAt(currentIndex, leftChildIndex)
                compareWithChilds(of: leftChildIndex)
            }
        }
    }
}

private func dijkstraShortestPathSearch(startingPoint: Int, destination: Int) -> Int {
    var heap = Heap<EdgeInformation> { $0.distance < $1.distance }
    var distanceArray = Array(repeating: Int.max, count: numberOfTown + 1)
    heap.insert((startingPoint, 0))
    distanceArray[startingPoint] = 0
    while heap.isEmpty == false {
        if let front = heap.popFront() {
            if front.distance <= distanceArray[front.town] {
                for next in edgeFor[front.town] {
                    if distanceArray[front.town] + next.distance < distanceArray[next.town] {
                        distanceArray[next.town] = distanceArray[front.town] + next.distance
                        heap.insert((next.town, distanceArray[next.town]))
                    }
                }
            }
        }
    }
    
    return distanceArray[destination]
}

var answer = 0
for town in 1 ... numberOfTown {
    if town != partyTown {
        answer = max(
            answer,
            dijkstraShortestPathSearch(startingPoint: town, destination: partyTown) + dijkstraShortestPathSearch(startingPoint: partyTown, destination: town)
        )
    }
}
print(answer)