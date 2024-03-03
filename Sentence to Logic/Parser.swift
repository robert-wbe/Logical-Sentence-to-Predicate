//
//  Parser.swift
//  Sentence to Logic
//
//  Created by Robert Wiebe on 11/4/23.
//

import Foundation

struct Node {
    
    struct Sentence {
        let nounPhrase: NounPhrase
        let verbPhrase: VerbPhrase
    }
    
    indirect enum NounPhrase {
        case quantified(Determiner, String, RelClause)
        case name(String)
    }
    
    indirect enum VerbPhrase {
        case transitive(String, NounPhrase, Bool)
        case intrans(String)
    }
    
    indirect enum RelClause {
        case empty
        case condition(VerbPhrase)
    }
}

class Parser {
    
    enum ParseError: Error {
        case syntaxError
    }
    
    func parseSentence() throws -> Node.Sentence {
        Node.Sentence(nounPhrase: try parseNounPhrase(), verbPhrase: try parseVerbPhrase(acceptReversed: false))
    }
    
    func parseNounPhrase() throws -> Node.NounPhrase {
        if case Token.name(let name) = peek() {
            consume()
            return .name(name)
        }
        
        guard case Token.determiner(let det) = consume() else { throw ParseError.syntaxError }
        guard case Token.noun(let noun) = consume() else { throw ParseError.syntaxError }
        let relClause = try parseRelClause()
        
        return .quantified(det, noun, relClause)
    }
    
    func parseVerbPhrase(acceptReversed: Bool) throws -> Node.VerbPhrase {
        if case Token.intransVerb(let verb) = peek() {
            consume()
            return .intrans(verb)
        }
        guard case Token.transVerb(let verb) = peek() else {
            let nounPhrase = try parseNounPhrase()
            guard case Token.transVerb(let revVerb) = consume() else {throw ParseError.syntaxError}
            return .transitive(revVerb, nounPhrase, true)
        }
        consume()
        let nounPhrase = try parseNounPhrase()
        return .transitive(verb, nounPhrase, false)
    }
    
    func parseRelClause() throws -> Node.RelClause {
        if end { return .empty }
        if case Token.who = peek() {
            consume()
            return .condition(try parseVerbPhrase(acceptReversed: true))
        }
        return .empty
    }
    
    func peek() -> Token {
        inputTokens[idx]
    }
    
    @discardableResult
    func consume() -> Token {
        let token = peek()
        idx += 1
        return token
    }
    
    init(inputTokens: [Token]) {
        self.inputTokens = inputTokens
    }
    
    var end: Bool {
        idx >= inputTokens.count
    }
    
    var idx: Int = 0
    let inputTokens: [Token]
}
