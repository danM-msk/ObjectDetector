    //  Created by Daniyar Mamadov on 22.06.2022.

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,
                      UIImagePickerControllerDelegate,
                      UINavigationControllerDelegate {
    
    private let textOutput: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.numberOfLines = 0
        view.sizeToFit()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imagePicker: UIImagePickerController = {
        let controller = UIImagePickerController()
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textOutput)
        NSLayoutConstraint.activate([
            textOutput.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            textOutput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textOutput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textOutput.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
        view.backgroundColor = .white
        title = "CoreML"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationItem.titleView?.tintColor = .red
        let cameraButton = UIBarButtonItem(image: UIImage(systemName: "camera.fill"), style: .plain, target: self, action: #selector(cameraButtonPressed))
        navigationItem.rightBarButtonItem = cameraButton
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    @objc private func cameraButtonPressed() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert userPickedImage to CIImage.")
            }
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    private func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: .init()).model) else {
            fatalError("Loading CoreML Model failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to form the request results.")
            }
            print(results)
            if let firstResult = results.first {
                self.textOutput.text = "It's propably a \(firstResult.identifier) with \(firstResult.confidence) accuracy."
            }
        }
            
            let handler = VNImageRequestHandler(ciImage: image)
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
