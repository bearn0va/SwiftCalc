//
//  Error.swift
//  SwiftCalc
//
//  Created by Silas Schwarz on 6/8/14.
//  Copyright (c) 2014 Silas Schwarz. All rights reserved.
//

import Foundation

enum ErrorType: String {
    case Syntax = "Syntax"
    case Math = "Math"
    case Unknown = "Unknown"
}

class Error: Value {
    var type: ErrorType
    var message: String
    
    convenience init() {
        self.init(type: .Unknown, message: "Error not initialized.")
    }
    
    init(type: ErrorType, message: String) {
        self.type = type
        self.message = message
    }
    
    func dump() -> String {
        return "\(type.toRaw()) Error: \(message)"
    }
    
    func verbose(indent: Int) -> String {
        return "[ Error ] \(self.dump())"
    }
    
    func evaluate(ctx: Context) -> Value {
        return self
    }
}
