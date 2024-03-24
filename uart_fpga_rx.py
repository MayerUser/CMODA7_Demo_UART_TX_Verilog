import serial
import time

# Replace 'COM14' with your serial port name
serial_port = 'COM14'
baud_rate = 9600
# parity = serial.PARITY_ODD
parity = serial.PARITY_NONE
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
        # Receive 100000 Byte
        data_cnter = [0] * 256
        for i in range(1000):
            rx_data = int.from_bytes(ser.read())
            data_cnter[rx_data] += 1
        print(data_cnter)
        
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
