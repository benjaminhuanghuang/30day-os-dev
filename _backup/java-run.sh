rm myos.img

# Create a img file
qemu-img create -f raw myos.img 1440k
  
##dd if=boot.bin of=myos.img count=1 bs=512 (this command can NOT add 0x55AA to sector)
##dd if=loader.bin of=myos.img count=1 bs=512 seek=1

# Wirte boot.bin (add set 0x55AA) and loader.bin to myos.img by using the java app
# FloppyOS read boot.bin and loader.bin from current dir
java -cp ../hello-kernel/target/classes/ FloppyOS

qemu-system-x86_64 -fda myos.img -boot a

