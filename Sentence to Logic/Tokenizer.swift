//
//  Tokenizer.swift
//  Sentence to Logic
//
//  Created by Robert Wiebe on 11/2/23.
//

import Foundation

enum Determiner {
    case a, every, no
}

enum Token {
    case determiner(Determiner)
    case name(String)
    case noun(String)
    case intransVerb(String)
    case transVerb(String)
    case who
}


class Tokenizer {
    static let nonTransVerbs: [String] = ["runs", "lives", "walks", "waits", "laughs", "stands"]
    static let transVerbs: [String] = ["knows", "loves", "likes", "sees", "pays"]
    
    static func tokenize(_ inputText: String) -> [Token] {
        var tokens: [Token] = []
        
        for word in inputText.split(separator: " ").map({String($0)}) {
            let wordLower = word.lowercased()
            
            if wordLower == "a" {tokens.append(.determiner(.a)); continue}
            if wordLower == "every" {tokens.append(.determiner(.every)); continue}
            if wordLower == "no" {tokens.append(.determiner(.no)); continue}
            
            if word == "who" {tokens.append(.who); continue}
            
            if nonTransVerbs.contains(word) {tokens.append(.intransVerb(word)); continue}
            if transVerbs.contains(word) {tokens.append(.transVerb(word)); continue}
            
            if word.first!.isUppercase {tokens.append(.name(word)); continue}
            tokens.append(.noun(word))
        }
        
        return tokens
    }
}

