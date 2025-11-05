//
//  UploadPhotoView.swift
//  HomeDesignAI
//
//  Photo upload screen with camera and library options
//

import SwiftUI

struct UploadPhotoView: View {
    @ObservedObject var viewModel: HomeDesignViewModel

    var body: some View {
        ZStack {
            AppGradients.twilight
                .ignoresSafeArea()

            FestiveSnowfallView()

            VStack(spacing: AppSpacing.lg) {
                Spacer()

                VStack(spacing: AppSpacing.sm) {
                    Text("Upload Your Space")
                        .font(AppFonts.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Use your camera or pick from your photos. No storage, just instant holiday styling.")
                        .font(AppFonts.callout)
                        .foregroundColor(Color.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.xl)
                }

                VStack(spacing: AppSpacing.md) {
                    UploadOptionButton(
                        title: "Take a New Photo",
                        subtitle: "Frame your room and let the magic begin",
                        icon: "camera.fill",
                        actionColor: AppColors.accent
                    ) {
                        viewModel.selectImageSource(.camera)
                    }
                    .accessibilityLabel("Take a new photo")
                    .accessibilityHint("Opens camera to capture your space for decoration")

                    UploadOptionButton(
                        title: "Choose From Library",
                        subtitle: "Select an existing room photo",
                        icon: "photo.on.rectangle",
                        actionColor: AppColors.surface.opacity(0.9),
                        iconColor: AppColors.primary,
                        textColor: AppColors.primary
                    ) {
                        viewModel.selectImageSource(.photoLibrary)
                    }
                    .accessibilityLabel("Choose from photo library")
                    .accessibilityHint("Select an existing photo of your space")
                }

                Spacer()

                Button(action: {
                    viewModel.goToStep(.welcome)
                }) {
                    Text("Back to Welcome")
                        .font(AppFonts.callout)
                        .foregroundColor(Color.white.opacity(0.75))
                        .padding(.vertical, AppSpacing.sm)
                        .padding(.horizontal, AppSpacing.lg)
                }
                .pressAnimation()

                Spacer(minLength: AppSpacing.lg)
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, AppSpacing.lg)
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(
                sourceType: viewModel.imagePickerSourceType,
                onImageSelected: { image in
                    viewModel.imageSelected(image)
                }
            )
        }
    }
}

// MARK: - Upload Option Card

struct UploadOptionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let actionColor: Color
    var iconColor: Color = AppColors.primary
    var textColor: Color = .white
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(iconColor)
                    .frame(width: 52, height: 52)
                    .background(AppColors.surface)
                    .cornerRadius(18)
                    .shadow(color: AppColors.deepShadow.opacity(0.1), radius: 6, x: 0, y: 4)

                Text(title)
                    .font(AppFonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)

                Text(subtitle)
                    .font(AppFonts.caption)
                    .foregroundColor(textColor.opacity(0.75))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.lg)
            .background(
                LinearGradient(
                    colors: [
                        actionColor.opacity(0.98),
                        actionColor.opacity(0.72)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(AppCornerRadius.lg)
            .shadow(color: AppColors.deepShadow.opacity(0.25), radius: 14, x: 0, y: 8)
        }
        .pressAnimation()
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImageSelected: (UIImage) -> Void

    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageSelected(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
