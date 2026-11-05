# Create Docker Image
# I created the another dockerfile to adpat to my pytorch and cuda version of 120

cd ~/dynosam_pkg/DynoSAM/docker
./build_docker_blackwell.sh


# ------------------------------------------------------------------------------------------------------
# Test after the image build

docker image inspect acfr_rpg/dyno_sam_blackwell >/dev/null && \
echo "Image exists: acfr_rpg/dyno_sam_blackwell"

docker run --rm --gpus all --entrypoint bash acfr_rpg/dyno_sam_blackwell -lc '
set -euo pipefail

source /opt/ros/kilted/setup.bash

echo
echo "=== GPU / CUDA ==="
nvidia-smi --query-gpu=name,driver_version --format=csv,noheader
nvcc --version

echo
echo "=== PyTorch / TensorRT ==="
python3 - <<PY
import torch
import tensorrt

print("PyTorch:", torch.__version__)
print("CUDA available:", torch.cuda.is_available())
print("GPU:", torch.cuda.get_device_name(0))
print("TensorRT:", tensorrt.__version__)
PY

echo
echo "=== ROS 2 ==="
ros2 pkg list | grep -x rclcpp

echo
echo "=== OpenCV CUDA ==="
python3 - <<PY
import cv2

print("OpenCV:", cv2.__version__)
print("CUDA devices:", cv2.cuda.getCudaEnabledDeviceCount())
PY

echo
echo "=== GTSAM / OpenGV ==="
ldconfig -p | grep libgtsam
find /usr/local -type f \( -name "libopengv*" -o -name "*OpenGV*Config.cmake" \) -print | head -10
'

# ------------------------------------------------------------------------------------------------------
# Build the docker container based on the dataset path
cd ~/dynosam_pkg/DynoSAM/docker

# Dataset stored here in Disk E
LOCAL_DATA_FOLDER=/mnt/e/AV_Dataset 
chmod u+x create_container_blackwell.sh     
./create_container_blackwell.sh   

docker exec -it dyno_sam_blackwell bash
source /opt/ros/kilted/setup.bash
ls /root/data/kitti-0004

cd /home/user/dev_ws
export MAKEFLAGS="-j10" && clear && colcon build
source install/setup.bash


# ------------------------------------------------------------------------------------------------------
# Run the Docker container everytime we run it
docker start dyno_sam_blackwell
docker exec -it dyno_sam_blackwell bash

source /opt/ros/kilted/setup.bash
source /home/user/dev_ws/install/setup.bash

cd /home/user/dev_ws

# Only needed when you edited any source .py/.cpp/.yaml file:
colcon build --packages-select dynosam_utils
source install/setup.bash

# Avoid interactive Matplotlib windows during analysis
export MPLBACKEND=Agg

# OFFLINE dataset KITTI frontend only testing with supplied masks
time ros2 run dynosam_utils eval_launch.py \
  --dataset_path /root/data/kitti-0004 \
  --params_path /home/user/dev_ws/src/core/dynosam/params_kitti_eval/ \
  --output_path /root/results/DynoSAM \
  --name kitti_0004_frontend \
  --run_pipeline \
  --data_provider_type=0 \
  --use_backend=false \
  --use_dynamic_track=true \
  --use_frontend_logger=true \
  --use_opencv_display=true

# Evaluation, create pdf trajectory
ros2 run dynosam_utils eval_launch.py \
  --output_path /root/results/DynoSAM \
  --name kitti_0004_frontend \
  --run_analysis

# OFFLINE dataset KITTI frontend only with YOLO processed masks and first 100 frames
time ros2 run dynosam_utils eval_launch.py \
  --dataset_path /root/data/kitti-0004 \
  --params_path /home/user/dev_ws/src/core/dynosam/params_kitti_yolo_test/ \
  --output_path /root/results/DynoSAM \
  --name kitti_0004_yolo_first100 \
  --run_pipeline \
  --data_provider_type=0 \
  --ending_frame=100 \
  --use_backend=false \
  --use_dynamic_track=true \
  --use_frontend_logger=true \
  --use_opencv_display=true

# Evaluation, create pdf trajectory
ros2 run dynosam_utils eval_launch.py \
  --output_path /root/results/DynoSAM \
  --name kitti_0004_yolo_first100 \
  --run_analysis