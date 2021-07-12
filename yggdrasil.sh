#!/bin/bash
echo "Making"
make clean
make yggdrasil
echo "Running"
qemu-system-riscv64 -machine virt -smp 2 -m 128M -nographic \
  -device virtio-blk-pci,drive=drive0,id=virtblk0,num-queues=4 \
  -drive file=data/yggdrasil.qcow2,if=none,id=drive0 \
  -bios yggdrasil
echo "Done"