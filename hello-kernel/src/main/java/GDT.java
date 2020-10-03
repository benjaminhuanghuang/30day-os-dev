/**
 * BYTE 7 ..... BYTE 0
 */
public class GDT
{
    byte[] segmentLengthLow = new byte[2];  // BYTE1 BYTE0

    byte[] baseAddressLow = new byte[3];  // BYTE4 BYTE3 BYTE2

    byte[] attribute = new byte[2];

    byte addressHigh;        // BYTE 7

}
