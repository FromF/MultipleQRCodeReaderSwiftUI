//
//  QRReaderView.swift
//  MultipleQRCodeReader
//
//  Created by 藤治仁 on 2021/09/06.
//

import SwiftUI

struct QRReaderView: View {
    @ObservedObject private var qrReaderViewModel = QRReaderViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                CALayerView(caLayer: qrReaderViewModel.previewLayer)
                    .clipped()
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .padding()

                NavigationLink(
                    destination: ResultView(textArray: qrReaderViewModel.metaText()),
                    isActive: $qrReaderViewModel.finishMultipleQR,
                    label: {
                        EmptyView()
                    })
            }
            .onAppear() {
                qrReaderViewModel.startSession()
            }
            .onDisappear() {
                qrReaderViewModel.endSession()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("QR読み込み")
        }
    }
}

struct QRReaderView_Previews: PreviewProvider {
    static var previews: some View {
        QRReaderView()
    }
}
