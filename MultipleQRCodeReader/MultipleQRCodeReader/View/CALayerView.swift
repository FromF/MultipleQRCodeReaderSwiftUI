//
//  CALayerView.swift
//  MultipleQRCodeReader
//
//  Created by 藤治仁 on 2021/09/06.
//

import SwiftUI
import AVFoundation

struct CALayerView: UIViewControllerRepresentable {
    var caLayer:AVCaptureVideoPreviewLayer

    func makeUIViewController(context: UIViewControllerRepresentableContext<CALayerView>) -> UIViewController {
        let viewController = UIViewController()

        viewController.view.layer.addSublayer(caLayer)
        caLayer.videoGravity = .resizeAspectFill
        caLayer.frame = viewController.view.layer.frame

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CALayerView>) {
        caLayer.frame = uiViewController.view.layer.frame
    }
}
