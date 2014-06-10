//
//  Script.swift
//  SwiftCalc
//
//  Created by Silas Schwarz on 6/5/14.
//  Copyright (c) 2014 Silas Schwarz. All rights reserved.
//

import Foundation

class Script {
    
    var fileHandle: NSFileHandle
    var data: NSData?
    var line: NSString?
    var index: Int
    
    convenience init() {
        self.init(fileHandle: NSFileHandle.fileHandleWithStandardInput())
    }
    
    init(fileHandle: NSFileHandle) {
        self.fileHandle = fileHandle
        self.index = 0
    }
    
    func lineData() -> NSData {
        if let isline = line {
            return isline.dataUsingEncoding(NSUTF8StringEncoding)
        }
        return NSData()
    }
    
    func character() -> unichar {
        return self.characterAtIndex(0)
    }
    
    func characterAtIndex(index: Int) -> unichar {
        if let isline = line {
            if self.index + index >= isline.length {
                return 0 as unichar
            }
            return isline.characterAtIndex(self.index + index)
        }
        return 0
    }
    
    func available() -> Int {
        if let isline = line {
            return isline.length - index
        }
        return 0
    }
    
    func increment(amount: Int = 1) {
        index += amount
    }
    
    func decrement(amount: Int = 1) {
        index -= amount
    }
    
    func hasCharacter(c: unichar) -> Bool {
        for index in 0...self.available()-1 {
            if c == self.characterAtIndex(index) {
                return true
            }
        }
        return false
    }
    
    func trimSpaces() {
        while isSpace(self.character()) {
            self.increment()
        }
    }
    
    subscript (index: Int) -> unichar {
        return self.characterAtIndex(index)
    }
    
    func substringFromIndex(index: Int) -> String {
        if let aline = line {
            return String(aline.substringFromIndex(self.index + index))
        }
        return ""
    }
    
    func substringToIndex(index: Int) -> String {
        if let aline = line {
            return aline.substringWithRange(NSMakeRange(self.index, self.index + index))
        }
        return ""
    }
    
    func substringFromIndex(index: Int, toIndex: Int) -> String {
        if let aline = line {
            return aline.substringWithRange(NSMakeRange(self.index + index, self.index + toIndex))
        }
        return ""
    }
    
    func readArgumentList(sep: unichar, end: unichar) -> Value[] {
        var ret = Value[]()
        while self.character() != 0 && self.character() != end {
            ret += self.readValue(sep)
            self.trimSpaces()
            if self.character() == sep {
                self.increment()
            }
        }
        self.increment()
        return ret
    }
    
    func readLine() -> Value {
        print(">>> ")
        data = fileHandle.availableData
        line = NSString(data: self.data, encoding: NSUTF8StringEncoding)
        if let aline = line {
            line = aline.substringToIndex(aline.length-1)
        }
        index = 0
        if !self.hasCharacter(~"=") {
            return self.readValue(~"\0")
        }
        var name = self.readNext()
        if name is Error {
            return name
        }
        if !(name is Variable) {
            return Error(type: .Syntax, message: "Cannot assign to value other than variable.")
        }
        self.trimSpaces()
        var args: Value[]? = nil
        if self.character() == ~"(" {
            self.increment()
            args = readArgumentList(~",", end: ~")")
        }
        self.trimSpaces()
        var next = ExpressionNextType(self)
        self.increment()
        self.trimSpaces()
        if self.character() == ~"=" {
            self.increment()
            self.trimSpaces()
        }
        var right = self.readValue(~"\0")
        if next != ExpressionType.Assign {
            right = Expression(type: next, left: name, right: right)
        }
        return Expression(type: .Assign, left: name, right: right)
    }
    
    func readValue(end: unichar) -> Value {
        self.trimSpaces()
        var tree: Expression? = nil
        var left = self.readNext()
        if left is Error {
            return left
        }
        while self.character() != end && self.character() != 0 {
            self.trimSpaces()
            var nextType: ExpressionType = ExpressionNextType(self)
            self.increment()
            if nextType == ExpressionType.Unknown {
                return Error(type: .Syntax, message: "Unexpected character \(self.character()).")
            }
            if nextType == .End {
                if let expr = tree {
                    return expr
                }
                return left
            }
            var right = self.readNext()
            if right is Error {
                return left
            }
            if let atree = tree {
                atree.addValue(nextType, right: right)
            } else {
                tree = Expression(type: nextType, left: left, right: right)
            }
        }
        if let atree = tree {
            return atree
        }
        return left
    }
    
    func skipNum() {
        do {
            self.increment()
        } while self.isNumberChar(dot: true)
    }
    
    func readNext() -> Value {
        self.trimSpaces()
        if self.isNumberChar() {
            var str = NSString(string: self.substringFromIndex(0))
            var range = str.rangeOfString(".")
            if range.length != 0 {
                var ret = str.floatValue as Float
                self.skipNum()
                return Simple(value: ret)
            }
            var ret = str.integerValue;
            self.skipNum()
            return Simple(value: ret)
        } else if self.isNameChar() {
            var count = 0
            do {
                count += 1
            } while self.isNameChar(index: count)
            var name = self.substringToIndex(count)
            self.increment(amount: count)
            return Variable(value: name)
        }
        return Error()
    }
    
    func isNumberChar(dot: Bool = true) -> Bool {
        return isdigit(self.character().asCInt()).asBool() || self.character() == ~"."
    }
    
    func isNameChar(index: Int = 0) -> Bool {
        return isalnum(self.characterAtIndex(index).asCInt()).asBool() || self.character() == ~"_"
    }
}

extension unichar {
    func asCInt() -> CInt {
        return NSNumber(unsignedShort: self).intValue
    }
    
    func asInt() -> Int {
        return NSNumber(unsignedShort: self).integerValue
    }
}

extension CInt {
    func asBool() -> Bool {
        return self != 0
    }
}

@prefix func ~ (l: String) -> unichar {
    return characterFromLiteral(l)
}

func characterFromLiteral(l: String) -> unichar {
    return NSString(string: l).characterAtIndex(0)
}

func isSpace(c: unichar) -> Bool {
    return c == ~" " || c == ~"\t"
}
