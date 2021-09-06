//
//  ResultView.swift
//  MultipleQRCodeReader
//
//  Created by 藤治仁 on 2021/09/06.
//

import SwiftUI

struct ResultView: View {
    let textArray: [String]
    
    var body: some View {
        List(textArray, id: \.self) { text in
            Text(text)
        }
        .navigationTitle("読み取り結果")
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView(textArray: ["りんご" , "オレンジ"])
    }
}
