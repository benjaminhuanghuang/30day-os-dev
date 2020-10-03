# create img
dd if=/dev/zero of=floppy.img bs=512 count=2880

# format img
mkfs.vfat floppy.img
sudo mount -o loop - t vfat ./floppy.img /media/floppy1
sudo cp kernel.bin /media/floppy1/kenel.bin
