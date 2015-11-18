//
//  main.swift
//  DefaultErrorHandler
//
//  Created by Benjamin Encz on 11/12/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

func doThing() throws {
    
}

func readFile() {
    let errorHandler = ErrorHandler()
    
    let fileContent = errorHandler.wrap {
        return try NSString(contentsOfFile: "doesNotExist", encoding: NSUTF8StringEncoding)
    }
    
    let a = try? doThing()
    
    print(file)
}



readFile()


