rm myos.img

# Create a img file
dd if=/dev/zero of=myos.img bs=512 count=2880
mkfs.vfat -F 12 myos.img

sudo mount -o loop myos.img /media/floppy1
sudo cp loader.bin /media/floppy1/ -v
sudo umount /media/floppy1

dd if=boot.bin of=myos.img count=1 bs=512 conv=notrunc

qemu-system-x86_64 -fda myos.img -boot a

