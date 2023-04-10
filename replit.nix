{ pkgs }: {
    deps = [
        pkgs.bochs
        pkgs.hexdump
        pkgs.qemu
        pkgs.nasm
    ];
}