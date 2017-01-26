//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Ziheng Chen on 1/13/17.
//  Copyright © 2017 edu.stanford.cs193p.zihengc. All rights reserved.
//

import Foundation

// store variable name and value pair in a dictionary
var variables = Dictionary<String, Double>()

struct CalculatorBrain {
    
    // the calculated value
    private var accumulator: Double?
    
    // the math sequence that leads to the calculated value
    private var description: String?
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    // an array stores operator and operand
    private var expressionElementArray = Array<ExpressionElement>()

    
    
    // four types of operations that the user could type
    private enum Operation {
        case constant(Double)
        case variable(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    
    
    private enum ExpressionElement {
        case number(Double)
        case constant(String, Double)
        case variable(String)
        case unaryOperation(String, (Double) -> Double)
        case binaryOperation(String, (Double, Double) -> Double, (String, String) -> String)
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
                expressionElementArray.append(ExpressionElement.constant(symbol, value))
            case .unaryOperation(let function):
                if accumulator != nil && description != nil {
                    accumulator = function(accumulator!)
                    description = symbol + "(" + description! + ")"
                }
                expressionElementArray.append(ExpressionElement.unaryOperation(symbol, function))
            case .binaryOperation(let function, let descriptionFunction):
                performPendingBinaryOperation()
                if accumulator != nil && description != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!, descriptionFunction: descriptionFunction, oldDescription: description!)
                    accumulator = nil
                    description! += symbol
                }
                expressionElementArray.append(ExpressionElement.binaryOperation(symbol, function, descriptionFunction))
            case .equals:
                performPendingBinaryOperation()
                expressionElementArray.append(ExpressionElement.equals)
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
    
    /* 
     * set number operand
     */
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        description = String(operand)
        // store input number to the expression array
        expressionElementArray.append(ExpressionElement.number(operand))
    }
    
    private var variableName: String?
    private var variableIsAssignedValue = false
    
    /*
     * set variable operand
     */
    mutating func setOperand(variable named: String) {
        // add (variableName, 0) to the dictionary
        variables[named] = 0
        // store input variable to the expression array
        expressionElementArray.append(ExpressionElement.variable(named))
    }
    
    
    func evaluate(using variables: Dictionary<String, Double>? = nil)
        -> (result: Double?, description: String) {
            
            func evaluateExpression(_ expression: Array<ExpressionElement>) -> (result: Double?, description: String, restExpression: Array<ExpressionElement>) {
                var restExpression = expression
                if restExpression.isEmpty == false {
                    let lastElement = restExpression.removeLast()
                    switch lastElement {
                    case .number(let value):
                        return (value, "\(value)", restExpression)
                    case .constant(let name, let value):
                        return (value, name, restExpression)
                    case .variable(let name):
                        if variables != nil {
                            if let value = variables![name] {
                                return (value, name, restExpression)
                            } else {
                                return (0, name, restExpression)
                            }
                        }
                    case .unaryOperation(let operatorName, let function):
                        let currentState = evaluateExpression(restExpression)
                        let result: Double?
                        let description: String
                        if let currentResult = currentState.result {
                            result = function(currentResult)
                        }
                        description = operatorName + "(" + currentState.description + ")"
                        return (result, description, currentState.restExpression)
                    case .binaryOperation(let operatorName, let function, let descriptionFunction):
                        
                    case .equals:
                        // compute all the previous result
                        while restExpression.isEmpty == false {
                            
                            
                        }
                    }
                    
                    
                }
            }
            
            var currentState: (results: Double?, description: String, restExpression: Array<ExpressionElement>)
            currentState.restExpression = expressionElementArray
            
            while currentState.restExpression.isEmpty == false {
                // TODO
                currentState = evaluateExpression(currentState.restExpression)
            }
        
            return (currentState.results, currentState.description)
            
            
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
