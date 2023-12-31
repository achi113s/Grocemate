//
//  CameraView.swift
//  Grocemate
//
//  Created by Giorgio Latour on 12/30/23.
//

import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    private var sourceType: UIImagePickerController.SourceType
    private var onImagePicked: (UIImage) -> Void

    @Environment(\.presentationMode) private var presentationMode

    public init(sourceType: UIImagePickerController.SourceType, onImagePicked: @escaping (UIImage) -> Void) {
        self.sourceType = sourceType
        self.onImagePicked = onImagePicked
    }

    func makeUIViewController(context: Context) -> some UIImagePickerController {
        let pickerVC = UIImagePickerController()
        pickerVC.sourceType = self.sourceType
        pickerVC.delegate = context.coordinator
        pickerVC.allowsEditing = false
        return pickerVC
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator {
            self.presentationMode.wrappedValue.dismiss()
        } onImagePicked: { image in
            self.onImagePicked(image)
        }
    }

    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let onDismiss: () -> Void
        private let onImagePicked: (UIImage) -> Void

        init(onDismiss: @escaping () -> Void, onImagePicked: @escaping (UIImage) -> Void) {
            self.onDismiss = onDismiss
            self.onImagePicked = onImagePicked
        }

        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            self.onDismiss()
            if let image = info[.originalImage] as? UIImage {
                print("image was picked")
                self.onImagePicked(image)
            }
        }

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.onDismiss()
        }
    }
}
