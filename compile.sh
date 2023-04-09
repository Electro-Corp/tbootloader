rm parts/part1.bin parts/part2.bin boot.bin
echo "Compiling Stage 1"
nasm src/main.s -f bin -o parts/part1.bin
echo "Compile Stage 2"
nasm src/part2.s -f bin -o parts/part2.bin
#echo "Compile fs floppy"
nasm src/fs.s -f bin -o parts/fs.o
dd if=parts/part1.bin bs=512 seek=0 of=boot.bin
dd if=parts/part2.bin of=boot.bin bs=512 seek=1 conv=notrunc
dd if=parts/fs.o of=boot.bin bs=512 seek=4
#dd if=fs.o of=fs.bin bs=512 seek=0 #conv=notrunc
echo "Creating Kernel floppy"
#dd if=kernel bs=512 seek=0 of=t54.bin
#dd if=kernel of=boot.bin bs=512 seek=2 conv=notrunc
qemu-system-x86_64 -fda boot.bin
