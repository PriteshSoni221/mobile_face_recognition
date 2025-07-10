from facenet_pytorch import MTCNN
from PIL import Image
import torch

# Enhanced MTCNN setup for better face detection and alignment


def setup_mtcnn():
    """Setup MTCNN with optimal parameters for face alignment"""
    return MTCNN(
        image_size=112,  # Standard size for face recognition
        margin=0,
        min_face_size=20,
        thresholds=[0.6, 0.7, 0.7],  # More strict thresholds
        factor=0.709,
        post_process=True,
        keep_all=False,  # Only keep the best face
        device='cuda' if torch.cuda.is_available() else 'cpu'
    )


def preprocess_face_image(image_path: str, output_path: str = None):
    """
    Preprocess face image with alignment and cropping

    Args:
        image_path: Path to input image
        output_path: Optional path to save cropped face

    Returns:
        Preprocessed face tensor
    """
    mtcnn = setup_mtcnn()

    # Load image
    img = Image.open(image_path).convert('RGB')

    # Get cropped and aligned face
    img_cropped = mtcnn(img, save_path=output_path)

    if img_cropped is None:
        print("No face detected in the image")
        return None

    return img_cropped


# Example usage
if __name__ == "__main__":
    img_tensor = preprocess_face_image(
        "data/sample3.jpeg", "output/cropped_face3.jpeg")
    if img_tensor is not None:
        print(f"Face preprocessed successfully. Shape: {img_tensor.shape}")
