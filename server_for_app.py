import socket
import threading

# Initialize running total
running_total = 0
lock = threading.Lock()  # Thread-safe lock for updating total

def handle_client(client_socket):
    global running_total
    try:
        # Receive data
        data = client_socket.recv(1024).decode('utf-8').strip()
        if not data:
            return

        # Expect data in format "number:<value>"
        if data.startswith("number:"):
            try:
                number = int(data.split(":")[1])
                with lock:
                    running_total += number
                    response = f"total:{running_total}"
                client_socket.send(response.encode('utf-8'))
            except (ValueError, IndexError):
                client_socket.send("error:Invalid number".encode('utf-8'))
        elif data.startswith("request:"):
            try:
                number = int(data.split(":")[1])
                with lock:
                    response = f"total:{running_total}"
                client_socket.send(response.encode('utf-8'))
            except (ValueError, IndexError):
                client_socket.send("error:Invalid number".encode('utf-8'))
        else:
            client_socket.send("error:Invalid format".encode('utf-8'))
    except Exception as e:
        client_socket.send(f"error:{str(e)}".encode('utf-8'))
    finally:
        client_socket.close()

def start_server():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind(('0.0.0.0', 5072))
    server.listen(5)
    print("Server listening on 192.168.1.126:5072")

    while True:
        client_socket, addr = server.accept()
        print(f"Connection from {addr}")
        client_thread = threading.Thread(target=handle_client, args=(client_socket,))
        client_thread.start()

if __name__ == "__main__":
    start_server()
