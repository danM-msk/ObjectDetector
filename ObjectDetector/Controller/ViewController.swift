	//  Created by Daniyar Mamadov on 22.06.2022.

	import UIKit
	import CoreML
	import Vision

	class ViewController: UIViewController,
						  UIImagePickerControllerDelegate,
						  UINavigationControllerDelegate {
		
		private let imageView: UIImageView = {
			let view = UIImageView(frame: CGRect(x: 0,
												 y: 0,
												 width: UIScreen.main.coordinateSpace.bounds.width,
												 height: UIScreen.main.coordinateSpace.bounds.height))
			return view
		}()
		
		private let imagePicker: UIImagePickerController = {
			let controller = UIImagePickerController()
			return controller
		}()

		override func viewDidLoad() {
			super.viewDidLoad()
			view.addSubview(imageView)
			view.backgroundColor = .white
			title = "coreML"
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
				imageView.image = userPickedImage
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
			}
			
			let handler = VNImageRequestHandler(ciImage: image)
			do {
				try handler.perform([request])
			} catch {
				print(error)
			}
		}
	}

