rm floppy.img
# create img
dd if=/dev/zero of=floppy.img bs=512 count=2880

# format img
mkfs.vfat floppy.img

