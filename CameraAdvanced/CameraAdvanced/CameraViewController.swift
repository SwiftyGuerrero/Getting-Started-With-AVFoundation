//
//  CameraViewController.swift
//  CameraAdvanced
//
//  Created by Emanuel Guerrero on 9/25/19.
//  Copyright © 2019 Modernizing Medicine. All rights reserved.
//

import AVFoundation
import UIKit

// MARK: - CameraViewControllerDelegate

protocol CameraViewControllerDelegate: AnyObject {
    func didTakePhoto(_ photo: UIImage)
    func didCancel()
}

// MARK: - CameraViewController

final class CameraViewController: UIViewController {
    
    // MARK: Session Management
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    // MARK: - Private Instance Properties
    
    private lazy var previewView: CameraVideoPreviewView = {
        let newPreviewView = CameraVideoPreviewView(frame: .zero)
        newPreviewView.backgroundColor = .black
        newPreviewView.translatesAutoresizingMaskIntoConstraints = false
        
        return newPreviewView
    }()
    
    private lazy var takePhotoButton: UIButton = {
        let newButton = UIButton(frame: .zero)
        newButton.backgroundColor = .clear
        newButton.setImage(#imageLiteral(resourceName: "camerabutton.png"), for: .normal)
        newButton.addTarget(self, action: #selector(takePhotoButtonTapped), for: .touchUpInside)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        
        return newButton
    }()
    
    private lazy var cancelButton: UIButton = {
        let newButton = UIButton(frame: .zero)
        newButton.backgroundColor = .clear
        newButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        newButton.setTitleColor(.white, for: .normal)
        newButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        
        return newButton
    }()
    
    private var setupResult: SessionSetupResult = .success
    private let captureSession = AVCaptureSession()
    private let captureOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.modernizingmedicine.CameraAdvanced.AVFoundation")
    
    // MARK: - Public Instance Properties
    
    weak var delegate: CameraViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        checkCameraAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startCameraSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopCameraSession()
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Actions
    
    @objc
    private func takePhotoButtonTapped() {
        sessionQueue.async {
            self.takePhoto()
        }
    }
    
    @objc
    private func cancelButtonTapped() {
        delegate?.didCancel()
    }
    
    // MARK: - Private Instance Methods
    
    private func setupUI() {
        view.backgroundColor = .black
        
        setupPreviewView()
        setupTakePhotoButton()
        setupCancelButton()
    }
    
    private func setupPreviewView() {
        view.addSubview(previewView)
        
        previewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        previewView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        previewView.session = captureSession
    }
    
    private func setupTakePhotoButton() {
        view.addSubview(takePhotoButton)
        view.bringSubviewToFront(takePhotoButton)
        
        takePhotoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 8).isActive = true
        takePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupCancelButton() {
        view.addSubview(cancelButton)
        view.bringSubviewToFront(cancelButton)
        
        cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
    }
    
    private func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted permission to access the camera
            break
        case .notDetermined:
            // User was never asked for permission
            
            sessionQueue.suspend()
            
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                
                self.sessionQueue.resume()
            }
        default:
            setupResult = .notAuthorized
        }
        
        sessionQueue.async {
            self.configureCameraSession()
        }
    }
    
    private func configureCameraSession() {
        // First check if we can configure the capture session
        
        guard setupResult == .success else { return }
        
        // Start the configuration of the session
        
        captureSession.beginConfiguration()
        
        captureSession.sessionPreset = .photo
        
        // Setup capture device
        
        do {
            // Query for capture device
            
            guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                setupResult = .configurationFailed
                captureSession.commitConfiguration()
                
                return
            }
            
            // Connect capture device to capture session
            
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                
                DispatchQueue.main.async {
                    self.previewView.videoPreviewLayer.connection?.videoOrientation = .portrait
                }
            } else {
                setupResult = .configurationFailed
                captureSession.commitConfiguration()
                
                return
            }
        } catch {
            setupResult = .configurationFailed
            captureSession.commitConfiguration()
            
            return
        }
        
        // Setup capture output
        
        if captureSession.canAddOutput(captureOutput) {
            captureSession.addOutput(captureOutput)
            
            let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            captureOutput.setPreparedPhotoSettingsArray([photoSettings], completionHandler: nil)
        } else {
            setupResult = .configurationFailed
            captureSession.commitConfiguration()
            
            return
        }
        
        // Finish the configuration of the session
        
        captureSession.commitConfiguration()
    }
    
    private func startCameraSession() {
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                self.captureSession.startRunning()
            case .notAuthorized:
                DispatchQueue.main.async {
                    let changePrivacySetting = "AVCam doesn't have permission to use the camera, please change privacy settings"
                    let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                                            style: .`default`,
                                                            handler: { _ in
                                                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                                                                          options: [:],
                                                                                          completionHandler: nil)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            case .configurationFailed:
                DispatchQueue.main.async {
                    let alertMsg = "Alert message when something goes wrong during capture session configuration"
                    let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func stopCameraSession() {
        sessionQueue.async {
            if self.setupResult == .success {
                self.captureSession.stopRunning()
            }
        }
    }
    
    private func takePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.isAutoStillImageStabilizationEnabled = captureOutput.isStillImageStabilizationSupported
        settings.flashMode = .auto
        
        captureOutput.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let takenPhoto = photo
            .fileDataRepresentation()
            .flatMap { UIImage(data: $0) }
        
        if let photo = takenPhoto {
            
            // Need to use the main thread since we captured the photo on a background thread
            DispatchQueue.main.async {
                self.delegate?.didTakePhoto(photo)
            }
        }
    }
}
