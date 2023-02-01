import torch

# even if check is calling "cuda", the function works for CUDA and ROCm devices
if torch.cuda.is_available():
    print("TORCH CUDA device name: " + torch.cuda.get_device_name(0))
    print("TORCH CUDA device count: " + str(torch.cuda.device_count()))
else:
    print("TORCH device name: " + "[CPU]")