.model small
.stack 4096 

;Visual Laser 10 New - Ema3nto
.data          
    ;          "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    cryAlph DB "GTHEQUICKBSOWNFXJMPDVRLAZY"  ;cryptography alphabet ;0based array
    k       DW  0                            ;cryptography key
    
    rqS     DB "Insert the message (only letters)",10,13,'$'
    nkS     DB "Insert a number (less or equal than 25)",10,13,'$'
    caS     DB 10,13,'$'
    esS     DB "Encrypted message: $"
    mess    DB 100 dup (0)                   ;message entered by user
    output  DB 98 dup (0)                    ;encrypted message
    
    dieci   DW 10

.code
    .startup
    
       ;beginning of Buffered Input
       mov mess[0], 98
       
      req:
       ;show request string
       lea dx, rqS
       mov ah, 9
       int 21h
       
       ;buffered input
       lea dx, mess
       mov ah, 0Ah
       int 21h
       
       call checkStr           ;string validation
       push ax
       
       call acapo
       
       pop ax                  ;to restore the value "returned" by checkStr
       cmp ah, 0               ;string check
       je req
       
       
       ;entering multi-digit numbers
      numreq:
       lea dx, nkS
       mov ah, 9
       int 21h
       
       call insert_k
       
       call acapo
       
       cmp k, 25
       ja numreq              ;if above 25 re-request
             
             
       ;encryption
       mov cx, 0
       mov cl, mess[1]
       mov ah, 0
       mov si, 2
       
       perogni_let:
           
           cmp mess[si], 32    ;if space do not encrypt
           je noncript
           
           mov al, mess[si]
           add ax, k           ;sum mess[si] + k
            
           cmp al, 90          ;if sum above than 25 error -> OutOfRangeException
           jbe nonsup
               
               sub al, 26      ;subtract 26 from AL to go to the beginning of the array
           
           nonsup:
           sub al, 65
           mov ah, 0
           mov di, ax
           
           mov dl, cryAlph[di]
           mov output[si], dl  ;replace of the char
           
           noncript:
           
           inc si
       
       LOOP perogni_let
       
       ;print of encrypted message
       lea dx, esS
       mov ah, 9
       int 21h
       
       call prepara            ;prepare the encrypted message with $ at the end
       lea dx, output
       mov ah, 9
       int 21h
       
       call acapo
    
    .exit 
    
    
    ;procedures
    
    prepara  PROC
        mov bx, 0
        mov bl, mess[1]
        mov output[bx+2], '$' 
    RET
    
    acapo    PROC
       lea dx, caS
       mov ah, 9
       int 21h
    RET 
    
    checkStr PROC
       mov ch, 0 
       mov cl, mess[1]
       
       mov si, 2
       cyclec:
         cmp mess[si], 32     ;check if char == space
         je ok
         
         
         cmp mess[si], 'A'    ;check if char is included in Upper || Lower alphabet
          jae toZ
          mov ah, 0
          RET
         toZ:
         cmp mess[si], 'Z'
         jbe ok
         cmp mess[si], 'a'
         jae tozm 
         mov ah, 0
         RET
         tozm:
         cmp mess[si], 'z'
         jbe ok
         mov ah, 0
         RET
         
         ok:                   ;validation completed
         cmp mess[si], 'a'
         jb next
         
         xor mess[si], 32      ;do uppercase        
         
         next:
         
         inc si      
       
       LOOP cyclec 
         
    RET
    
    insert_k PROC
     mov bx, 0    
     
     cyclek:
     mov ah,01h
     int 21h
     
     cmp al, 13
     je finek
     
     mov ah, 0
     push ax    ;put the inserted number into the stack
     
     mov ax, bx ;moltiply bx by 10
     mul dieci
     mov bx, ax
     
     pop ax     ;sum bx + entered number
     sub ax, 48
     add bx, ax     
     
     
     jmp cyclek
     
     finek: 
     
     mov k, bx     
    RET
END