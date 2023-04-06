# Compile stage 1
echo "Compiling Stage 1"
nasm main.s -f bin -o part1.bin
dd if=part1.bin bs=512 of=part1.flop
qemu-system-x86_64 -fda part1.flop
