import Foundation

let input = readLine()!.components(separatedBy: " ").map { Int($0)! }
var cableLines: [Int] = []

func binarySearch(_ start: Int, _ end: Int, _ target: Int) -> Int {
    if end <= start {
        
        return end
    } else {
        let midValue = (start + end) / 2
        if target <= cableLines.reduce(0, { $0 + ($1 / midValue) }) {
            if target <= cableLines.reduce(0, { $0 + ($1 / (midValue + 1)) }) {
                
                return binarySearch(midValue + 1, end, target)
            } else {
                
                return midValue
            }
        } else {
            
            return binarySearch(start, midValue - 1, target)
        }
    }
}

for _ in 0 ..< input[0] {
    let cableLine = Int(readLine()!)!
    cableLines.append(cableLine)
}
print(binarySearch(1, cableLines.max()!, input[1]))