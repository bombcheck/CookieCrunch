//
//  Level.swift
//  CookieCrunch
//
//  Created by Nils Bernhardt on 17.06.16.
//  Copyright © 2016 Nils Bernhardt. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9
let NumLevels = 5

class Level {
    private var cookies = Array2D<Cookie>(columns: NumColumns, rows: NumRows)
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    private var possibleSwaps = Set<Swap>()
    
    var targetScore = 0
    var maximumMoves = 0
    private var comboMultiplier = 0
    
    
    private func createInitialCookies() -> Set<Cookie> {
        var set = Set<Cookie>()
        
        // 1: Loop through rows and columns of 2D Array
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if tiles[column, row] != nil {
                    // 2: Select random CookieType
                    //var cookieType = CookieType.random()
                    var cookieType: CookieType
                    repeat {
                        cookieType = CookieType.random()
                    } while (column >= 2 &&
                        cookies[column - 1, row]?.cookieType == cookieType &&
                        cookies[column - 2, row]?.cookieType == cookieType)
                       || (row >= 2 &&
                        cookies[column, row - 1]?.cookieType == cookieType &&
                        cookies[column, row - 2]?.cookieType == cookieType)
            
                    // 3: Create new cookie object and add to array
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
            
                    // 4: Add new cookie object to Set
                    set.insert(cookie)
                }
            }
        }
    return set
    }
    
    private func hasChainAtColumn(column: Int, row: Int) -> Bool {
        let cookieType = cookies[column, row]!.cookieType
        
        // Horizontal chain check
        var horzLength = 1
        
        // Left
        var i = column - 1
        while i >= 0 && cookies[i, row]?.cookieType == cookieType {
            i -= 1
            horzLength += 1
        }
        
        // Right
        i = column + 1
        while i < NumColumns && cookies[i, row]?.cookieType == cookieType {
            i += 1
            horzLength += 1
        }
        if horzLength >= 3 { return true }
        
        // Vertical chain check
        var vertLenght = 1
        
        // Down
        i = row - 1
        while i >= 0 && cookies[column, i]?.cookieType == cookieType {
            i -= 1
            vertLenght += 1
        }
        
        // Up
        i = row + 1
        while i < NumRows && cookies[column, i]?.cookieType == cookieType {
            i += 1
            vertLenght += 1
        }
        return vertLenght >= 3
    }
    
    private func detectHorizontalMatches() -> Set<Chain> {
        // 1: Create new set to hold horizontal chains
        var set = Set<Chain>()
        
        // 2: Loop through rows and columns
        for row in 0..<NumRows {
            var column = 0
            while column < NumColumns-2 {
                // 3: Skip gaps in level design
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType
                    
                    // 4: Check if the next two columns have the same cookie type
                    if cookies[column + 1, row]?.cookieType == matchType &&
                       cookies[column + 2, row]?.cookieType == matchType {
                        // 5: We have a chain of at least 3 cookies of the same type. Check if there are more.
                        let chain = Chain(chainType: .Horizontal)
                        repeat {
                            chain.addCookie(cookies[column, row]!)
                            column += 1
                        } while column < NumColumns && cookies[column, row]?.cookieType == matchType
                        
                        set.insert(chain)
                        continue
                    }
                }
            // 6: If the next tweo cookies do not match the current one ore if there is an empty tile: Skip
            column += 1
            }
        }
        return set
    }

    private func detectVerticalMatches() -> Set<Chain> {
        // 1
        var set = Set<Chain>()
        
        // 2
        for column in 0..<NumColumns {
            var row = 0
            while row < NumRows-2 {
                // 3
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType
                    
                    // 4
                    if cookies[column, row + 1]?.cookieType == matchType &&
                        cookies[column, row + 2]?.cookieType == matchType {
                        let chain = Chain(chainType: .Vertical)
                        repeat {
                            chain.addCookie(cookies[column, row]!)
                            row += 1
                        } while row < NumRows && cookies[column, row]?.cookieType == matchType
                        
                        set.insert(chain)
                        continue
                    }
                }
                // 6
                row += 1
            }
        }
        return set
    }
    
    private func removeCookie(chains: Set<Chain>) {
        for chain in chains {
            for cookie in chain.cookies {
                cookies[cookie.column, cookie.row] = nil
            }
        }
    }
    
    private func calculateScores(chains: Set<Chain>) {
        // 3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on
        for chain in chains {
            chain.score = 60 * (chain.length - 2) * comboMultiplier
            comboMultiplier += 1
        }
    }
    
    init(filename: String) {
        // 1: Load the named file into Dictionary
        guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) else {
            print("Error loading JSON")
            return
        }
        // 2: Get Tiles-Description from JSON
        guard let tilesArray = dictionary["tiles"] as? [[Int]] else {
            print("Error parsing tiles-array in json-file")
            return
        }
        // 3:
        for (row, rowArray) in tilesArray.enumerate() {
            // 4
            let tileRow = NumRows - row - 1
            
            for (column, value) in rowArray.enumerate() {
                if value == 1 {
                    tiles[column, tileRow] = Tile()
                }
            }
        }
        
        targetScore = dictionary["targetScore"] as! Int
        maximumMoves = dictionary["moves"] as! Int
    }
    
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    func cookieAtColumn(column: Int, row: Int) -> Cookie? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return cookies[column, row]
    }
    
    func shuffle() -> Set<Cookie> {
        //return createInitialCookies()
        var set: Set<Cookie>
        repeat {
            set = createInitialCookies()
            detectPossibleSwaps()
            print("possible swaps: \(possibleSwaps)")
        } while possibleSwaps.count == 0
        
        return set
    }

    func performSwap(swap: Swap) {
        let columnA = swap.cookieA.column
        let rowA = swap.cookieA.row
        let columnB = swap.cookieB.column
        let rowB = swap.cookieB.row
        
        cookies[columnA, rowA] = swap.cookieB
        swap.cookieB.column = columnA
        swap.cookieB.row = rowA
        
        cookies[columnB, rowB] = swap.cookieA
        swap.cookieA.column = columnB
        swap.cookieA.row = rowB
    }
 
    func detectPossibleSwaps() {
        var set = Set<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let cookie = cookies[column, row] {
                    // Is it possible to swap this cookie with the one on the right?
                    if column < NumColumns - 1 {
                        // Have a cookie in this spot? If there is no tile, there is no cookie.
                        if let other = cookies[column + 1, row] {
                            // Swap them
                            cookies[column, row] = other
                            cookies[column + 1, row] = cookie
                            
                            // Is either cookie now part of a chain?
                            if hasChainAtColumn(column + 1, row: row) ||
                                hasChainAtColumn(column, row: row) {
                                set.insert(Swap(cookieA: cookie, cookieB: other))
                            }
                            
                            // Swap them back
                            cookies[column, row] = cookie
                            cookies[column + 1, row] = other
                        }
                    }
                    
                    if row < NumRows - 1 {
                        if let other = cookies[column, row + 1] {
                            cookies[column, row] = other
                            cookies[column, row + 1] = cookie
                            
                            // Is either cookie now part of a chain?
                            if hasChainAtColumn(column, row: row + 1) ||
                                hasChainAtColumn(column, row: row) {
                                set.insert(Swap(cookieA: cookie, cookieB: other))
                            }
                            
                            // Swap them back
                            cookies[column, row] = cookie
                            cookies[column, row + 1] = other
                        }
                    }
                }
            }
        }
        
        possibleSwaps = set
    }
    
    func isPossibleSwap(swap: Swap) -> Bool {
        return possibleSwaps.contains(swap)
    }
    
    func removeMatches() -> Set<Chain> {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        
        removeCookie(horizontalChains)
        removeCookie(verticalChains
        )
        
        calculateScores(horizontalChains)
        calculateScores(verticalChains)
        
        return horizontalChains.union(verticalChains)
    }
    
    func fillHoles() -> [[Cookie]] {
        var columns = [[Cookie]]()
        
        // 1: Loop through rows from bottom to top
        for column in 0..<NumColumns {
            var array = [Cookie]()
            for row in 0..<NumRows {
                // 2: If there is a tile but no cookie, then there is a hole
                if tiles[column, row] != nil && cookies[column, row] == nil {
                    // 3: Scan upwards to find the next cookie above the hole
                    for lookup in (row + 1)..<NumRows {
                        if let cookie = cookies[column, lookup] {
                            // 4: Another cookie found? Move it to the hole
                            cookies[column, lookup] = nil
                            cookies[column, row] = cookie
                            cookie.row = row
                            
                            // 5: Add cookie to array
                            array.append(cookie)
                            
                            // 6: Cookie found? Break loop
                            break
                        }
                    }
                }
            }
            
            // 7: No holes in the column? No need to add it to final array
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    func topUpCookies() -> [[Cookie]] {
        var columns = [[Cookie]]()
        var cookieType: CookieType = .Unknown
        
        for column in 0..<NumColumns {
            var array = [Cookie]()
            
            // 1: Loop through cookies (top to bottom). Ends when a cookie is found.
            var row = NumRows - 1
            while row >= 0 && cookies[column, row] == nil {
                // 2: Ignore gaps: They do not need to be filled with new cookies.
                if tiles[column, row] != nil  {
                    // 3: Randomly create new cookies, but not of the type the previous one was of.
                    var newCookieType: CookieType
                    repeat {
                        newCookieType = CookieType.random()
                    } while newCookieType == cookieType
                    cookieType = newCookieType
                    // 4: Create new cookie object and add it to array
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                    array.append(cookie)
                }
                
                row -= 1
            }
            // 5: If column did not have any holes, do not add to final array
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    func resetComboMultiplier() {
        comboMultiplier = 1
    }
    
    
}