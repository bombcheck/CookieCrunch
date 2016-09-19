//
//  Array2D.swift
//  CookieCrunch
//
//  Created by Nils Bernhardt on 17.06.16.
//  Copyright © 2016 Nils Bernhardt. All rights reserved.
//

struct Array2D<T> {
    let columns: Int
    let rows: Int
    private var array: Array<T?>
    
    init (columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        array = Array<T?>(count: rows*columns, repeatedValue: nil)
    }
    
    subscript(colum: Int, row: Int) -> T? {
        get {
            return array[row*columns + colum]
        }
        set {
            array [row*columns + colum] = newValue
        }
    }

}
