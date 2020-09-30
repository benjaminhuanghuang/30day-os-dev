rm myos.img

# Create a img file
qemu-img create -f raw myos.img 1440k
  
# Wirte loader.bin (add 0x55AA) and kernel.bin to myos.img by using the java app

qemu-system-x86_64 -fda myos.img -boot a

