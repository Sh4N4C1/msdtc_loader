section .text

extern GetLoadLibrary

global WorkProxyDllLoadCallBack

WorkProxyDllLoadCallBack:
mov rcx, rdx
xor rdx, rdx
call GetLoadLibrary
jmp rax
