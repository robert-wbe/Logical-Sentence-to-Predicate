//
//  Transformer.swift
//  Sentence to Logic
//
//  Created by Robert Wiebe on 11/2/23.
//

import Foundation

typealias PredVar = String

enum Subject: CustomStringConvertible {
    case name(String)
    case predVar(PredVar)
    
    var description: String {
        switch self {
        case .name(let name):
            name
        case .predVar(let predVar):
            predVar
        }
    }
}

indirect enum Predicate {
    case all(PredVar, Predicate)
    case some(PredVar, Predicate)
    case not(Predicate)
    
    case implies(Predicate, Predicate)
    case and(Predicate, Predicate)
    
    case namedPred(String, [Subject])
}

class Transformer {
    func transformSentence(_ sentence: Node.Sentence) -> Predicate {
        let subject = getNounPhraseSubject(sentence.nounPhrase)
        let verbPred = transformVerbPhrase(sentence.verbPhrase, subject: subject)
        return transformNounPhrase(sentence.nounPhrase, subject: subject, verbPred: verbPred)
    }
    
    func getNounPhraseSubject(_ nounPhrase: Node.NounPhrase) -> Subject {
        switch nounPhrase {
        case .quantified(_, _, _):
            return .predVar(nextPredVar())
        case .name(let name):
            return .name(name)
        }
    }
    
    func transformNounPhrase(_ nounPhrase: Node.NounPhrase, subject: Subject, verbPred: Predicate) -> Predicate {
        switch nounPhrase {
        case .quantified(let determiner, let noun, let relClause):
            let nounPred = Predicate.namedPred(noun, [subject])
            let relPred = transformRelClause(relClause, subject: subject, nounPred: nounPred)
            
            guard case Subject.predVar(let predVar) = subject else {
                print("You messed up")
                return .namedPred("fail", [])
            }

            switch determiner {
            case .a:
                return .some(predVar, .and(relPred, verbPred))
            case .every:
                return .all(predVar, .implies(relPred, verbPred))
            case .no:
                return .not(.some(predVar, .and(relPred, verbPred)))
            }
        case .name(_):
            return verbPred
        }
    }
    
    func transformVerbPhrase(_ verbPhrase: Node.VerbPhrase, subject: Subject) -> Predicate {
        switch verbPhrase {
        case .transitive(let verb, let nounPhrase, let reversed):
            let transSubject = getNounPhraseSubject(nounPhrase)
            let verbPred = Predicate.namedPred(verb, reversed ? [transSubject, subject] : [subject, transSubject])
            return transformNounPhrase(nounPhrase, subject: transSubject, verbPred: verbPred)
            
        case .intrans(let verb):
            return .namedPred(verb, [subject])
        }
    }
    
    func transformRelClause(_ relClause: Node.RelClause, subject: Subject, nounPred: Predicate) -> Predicate {
        switch relClause {
        case .empty:
            return nounPred
        case .condition(let verbPhrase):
            return .and(nounPred, transformVerbPhrase(verbPhrase, subject: subject))
        }
    }
    
    static let predVars: [String] = ["x","y","z","a","b","c","d","e","f","g","h","i","j"]
    var predVarIdx: Int = 0
    func nextPredVar() -> String {
        let nextVar = Transformer.predVars[predVarIdx]
        predVarIdx += 1
        return nextVar
    }
}
