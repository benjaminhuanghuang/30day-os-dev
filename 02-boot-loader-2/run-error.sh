rm myos.img

# Create a img file
dd if=boot.bin of=myos.img count=1 bs=512 conv=notrunc

sudo mount -o loop myos.img /media/floppy1
# get error: No space left on device
sudo cp loader.bin /media/floppy1/ -v
sudo umount /media/floppy1

qemu-system-x86_64 -fda myos.img -boot a

