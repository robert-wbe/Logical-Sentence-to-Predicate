//
//  ContentView.swift
//  Sentence to Logic
//
//  Created by Robert Wiebe on 11/2/23.
//

import SwiftUI
import LaTeXSwiftUI

struct ContentView: View {
    @State private var inputSentence: String = ""
    @State var latexList: [String] = ["Predicate \\ will \\ appear \\ here"]
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField(text: $inputSentence, label: {})
                Button("Convert") {
                    let tokens = Tokenizer.tokenize(inputSentence)
                    let parser = Parser(inputTokens: tokens)
                    let transformer = Transformer()
                    do {
                        let sentence = try parser.parseSentence()
                        let predicate = transformer.transformSentence(sentence)
                        let latexResult = Renderer.renderPredicate(predicate, parens: false)
                        self.latexList.append(latexResult)
                        self.latexList.removeFirst()
                    } catch(let error) {
                        print (error)
                    }
                    
                }
                ForEach(latexList, id: \.self) { lt in
                    LaTeX("$\(lt)$")
                        .foregroundStyle(.white)
                        .font(.title2)
                }
            }
            .padding()
        .frame(minWidth: 400, minHeight: 300)
        }
    }
    
    func makeLaTeX() -> LaTeX {
        return LaTeX(latexList.last ?? "")
    }
}

#Preview {
    ContentView()
}
