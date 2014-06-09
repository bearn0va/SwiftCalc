//
//  main.swift
//  SwiftCalc
//
//  Created by Silas Schwarz on 6/4/14.
//  Copyright (c) 2014 Silas Schwarz. All rights reserved.
//

import Foundation

var s = Script()

while true {
    var r = s.readLine()
    println(r.verbose(0))
    println(r.dump())
    var ctx = Context()
    println(r.evaluate(ctx).dump())
}