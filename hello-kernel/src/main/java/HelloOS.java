import java.io.*;
import java.util.ArrayList;

public class HelloOS {

    private ArrayList<Integer> imgByteToWrite = new ArrayList<>();

    /**
     * The binary code of the kernel
     * BIOS will load it to address 0x8000 and execute it.
     * The code calls BIOS interrupt to print a message on screen
     */
    private void readKernelFromFile(String fileName) {
        File file = new File(fileName);
        InputStream in = null;

        try {
            in = new FileInputStream(file);
            int tempbyte;
            while ((tempbyte = in.read()) != -1) {
                imgByteToWrite.add(tempbyte);
            }
        } catch (IOException e) {
            e.printStackTrace();
            return;
        }

        /**
         BIOS will load 512 bytes if the last two bytes of the 512 bytes are 0x55, 0xaa
         */
        imgByteToWrite.add(0x55);
        imgByteToWrite.add(0xaa);
        imgByteToWrite.add(0xf0);
        imgByteToWrite.add(0xff);
        imgByteToWrite.add(0xff);

    }

    public HelloOS(String message) {
        readKernelFromFile("kernel.bat");

        int len = 0x168000;
        int curSize = imgByteToWrite.size();
        for (int l = 0; l < len - curSize; l++) {
            imgByteToWrite.add(0);
        }

    }

    public void makeFloppy() {

        try {
            /**
             * Create a bin file has size 1474560(= 1440 * 1024 ) bytes. Write imgContent to it.
             * The bin file will be loaded as a floppy disk by the virtual machine
             */
            DataOutputStream out = new DataOutputStream(new FileOutputStream("myos.img"));
            for (int i = 0; i < imgByteToWrite.size(); i++) {
                out.writeByte(imgByteToWrite.get(i).byteValue());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public static void main(String[] args) {
        HelloOS os = new HelloOS("Hello, this is my first line of os");
        os.makeFloppy();
    }


}
