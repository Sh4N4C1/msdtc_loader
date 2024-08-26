CCX64 := x86_64-w64-mingw32-gcc
SRC := src
INJECTION_SRC := src/method
CFLAGS_DEBUG := -s -w -static -fpermissive -Wl,--subsystem,console -nostdlib -Wl,--entry="Main" -Iinclude -Isrc/method -lkernel32 -luser32 -masm=intel -DDEBUG -DREMOTE
CFLAGS := -s -w -static -fpermissive -Wl,--subsystem,windows -nostdlib -Wl,--entry="Main" -Iinclude -Isrc/method -lkernel32 -masm=intel -DREMOTE

CFLAGS_LOCAL_DEBUG := -s -w -static -fpermissive -Wl,--subsystem,console -nostdlib -Wl,--entry="Main" -Iinclude -Isrc/method -lkernel32 -luser32 -masm=intel -DDEBUG -DLOCAL
CFLAGS_LOCAL := -s -w -static -fpermissive -Wl,--subsystem,windows -nostdlib -Wl,--entry="Main" -Iinclude -Isrc/method -lkernel32 -masm=intel -DLOCAL
DLL_LOCAL := -s -w -static -fpermissive -Wl,--subsystem,console -nostdlib -Wl,--entry="DllMain" -Iinclude -shared -Isrc/method -lkernel32 -masm=intel -DLOCAL -o ./local.dll
DLL_LOCAL_DEBUG := -s -w -static -fpermissive -Wl,--subsystem,console -nostdlib -Wl,--entry="DllMain" -Iinclude -luser32 -shared -Isrc/method -lkernel32 -masm=intel -DLOCAL -DDEBUG -o ./local.dll

threadless_remote_injection:
	nasm -f win64 ./src/asm/syscall.s -o ./src/asm/syscall.o
	nasm -f win64 ./src/asm/proxydll.s -o ./src/asm/proxydll.o
	nasm -f win64 ./src/asm/proxycall.s -o ./src/asm/proxycall.o
	@ $(CCX64) $(SRC)/*.c $(INJECTION_SRC)/threadless_injection.c $(SRC)/asm/*.o $(CFLAGS)
threadless_remote_injection_debug:
	nasm -f win64 ./src/asm/syscall.s -o ./src/asm/syscall.o
	nasm -f win64 ./src/asm/proxydll.s -o ./src/asm/proxydll.o
	nasm -f win64 ./src/asm/proxycall.s -o ./src/asm/proxycall.o
	@ $(CCX64) $(SRC)/*.c $(INJECTION_SRC)/threadless_injection.c $(SRC)/asm/*.o $(CFLAGS_DEBUG)
threadless_local_injection_debug:
	nasm -f win64 ./src/asm/syscall.s -o ./src/asm/syscall.o
	nasm -f win64 ./src/asm/proxydll.s -o ./src/asm/proxydll.o
	nasm -f win64 ./src/asm/proxycall.s -o ./src/asm/proxycall.o
	@ $(CCX64) $(SRC)/*.c $(INJECTION_SRC)/threadless_injection.c $(SRC)/asm/*.o $(CFLAGS_LOCAL_DEBUG)
threadless_local_injection:
	nasm -f win64 ./src/asm/syscall.s -o ./src/asm/syscall.o
	nasm -f win64 ./src/asm/proxydll.s -o ./src/asm/proxydll.o
	nasm -f win64 ./src/asm/proxycall.s -o ./src/asm/proxycall.o
	@ $(CCX64) $(SRC)/*.c $(INJECTION_SRC)/threadless_injection.c $(SRC)/asm/*.o $(CFLAGS_LOCAL)
threadless_local_injection_dll:
	nasm -f win64 ./src/asm/syscall.s -o ./src/asm/syscall.o
	nasm -f win64 ./src/asm/proxydll.s -o ./src/asm/proxydll.o
	nasm -f win64 ./src/asm/proxycall.s -o ./src/asm/proxycall.o
	@ $(CCX64) $(SRC)/*.c ./linker.def $(INJECTION_SRC)/threadless_injection.c $(SRC)/asm/*.o $(DLL_LOCAL)
threadless_local_injection_dll_debug:
	nasm -f win64 ./src/asm/syscall.s -o ./src/asm/syscall.o
	nasm -f win64 ./src/asm/proxydll.s -o ./src/asm/proxydll.o
	nasm -f win64 ./src/asm/proxycall.s -o ./src/asm/proxycall.o
	@ $(CCX64) $(SRC)/*.c ./linker.def $(INJECTION_SRC)/threadless_injection.c $(SRC)/asm/*.o $(DLL_LOCAL_DEBUG)
clean:
	@ rm -rf $(DIST)/*
