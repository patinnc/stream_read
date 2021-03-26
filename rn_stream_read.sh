#!/bin/bash

OS=LNX
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
   NUM_CPUS=`grep -c processor /proc/cpuinfo`
elif [[ "$OSTYPE" == "darwin"* ]]; then
   OS=MAC
   # Mac OSX
   NUM_CPUS=`sysctl -a | grep machdep.cpu.thread_count | awk '{v=$2+0;printf("%d\n", v);exit;}'`
fi

export OMP_DISPLAY_ENV=VERBOSE
ODIR=/root/output/tst_rd_01
mkdir $ODIR

USE_NTIMES=100
USE_NTIMES=20
ARR_SZ_0=67108864  # get 
ARR_SZ_a=26214400  # 200MB arr sz
ARR_SZ_a=52428800  # 400MB arr sz
ARR_SZ_1=134217728  # get 170 1thr/cpu, int all arr
ARR_SZ_2=268435456  # get 173 1thr/cpu, int all arr
ARR_SZ_4=536870912  # get 179 1thr/cpu, int all arr
ARR_SZ_8=1073741824 # get 180 1thr/cpu, int all arr
ARR_SZ_16=2147483648
ARR_SZ=$ARR_SZ_8
USE=stream
USE=stream_read
if [ "$OS" == "MAC" ]; then
  ARR_SZ=$ARR_SZ_1
  # had to "brew install llvm"
  export PATH="/usr/local/opt/llvm/bin:$PATH"
  export OMP_PROC_BIND=true
  #For compilers to find llvm you may need to set:
  export LDFLAGS="-L/usr/local/opt/llvm/lib"
  export CPPFLAGS="-I/usr/local/opt/llvm/include"
  clang $USE.c -O3 -march=native -fno-builtin -DSTREAM_ARRAY_SIZE=$ARR_SZ -mcmodel=medium -DNTIMES=20 -DOFFSET=0 -DSTREAM_TYPE=double -fopenmp -o $USE.x -L/usr/local/opt/llvm/lib
else
  gcc $USE.c -O3 -march=native -fno-builtin -DSTREAM_TYPE_READ=int32_t  -DSTREAM_ARRAY_SIZE=$ARR_SZ -mcmodel=medium -DNTIMES=$USE_NTIMES -DOFFSET=0 -DSTREAM_TYPE=double -fopenmp -o $USE.x
fi
if [ $? != 0 ]; then
  echo error
  exit 1
fi
CORES=$((NUM_CPUS/2))
echo NUM_CPU= $NUM_CPUS

EVERY=2

#for i in 0; do
#for i in 0 1; do
for i in 0 1 2; do
EVERY=$i
if [ $EVERY == 0 ]; then
  THRDS=$NUM_CPUS
  BY=1
  TM1=$((THRDS-1))
else
  THRDS=$((CORES/EVERY))
  BY=$EVERY
  TM1=$((CORES-1))
fi
export OMP_NUM_THREADS=$THRDS
export GOMP_CPU_AFFINITY="0-${TM1}:$BY"
echo OMP_NUM_THREADS=$OMP_NUM_THREADS
echo GOMP_CPU_AFFINITY=$GOMP_CPU_AFFINITY

BIN=./$USE.x

if [ 1 == 1 ]; then
  $BIN
else
  /root/itp/do_perf3.sh -F -I 1 -p $ODIR -x $BIN  > $ODIR/str.txt
  cat /root/output/tst_rd_01/str.txt |grep Read:
  ./get_bw.sh /root/output/tst_rd_01/sys_10_perf_stat.txt 
fi
done

exit
