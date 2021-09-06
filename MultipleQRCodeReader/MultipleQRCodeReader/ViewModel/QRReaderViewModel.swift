//
//  QRReaderViewModel.swift
//  MultipleQRCodeReader
//
//  Created by 藤治仁 on 2021/09/06.
//

import Foundation
import AVFoundation
import CoreImage
import BinaryKit
import SwiftUI

class QRReaderViewModel: NSObject, ObservableObject {
    ///プレビュー用レイヤー
    var previewLayer:CALayer!
    
    ///連結QR読み込み終了
    @Published var finishMultipleQR = false
    
    ///セッション
    private let captureSession = AVCaptureSession()
    ///撮影デバイス
    private var capturepDevice:AVCaptureDevice!
    
    ///連結されるシンボルの合計数
    private var totalSymbol = 0
    
    ///シンボル列指示子
    private struct Symbol {
        let position: Int
        let total: Int
    }
    
    ///QRスキャン結果
    private struct scanResult {
        let postion: Int
        let text: String
    }
    
    ///QRスキャン結果を格納する配列
    private var qrScanArray: [scanResult] = []
    
    override init() {
        super.init()

        prepareCamera()
        beginSession()
    }
    
    private func prepareCamera() {
        captureSession.sessionPreset = .photo
        
        if let availableDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first {
            capturepDevice = availableDevice
        }
    }

    private func beginSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: capturepDevice)

            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = previewLayer
        
        
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)

        let queue = DispatchQueue(label: "FromF.github.com.MultipleQRCodeReader.AVFoundation")
        metadataOutput.setMetadataObjectsDelegate(self, queue: queue)
        metadataOutput.metadataObjectTypes = [.qr]

        captureSession.commitConfiguration()
    }

    func startSession() {
        if captureSession.isRunning { return }
        totalSymbol = 0
        qrScanArray = []
        captureSession.startRunning()
    }

    func endSession() {
        if !captureSession.isRunning { return }
        captureSession.stopRunning()
    }
    
    func metaText() -> [String] {
        var result: [String] = []
        
        for qrScan in qrScanArray.sorted(by: {$0.postion < $1.postion}) {
            result.append(qrScan.text)
        }
        
        return result
    }
    
    private func analyzeDescriptor(descriptor: CIQRCodeDescriptor) -> Symbol? {
        var result: Symbol?
        // バイナリーに変換
        var binary = Binary(data: descriptor.errorCorrectedPayload)
        binary.resetReadCursor()
        // モード指示子(4bit)を取得
        guard let modeBits = try? binary.readBits(4) else { return result }
        guard let mode = QRMode(rawValue: modeBits) else { return result }
        
        if mode == .structuredAppend {
            // 構造的連接
            // シンボル位置(4bit)
            if let symbolPosition = try? binary.readBits(4) ,
               // 連結されるシンボルの合計数(4bit)
               let totalSymbols = try? binary.readBits(4) {
                result = Symbol(position: symbolPosition, total: totalSymbols + 1)
            }
        } else {
            result = Symbol(position: 0, total: 1)
        }
        
        return result
    }
}

extension QRReaderViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects {
            guard let metadata = metadata as? AVMetadataMachineReadableCodeObject, metadata.type == .qr else { continue }
            guard let descriptor = metadata.descriptor as? CIQRCodeDescriptor else { continue }
            // ヘッダーとメタデータの文字列を取り出す
            if let header = analyzeDescriptor(descriptor: descriptor) ,
               let metaText = metadata.stringValue {
                if totalSymbol == 0 {
                    //連結されるシンボルの合計数が未格納なら格納する
                    totalSymbol = header.total
                }
                
                if qrScanArray.contains(where: {$0.postion == header.position}) == false {
                    //読み込みした内容が未格納なら格納する
                    qrScanArray.append(scanResult(postion: header.position, text: metaText))
                    print("[\(header)] = \(metaText)")
                }
                
                if qrScanArray.count == totalSymbol {
                    DispatchQueue.main.async {
                        //全てのシンボルが読み込み終わったらtrueとする
                        self.finishMultipleQR = true
                    }
                }
            }
        }
    }
}
