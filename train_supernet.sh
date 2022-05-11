#!/bin/bash
#SBATCH -N 1     # 需要使用的节点数
#SBATCH -J rk6      # 作业名字
# 需要使用的卡数

module load cuda/11.0
module load anaconda/2020.11
module load nccl/2.9.6-1_cuda11.0
module load cudnn/8.1.1.33_CUDA11.0
source activate pp


# python -m pip install paddlepaddle-gpu==2.0.2.post110 -f https://paddlepaddle.org.cn/whl/mkl/stable.html

# 将数据加载到内存中
mkdir -p /dev/shm/imagenet-mini
unzip -n /data/home/scv6681/run/data/imagenet_mini_train.zip -d /dev/shm/imagenet-mini > /dev/null
unzip -n /data/home/scv6681/run/data/imagenet_mini_val.zip -d /dev/shm/imagenet-mini > /dev/null

image_dir=/dev/shm/imagenet-mini
# 此处可填写运行程序的命令

# ignore warning 
python train_supernet.py run \
  --backbone resnet48_prelu \
  --max_epoch 70 \
  --batch_size 256 \
  --lr 0.001 \
  --warmup 5 \
  --dyna_batch_size 4 \
  --pretrained checkpoints/resnet48.pdparams \
  --save_dir checkpoints/res48_prelu_rankloss_run6 \
  --log_freq 50 \
  --visualdl_dir "./visualdl_log/res48_prelu_rankloss_run6" \
  --image_dir $image_dir
  # --resume checkpoints/res48-autoslim4 \

# autoslim3: wd=0 cosine_fix=0.05 max_epoch=100 
# autoslim_baseline: autoslim方法。
# autoslim_alphanet: 使用alphanet蒸馏损失函数。中途出现nan的问题
# autoslim_alphanet2: 针对nan的问题，删除min_lr，将iw_clip由5修改为3
# alphanet: 按照2的设置开始全量数据运行 [jobid]:134598

# rankloss_run1: 使用rank loss
# rankloss_run2: 使用rank_loss,coeff=1, sample 2 times 
# rankloss_run3: 使用rank_loss,coeff=1, sample 3 times, mish 
# rankloss_run4: rank_loss, sample 3 times, mish + zenscore

# for adjust parameter setting of rank loss 

# rankloss_run5: 使用rank_loss,coeff=1, sample 3 times, prelu 65.9
# rankloss_run6: 使用rank_loss, coeff=1, prelu, sample 6 times 


# rankloss_resume_run1: 