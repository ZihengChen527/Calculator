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
    
    // six types of expression element
    private enum ExpressionElement {
        case number(Double)
        case constant(String, Double)
        case variable(String)
        case unaryOperation(String, (Double) -> Double)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    // an array stores operator and operand
    private var expressionElementArray = Array<ExpressionElement>()
    
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
    
    mutating func performOperation(_ symbol: String) -> (result: Double?, description: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                expressionElementArray.append(ExpressionElement.constant(symbol, value))
            case .unaryOperation(let function):
                expressionElementArray.append(ExpressionElement.unaryOperation(symbol, function))
            case .binaryOperation(let function, let descriptionFunction):
                expressionElementArray.append(ExpressionElement.binaryOperation(function, descriptionFunction))
            case .equals:
                expressionElementArray.append(ExpressionElement.equals)
            }
        }
        return evaluate(using: variables)
    }

    mutating func setOperand(_ operand: Double) -> (result: Double?, description: String) {
        // store input number to the expression array
        expressionElementArray.append(ExpressionElement.number(operand))
        return evaluate(using: variables)
    }
    
    mutating func setOperand(variable named: String) -> (result: Double?, description: String) {
        // add (variableName, 0) to the dictionary
        variables[named] = 0
        // store input variable to the expression array
        expressionElementArray.append(ExpressionElement.variable(named))
        return evaluate(using: variables)
    }
    
    func evaluate(using variables: Dictionary<String, Double>? = nil)
        -> (result: Double?, description: String) {
            
            var currentState: (result: Double?, description: String, restExpression: Array<ExpressionElement>)
            currentState.result = nil
            currentState.description = ""
            currentState.restExpression = expressionElementArray
            
            func evaluateExpression(_ currentStateTuple: (result: Double?, description: String, restExpression: Array<ExpressionElement>)) -> (result: Double?, description: String, restExpression: Array<ExpressionElement>) {
                var currentStateTuple = currentStateTuple
                if currentStateTuple.restExpression.isEmpty == false {
                    let lastElement = currentStateTuple.restExpression.removeLast()
                    switch lastElement {
                    case .number(let value):
                        return (value, "\(value)", currentStateTuple.restExpression)
                    case .constant(let name, let value):
                        return (value, name, currentStateTuple.restExpression)
                    case .variable(let name):
                        if variables != nil {
                            if let value = variables![name] {
                                return (value, name, currentStateTuple.restExpression)
                            } else {
                                return (0, name, currentStateTuple.restExpression)
                            }
                        } else {
                            return (nil, name, currentStateTuple.restExpression)
                        }
                    case .unaryOperation(let operatorName, let function):
                        let currentState = evaluateExpression(currentStateTuple)
                        var result: Double?
                        let description: String
                        if let currentResult = currentState.result {
                            result = function(currentResult)
                        }
                        description = operatorName + "(" + currentState.description + ")"
                        return (result, description, currentState.restExpression)
                    case .binaryOperation(let function, let descriptionFunction):
                        let secondOperandDescription = currentStateTuple.description
                        let currentState = evaluateExpression(currentStateTuple)
                        let firstOperandDescription = currentState.description
                        if let secondOperand = currentStateTuple.result {
                            if let firstOperand = currentState.result {
                                return (function(firstOperand, secondOperand), descriptionFunction(firstOperandDescription, secondOperandDescription), currentState.restExpression)
                            }
                        }
                        return (nil, descriptionFunction(firstOperandDescription, secondOperandDescription), currentStateTuple.restExpression)
                    case .equals:
                        // compute all the previous result
                        while currentStateTuple.restExpression.isEmpty == false {
                            currentStateTuple = evaluateExpression(currentStateTuple)
                        }
                        return currentStateTuple
                    }
                }
                
                // return "Error!" if expressionElementArray.isEmpty!
                return (result: nil, description: "Error!", currentState.restExpression)
            }
            
            currentState = evaluateExpression(currentState)
            return (currentState.result, currentState.description)
    }
    
    // undo the last operation
    mutating func undo() -> (result: Double?, description: String) {
        if expressionElementArray.isEmpty == false {
            expressionElementArray.removeLast()
        }
        return evaluate(using: variables)
    }
    
    // clears everything of the calculator
    mutating func clear() {
        expressionElementArray.removeAll()
        variables.removeAll()
    }
}
