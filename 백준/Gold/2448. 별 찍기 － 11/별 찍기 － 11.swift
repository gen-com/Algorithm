import Foundation

var size: Int = Int(readLine()!)!

var beforeStar: [String] = []
var currentStar: [String] = ["  *  ", " * * ", "*****"]
var blank: String = "   "
let initNum: Int = 6
var answer = ""

func makeStar(_ n: Int) {
    if n == size {
        for i in 0..<n/2 {
            answer += (blank + currentStar[i] + blank + "\n")
        }
        for i in 0..<n/2 {
            answer += (currentStar[i] + " " + currentStar[i] + "\n")
        }
        return
    }
    
    beforeStar = currentStar
    currentStar = []
    for i in 0..<n/2 {
        currentStar.append(blank + beforeStar[i] + blank)
    }
    for i in 0..<n/2 {
        currentStar.append(beforeStar[i] + " " + beforeStar[i])
    }
    blank += blank
    makeStar(2*n)
}

switch size {
case 3: print("  *  \n" + " * * \n" + "*****")
default: makeStar(initNum); print(answer)
}