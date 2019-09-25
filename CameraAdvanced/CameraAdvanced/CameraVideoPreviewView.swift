//
//  CameraVideoPreviewView.swift
//  CameraAdvanced
//
//  Created by Emanuel Guerrero on 9/25/19.
//  Copyright © 2019 Modernizing Medicine. All rights reserved.
//

import AVFoundation
import UIKit

final class CameraVideoPreviewView: UIView {
    
    // MARK: - UIView
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    // MARK: - Public Instance Properties
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }
        return layer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
}
