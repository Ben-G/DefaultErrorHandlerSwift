
//
//  DefaultErrorHanlder.swift
//  DefaultErrorHandler
//
//  Created by Benjamin Encz on 11/12/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

class ErrorHandler {
    
    func wrap<ReturnType>(@noescape f: () throws -> ReturnType?) -> ReturnType? {
        do {
            return try f()
        } catch let error {
            logError(error)
            return nil
        }
    }
    
    func logError(error: ErrorType) {
        let stackSymbols = NSThread.callStackSymbols()
        print("Error: \(error) \n Stack Symbols: \(stackSymbols)")
    }
    
}