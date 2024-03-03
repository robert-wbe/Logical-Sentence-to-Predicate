//
//  Renderer.swift
//  Sentence to Logic
//
//  Created by Robert Wiebe on 11/5/23.
//

import Foundation

extension String {
    func encloseInParens(_ flag: Bool) -> String {
        flag ? "(\(self))" : self
    }
}

class Renderer {
    static func renderPredicate(_ predicate: Predicate, parens: Bool) -> String {
        switch predicate {
        case .all(let predVar, let predicate):
            "\\forall \(predVar) \\ \(renderPredicate(predicate, parens: false))".encloseInParens(parens)
        case .some(let predVar, let predicate):
            "\\exists \(predVar) \\ \(renderPredicate(predicate, parens: false))".encloseInParens(parens)
        case .not(let predicate):
            "\\lnot \(renderPredicate(predicate, parens: true))"
        case .implies(let predicate, let predicate2):
            "\(renderPredicate(predicate, parens: true)) \\implies \(renderPredicate(predicate2, parens: true))".encloseInParens(parens)
        case .and(let predicate, let predicate2):
            "\(renderPredicate(predicate, parens: true)) \\land \(renderPredicate(predicate2, parens: true))".encloseInParens(parens)
        case .namedPred(let predName, let predVars):
            "\(predName)(\(predVars.map({$0.description}).joined(separator: ", ")))"
        }
    }
}
