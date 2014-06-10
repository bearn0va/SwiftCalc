//
//  Expression.swift
//  SwiftCalc
//
//  Created by Silas Schwarz on 6/8/14.
//  Copyright (c) 2014 Silas Schwarz. All rights reserved.
//

import Foundation

enum ExpressionType: String {
    case Unknown = ""
    case Add = "+"
    case Subtract = "-"
    case Multiply = "*"
    case Divide = "/"
    case Power = "^"
    case Assign = "="
    case End = "\0"
    
    func pemdas() -> Int {
        switch self {
        case .Assign:
            return -1
        case .Add:
            return 0
        case .Subtract:
            return 0
        case .Multiply:
            return 1
        case .Divide:
            return 1
        case .Power:
            return 2
        default:
            return 3
        }
    }
}

class Expression: Value {
    var type: ExpressionType
    var left: Value
    var right: Value
    
    convenience init() {
        self.init(type: .Unknown, left: Simple(value: 0), right: Simple(value: 0))
    }
    
    init(type: ExpressionType, left: Value, right: Value) {
        self.type = type
        self.left = left
        self.right = right
    }
    
    func dump() -> String {
        return "( \(left.dump()) \(type.toRaw()) \(self.right.dump()) )"
    }
    
    func verbose(indent: Int) -> String {
        var tabs_sub = newTabs(indent + 1)
        var tabs = newTabs(indent)
        return "[ Expression ] \"\(type.toRaw())\" {\n\(tabs_sub)\(self.left.verbose(indent + 1))\n\(tabs_sub)\(self.right.verbose(indent + 1))\n\(tabs)}"
    }
    
    func evaluate(ctx: Context) -> Value {
        if type == .Assign {
            if let aleft = self.left as? Variable {
                var ret = self.right.evaluate(ctx)
                ctx.setGlobal(ret, name: aleft.value)
                return ret
            } else {
                return self
            }
        }
        var left = self.left.evaluate(ctx)
        var right = self.right.evaluate(ctx)
        if let aleft = left as? Simple<Int> {
            if let aright = right as? Simple<Int> {
                switch self.type {
                case .Add:
                    return Simple(value: aleft.value + aright.value)
                case .Subtract:
                    return Simple(value: aleft.value - aright.value)
                case .Multiply:
                    return Simple(value: aleft.value * aright.value)
                case .Divide:
                    return Fraction(numerator: aleft.value, denominator: aright.value)
                case .Power:
                    return Simple(value: power(aleft.value, aright.value))
                default:
                    return Error()
                }
            } else if let aright = right as? Simple<Float> {
                switch self.type {
                case .Add:
                    return Simple(value: aleft.value.floatValue() + aright.value)
                case .Subtract:
                    return Simple(value: aleft.value.floatValue() - aright.value)
                case .Multiply:
                    return Simple(value: aleft.value.floatValue() * aright.value)
                case .Divide:
                    return Simple(value: aleft.value.floatValue() / aright.value)
                case .Power:
                    var a: NSNumber = aleft.value
                    var b: NSNumber = aright.value
                    var r: NSNumber = pow(a.doubleValue, b.doubleValue)
                    return Simple(value: r.floatValue as Float)
                default:
                    return Error()
                }
            }
        } else if let aleft = left as? Simple<Float> {
            if let aright = right as? Simple<Int> {
                switch self.type {
                case .Add:
                    return Simple(value: aleft.value + aright.value.floatValue())
                case .Subtract:
                    return Simple(value: aleft.value - aright.value.floatValue())
                case .Multiply:
                    return Simple(value: aleft.value * aright.value.floatValue())
                case .Divide:
                    return Simple(value: aleft.value / aright.value.floatValue())
                case .Power:
                    var a: NSNumber = aleft.value
                    var b: NSNumber = aright.value
                    var r: NSNumber = pow(a.doubleValue, b.doubleValue)
                    return Simple(value: r.floatValue as Float)
                default:
                    return Error()
                }
            } else if let aright = right as? Simple<Float> {
                switch self.type {
                case .Add:
                    return Simple(value: aleft.value + aright.value)
                case .Subtract:
                    return Simple(value: aleft.value - aright.value)
                case .Multiply:
                    return Simple(value: aleft.value * aright.value)
                case .Divide:
                    return Simple(value: aleft.value / aright.value)
                case .Power:
                    var a: NSNumber = aleft.value
                    var b: NSNumber = aright.value
                    var r: NSNumber = pow(a.doubleValue, b.doubleValue)
                    return Simple(value: r.floatValue as Float)
                default:
                    return Error()
                }
            }
        }
        return self
    }
    
    func addValue(type: ExpressionType, right: Value) {
        if type.pemdas() <= self.type.pemdas() {
            self.left = Expression(type: self.type, left: self.left, right: self.right)
            self.right = right
            self.type = type
        } else if let expr = self.right as? Expression {
            expr.addValue(type, right: right)
        } else {
            self.right = Expression(type: type, left: self.right, right: right)
        }
    }
}



extension Int {
    func floatValue() -> Float {
        return (self as NSNumber).floatValue as Float
    }
}

func ExpressionNextType(script: Script) -> ExpressionType {
    switch script.character() {
    case ~ExpressionType.Add.toRaw():
        return .Add
    case ~ExpressionType.Subtract.toRaw():
        return .Subtract
    case ~ExpressionType.Multiply.toRaw():
        return .Multiply
    case ~ExpressionType.Divide.toRaw():
        return .Divide
    case ~ExpressionType.Power.toRaw():
        return .Power
    case ~ExpressionType.Assign.toRaw():
        return .Assign
    case ~ExpressionType.End.toRaw():
        return .End
    case ~"\n":
        return .End
    case ~")":
        return .End
    case ~",":
        return .End
    default:
        return .Unknown
    }
}

func power(a: Int, b: Int) -> Int {
    if b == 0 {
        return 1
    } else if a == 0 {
        return 0
    } else if b % 2 == 0 {
        return power(a * a, b / 2)
    } else if b == 1 {
        return a
    } else {
        return a * power(a, b - 1)
    }
}

func newTabs(count: Int) -> String {
    var ret = String()
    for _ in 0...count-1 {
        ret += "\t"
    }
    return ret
}
