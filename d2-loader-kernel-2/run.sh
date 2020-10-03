rm myos.img

# Create a img file
#qemu-img create -f raw myos.img 1440k
dd if=/dev/zero of=myos.img bs=512 count=2880
  
# Wirte loader.bin (add 0x55AA) and kernel.bin to myos.img by using the java app
dd if=loader.bin of=myos.img count=1 bs=512 conv=nottunc
sudo mount -o loop -t vfat ./myos.img /media/floppy1
sudo cp kernel.bin /media/floppy1/kenel.bin
sudo unmount /media/floppy1

qemu-system-x86_64 -fda myos.img -boot a

