import serial.tools.list_ports

def list_serial_ports():
    # Retrieve a list of all available serial ports
    ports = serial.tools.list_ports.comports()    
    available_ports = []
    for port, desc, hwid in sorted(ports):
        print(f"{port}: {desc} ")
        available_ports.append(port)
    
    if not available_ports:
        print("No serial ports were found!")
    else:
        print(f"Available serial ports:\n{available_ports}")

if __name__ == "__main__":
    list_serial_ports()