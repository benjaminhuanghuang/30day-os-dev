
用java做一个最小的操作系统内核2.
https://blog.csdn.net/tyler_download/article/details/51761750


##  Complie the kernel.asm
```
  brew install nasm
  
  nasm kernel.asm -o kernel.bat
```


## Use java app write the kernel.bat into a img file



## Create a VM in virtual box and insert the img file as a floppy disk
vm settings -> storagte -> add Floppy and insert image file
