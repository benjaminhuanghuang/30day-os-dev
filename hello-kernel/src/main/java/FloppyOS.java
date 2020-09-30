import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

/**
 * Read boot.bin into Floppy.
 * Write Floppy to a floppy disk img file
 */
public class FloppyOS {
    private Floppy floppyDisk = new Floppy();

    private void writeFileToFloppy(String fileName) {
        File file = new File(fileName);
        InputStream in = null;

        try {
            in = new FileInputStream(file);
            byte[] buf = new byte[512];
            buf[510] = 0x55;
            buf[511] = (byte) 0xaa;

            if (in.read(buf) != -1) {
                floppyDisk.writeFloppy(Floppy.MAGNETIC_HEAD.MAGNETIC_HEAD_0, 0, 1, buf);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public FloppyOS(String s) {
        writeFileToFloppy(s);
    }

    public void makeFloppy() {
        floppyDisk.makeFloppy("system.img");
    }

    public static void main(String[] args) {
        FloppyOS op = new FloppyOS("boot.bat");
        op.makeFloppy();
    }
}
