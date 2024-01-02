//
//  ImageWithROI.swift
//  Grocemate
//
//  Created by Giorgio Latour on 12/17/23.
//

import SwiftUI

struct ImageWithROI: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var ingredientRecognitionHandler: IngredientRecognitionHandler

    @Environment(\.dismiss) var dismiss

    var image: UIImage

    @State private var boundingBoxWidth: CGFloat = 100
    @State private var boundingBoxHeight: CGFloat = 100

    @State private var location: CGPoint = .init(x: 0, y: 0)
    @State private var imageSize: CGSize = CGSize(width: 100, height: 100)

    @GestureState private var startLocation: CGPoint?
    @GestureState private var startMagnification: CGFloat?

    var body: some View {
        VStack(spacing: 25) {
            titleMessage

            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .overlay {
                        GeometryReader { geo in
                            Color.clear
                                .updateImageSizePreferenceKey(geo.size)
                        }
                    }

                VStack {
                    /// The geometry reader resets the coordinate system so we can get the
                    /// location of the bounding box relative to the image.
                    GeometryReader { _ in
                        /// This is the view that's going to be resized by the gesture.
                        roiView
                    }
                    .frame(width: imageSize.width, height: imageSize.height, alignment: .topLeading)
                }
            }

            identifyButton
        }
        .onPreferenceChange(ImageSizePreferenceKey.self) { size in
            imageSize = size
        }
        .padding()
    }

    // MARK: - Gestures
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { dragValue in
                var newLocation = startLocation ?? location
                /// Set a minimum and maximum constraint on the x and y location
                /// such that the bounding box cannot be dragged outside of the image frame.
                newLocation.x = min(
                    max(0, newLocation.x + dragValue.translation.width),
                    (imageSize.width - boundingBoxWidth)
                )
                newLocation.y = min(
                    max(0, newLocation.y + dragValue.translation.height),
                    (imageSize.height - boundingBoxHeight)
                )

                self.location = newLocation
            }
            .updating($startLocation) { _, startLocation, _ in
                startLocation = startLocation ?? location
            }
    }

    private var resizeDrag: some Gesture {
        DragGesture()
            .onChanged { dragValue in
                /// When resizing, we want to constrain the bounding box so that
                /// it still cannot be resized out of the image frame.

                /// If the box is hitting the left or right edge, only allow making the width
                /// smaller (achieved by dragging toward the left).
                if (location.x + boundingBoxWidth) >= imageSize.width {
                    guard dragValue.translation.width < 0 else { return }
                }

                self.boundingBoxWidth = min(
                    max(50, self.boundingBoxWidth + dragValue.translation.width),
                    imageSize.width
                )

                /// If the box is hitting the top or bottom edge, only allow making the height
                /// smaller (achieved by dragging toward the top).
                if (location.y + boundingBoxHeight) >= imageSize.height {
                    guard dragValue.translation.height < 0 else { return }
                }

                self.boundingBoxHeight = min(
                    max(50, self.boundingBoxHeight + dragValue.translation.height),
                    imageSize.height
                )
            }
    }

    // MARK: - Subviews
    private var identifyButton: some View {
        Button {
//            print(
//                CGRect(
//                    origin: CGPoint(x: location.x, y: location.y),
//                    size: CGSize(width: boundingBoxWidth, height: boundingBoxHeight)
//                )
//            )

            let roi = ingredientRecognitionHandler.convertBoundingBoxToNormalizedBoxForVisionROI(
                boxLocation: location, boxSize: CGSize(width: boundingBoxWidth, height: boundingBoxHeight),
                imageSize: imageSize)

//            print(roi)

            ingredientRecognitionHandler.recognizeIngredientsInImage(image: image, region: roi)

            homeViewModel.sheet = nil
            homeViewModel.selectedImage = nil
            homeViewModel.selectedPhotosPickerItem = nil

            dismiss()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "sparkle.magnifyingglass")
                Text("Identify")
            }
            .fontWeight(.bold)
            .fontDesign(.rounded)
            .tint(.white)
            .padding(5)
        }
        .frame(width: 150, height: 50)
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(
            .roundedRectangle(radius: 30)
        )
    }

    private var roiView: some View {
        ZStack(alignment: .bottomTrailing) {
            Rectangle()
                .stroke(style: .init(lineWidth: 2, dash: [5]))
                .fill(.yellow)
                .contentShape(Rectangle())
                .frame(width: boundingBoxWidth, height: boundingBoxHeight)
            /// This is the "drag handle" positioned on the lower-left corner of this stack.
            Rectangle()
                .fill(.yellow)
                .frame(width: 30, height: 30)
                .gesture(
                    resizeDrag
                )
        }
        .frame(width: boundingBoxWidth, height: boundingBoxHeight, alignment: .topLeading)
        .position(x: location.x + boundingBoxWidth / 2, y: location.y + boundingBoxHeight / 2)
        .gesture(
            dragGesture
        )
    }

    private var titleMessage: some View {
        Text("Drag and resize the yellow box around your ingredients!")
            .multilineTextAlignment(.center)
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .padding(.horizontal)
    }
}

struct ImageWithROI_Previews: PreviewProvider {
    static var previews: some View {
        ImageWithROI(image: UIImage(named: "choonsik")!)
    }
}
