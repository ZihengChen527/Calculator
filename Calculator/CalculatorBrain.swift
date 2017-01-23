//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Ziheng Chen on 1/13/17.
//  Copyright © 2017 edu.stanford.cs193p.zihengc. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    // the calculated value
    private var accumulator: Double?
    
    // the math sequence that leads to the calculated value
    private var description: String?
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    // four types of operations that the user could type
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "sin" : Operation.unaryOperation(sin),
        "cos" : Operation.unaryOperation(cos),
        "tan" : Operation.unaryOperation(tan),
        "ln" : Operation.unaryOperation(log),
        "±" : Operation.unaryOperation({ -$0 }),
        "+" : Operation.binaryOperation({ $0 + $1 }, { $0 + "+" + $1 }),
        "-" : Operation.binaryOperation({ $0 - $1 }, { $0 + "-" + $1 }),
        "×" : Operation.binaryOperation({ $0 * $1 }, { $0 + "×" + $1 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }, { $0 + "÷" + $1 }),
        "=" : Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                description = symbol
            case .unaryOperation(let function):
                if accumulator != nil && description != nil {
                    accumulator = function(accumulator!)
                    description = symbol + "(" + description! + ")"
                }
            case .binaryOperation(let function, let descriptionFunction):
                performPendingBinaryOperation()
                if accumulator != nil && description != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!, descriptionFunction: descriptionFunction, oldDescription: description!)
                    accumulator = nil
                    description! += symbol
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil && description != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            description = pendingBinaryOperation!.appendDescription(with: description!)
            pendingBinaryOperation = nil
        }
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        let descriptionFunction: (String, String) -> String
        let oldDescription: String
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        func appendDescription(with discriptionToAppend: String) -> String {
            return descriptionFunction(oldDescription, discriptionToAppend)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        description = String(operand)
    }
    
    // interface to the controller to get the computed result
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    // interface to the controller to get the description sequence
    var mathSequence: String? {
        get {
            return description
        }
    }
    
    // return true if the result is pending
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    // clears everything of the calculator
    mutating func clear() {
        accumulator = nil
        description = nil
        pendingBinaryOperation = nil
    }
}
