//
//  main.swift
//  DefaultErrorHandler
//
//  Created by Benjamin Encz on 11/12/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation


func readFile() {
    let errorHandler = ErrorHandler()
    
    let file = errorHandler.wrap {
        try NSString(contentsOfFile: "doesNotExist", encoding: NSUTF8StringEncoding)
    }

    print(file)
}



readFile()
