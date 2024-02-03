import Foundation

class GameEngine: Engine {
    let blankBoard = (1...4).map { _ in [0,0,0,0] }
    private var points = 0
    private var didReduceFour = false
    
    private var twoOrFour: Int {
        return Int.random(in: .zero...10) < 9 ? 2 : [-2,-4].randomElement() ?? -2
    }
    
    func isGameOver(_ board: Matrix) -> Bool {
        !board.canCombineValues
    }
    
    func addNumber(_ board: Matrix) -> (newBoard: Matrix, addedTile: (Int, Int)?) {
        let emptyTile = board.randomIndex(for: .zero)
        var newBoard = board
        
        if let emptyTile = emptyTile {
            newBoard[emptyTile.row, emptyTile.column] = twoOrFour
        }
        
        return (newBoard, emptyTile)
    }
    
    func slide(_ row: [Int]) -> [Int] {
        let tilesWithNumbers = row.filter { $0 != .zero }
        let emptyTiles = row.count - tilesWithNumbers.count
        let arrayOfZeros = Array(repeating: Int.zero, count: emptyTiles)
        return arrayOfZeros + tilesWithNumbers
    }
    
    func combine(_ row: [Int]) -> [Int] {
        var newRow = row
        for column in (1...row.count - 1).reversed() {
            let prevColumn = column - 1
            let left = newRow[column]
            let right = newRow[prevColumn]
            if left == right {
                newRow[column] = left + right
                newRow[prevColumn] = .zero
                points += left + right
            } else if (left == -right) {
                newRow[column] = left + right
                newRow[prevColumn] = .zero
                didReduceFour = true
                
            }
        }
        return newRow
    }
    
    // 2024 reduction
//    func combine(_ row: [Int]) -> [Int] {
//        var newRow = row
//        for column in (1...row.count - 1).reversed() {
//            let prevColumn = column - 1
//            let left = newRow[column]
//            let right = newRow[prevColumn]
//            if left == right {
//                newRow[column] = left * right
//                newRow[prevColumn] = .zero
//                points += left + right
//            } else if (left > right) {
//                let newvalue = left - right
//                newRow[column] = newvalue > 0 ? newvalue : .zero
//                newRow[prevColumn] = .zero
//                points -= newRow[column]
//                
//            }
//        }
//        return newRow
//    }
    
    func flip(_ board: Matrix) -> Matrix {
        board.map { $0.reversed() }
    }
    
    func rotate(_ board: Matrix) -> Matrix {
        var newBoard = blankBoard
        for row in 0..<board.count {
            for column in 0..<board[row].count {
                newBoard[row][column] = board[column][row]
            }
        }
        return newBoard
    }
    
    func findIndexOfMaxElementAtEdge(_ board: Matrix) -> (row: Int, column: Int)? {
        guard !board.isEmpty, !board[0].isEmpty else {
            return nil // Matrix is empty
        }

        var maxElement = board[0][0]
        var maxRowIndex = 0
        var maxColIndex = 0

        for i in (0..<board.count) {
            if let maxInRow = board[i].max(), maxInRow > maxElement {
                maxElement = maxInRow
                maxRowIndex = i
                
                let firstIndex = board[i].firstIndex(of: maxInRow) ?? 0
                let lastIndex = board[i].lastIndex(of: maxInRow) ?? 0
                if lastIndex == board[i].count - 1 {
                    maxColIndex = lastIndex
                } else if (firstIndex == 0) {
                    maxColIndex = 0
                } else {
                    maxColIndex = max(firstIndex, lastIndex)
                }
            }
        }

        return (row: maxRowIndex, column: maxColIndex)
    }
    
    private func operateRows(_ board: Matrix) -> Matrix {
        board.map(slideAndCombine)
    }
    
    func push(_ board: Matrix, to direction: Direction) -> (newBoard: Matrix, scoredPoints: Int) {
        var newBoard = board
        points = .zero
        
        switch direction {
        case .right: newBoard = (board |> pushRight)
        case .up:    newBoard = (board |> pushUp)
        case .left:  newBoard = (board |> pushLeft)
        case .down:  newBoard = (board |> pushDown)
        }
        
//        if didReduceFour {
//            didReduceFour = false
//            return (doubleMaxElement(newBoard), points)
//        }
        
        return (newBoard, points)
    }
    
    func doubleMaxElement(_ board: Matrix) -> Matrix {
        var newBoard = board
        if let maxIndex = findIndexOfMaxElementAtEdge(board) {
            newBoard[maxIndex.row][maxIndex.column] /= 2
        }
        return newBoard
    }

    
    private func slideAndCombine(_ row: [Int]) -> [Int] {
        row
            |> slide
            |> combine
            |> slide
    }
    
    private func pushUp(_ board: Matrix) -> Matrix {
        board
            |> rotate
            |> flip
            |> operateRows
            |> flip
            |> rotate
    }
    
    private func pushDown(_ board: Matrix) -> Matrix {
        board
            |> rotate
            |> operateRows
            |> rotate
    }
    
    private func pushLeft(_ board: Matrix) -> Matrix {
        board
            |> flip
            |> operateRows
            |> flip
    }
    
    private func pushRight(_ board: Matrix) -> Matrix {
        board
            |> operateRows
    }
}
