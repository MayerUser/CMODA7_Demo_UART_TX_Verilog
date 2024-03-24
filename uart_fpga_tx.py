import serial
import time

# Replace 'COM14' with your serial port name
serial_port = 'COM14'
baud_rate = 9600
parity = serial.PARITY_EVEN
#parity = serial.PARITY_NONE
stop_bits = serial.STOPBITS_ONE
bytesize = serial.EIGHTBITS
 
def main():
    try:
        # Initialize serial connection
        ser = serial.Serial(port=serial_port, 
                            baudrate=9600, 
                            parity=parity, 
                            stopbits=stop_bits, 
                            bytesize=bytesize,
                            timeout=1)

        while True:
            # Send data
            test_string = 'Hello,UART!\n'
            for char in test_string:
                ser.write(char.encode('ascii'))
                print("0x%02x"%(int.from_bytes(char.encode('ascii')))) #Print current character in HEX format;
                time.sleep(2)

    except serial.SerialException as e:
        print(f"Error opening the serial port: {e}")

    except KeyboardInterrupt:
        print("\nProgram terminated by user.")

    finally:
        # Close the serial connection
        if 'ser' in locals() or 'ser' in globals():
            ser.close()
            print("Serial connection closed.")

if __name__ == "__main__":
    main()
