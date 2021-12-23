#!/bin/bash
echo "Making"
make clean
make
echo "Running"
qemu-system-riscv64 -machine virt -smp 4 -m 128M -nographic \
  -device virtio-blk-pci,drive=drive0,id=virtblk0,num-queues=4 \
  -drive file=data/yggdrasil.qcow2,if=none,id=drive0 \
  -vga virtio \
  -bios yggdrasil
echo "Done"
