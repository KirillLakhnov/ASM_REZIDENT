;===========================================
; Put value registrs on buffer
;===========================================
; Entry:     AH = color
;            CX = name registrs
;            DX = shift relative to bp
; Exit:      BX = BX + 16
; Expects:   
; Destroys:  
;===========================================
one_registr_to_buffer   proc
                        push ax
                        PRINT_DECOR
              
                        mov byte ptr registr_buffer + bx, ch
                        add bx, 1
                        mov byte ptr registr_buffer + bx, ah
                        add bx, 1
                        mov byte ptr registr_buffer + bx, cl 
                        add bx, 1
                        mov byte ptr registr_buffer + bx, ah
                        add bx, 1
              
                        PRINT_EQUALS
                        
                        push bp
                        add  bp, dx
                        mov  ax, [bp] ; ax = value register
                        pop  bp
                        call HEX_print
              
                        PRINT_DECOR
                        pop ax
                        ret
one_registr_to_buffer   endp
;=========================================== 


;===========================================
; Put value registrs on buffer
;===========================================
; Entry:    
; Exit:      
; Expects:   
; Destroys:  
;=========================================== 
registrs_to_buffer  proc 
                    push ax
                    push bp 
                    mov  bp, sp
                    push bx cx dx ds             

                    xor bx, bx

                    mov registr_buffer + bx, 4e20h
                    add bx, 2
                    mov registr_buffer + bx, 4eDAh
                    add bx, 2
              
                    mov cx, 12
                    call print_vline
              
                    mov registr_buffer + bx, 4eBFh
                    add bx, 2
                    mov registr_buffer + bx, 4e20h
                    add bx, 2

                    mov ah, 4eh
                    ;=============================
                    mov cx, 4158h
                    mov dx, 28
                    call one_registr_to_buffer ; printf ax
                    ;=============================
                    mov cx, 4258h
                    mov dx, 26
                    call one_registr_to_buffer ; printf bx
                    ;=============================
                    mov cx, 4358h
                    mov dx, 24
                    call one_registr_to_buffer ; printf cx
                    ;=============================
                    mov cx, 4458h
                    mov dx, 22
                    call one_registr_to_buffer ; printf dx
                    ;=============================
                    mov cx, 5349h
                    mov dx, 20
                    call one_registr_to_buffer ; printf si
                    ;=============================
                    mov cx, 4449h
                    mov dx, 18
                    call one_registr_to_buffer ; printf di
                    ;=============================
                    mov cx, 4250h
                    mov dx, 16
                    call one_registr_to_buffer ; printf bp
                    ;=============================
                    mov cx, 5350h
                    mov dx, 14
                    call one_registr_to_buffer ; printf sp
                    ;=============================
                    mov cx, 4453h
                    mov dx, 12
                    call one_registr_to_buffer ; printf ds
                    ;=============================
                    mov cx, 4553h
                    mov dx, 10
                    call one_registr_to_buffer ; printf es
                    ;=============================
                    mov cx, 5353h
                    mov dx, 8
                    call one_registr_to_buffer ; printf ss
                    ;=============================
                    mov cx, 4353h
                    mov dx, 6
                    call one_registr_to_buffer ; printf cs
                    ;=============================
              
                    mov registr_buffer + bx, 4e20h
                    add bx, 2
                    mov registr_buffer + bx, 4eC0h
                    add bx, 2
              
                    mov cx, 12
                    call print_vline
              
                    mov registr_buffer + bx, 4eD9h
                    add bx, 2
                    mov registr_buffer + bx, 4e20h
              
                    pop ds dx cx bx bp ax
                    ret
registrs_to_buffer  endp
;=========================================== 

;===========================================
; SCANF OLD VIDEO BUFFER 
;===========================================
; Entry:    BX = pointer to buffer
; Exit:     None
; Expects:  None
; Destroys: AX, BX, DX, SI, DI, ES
;=========================================== 
old_video_to_buffer proc
                    push ax bx cx dx si es ds

                    push bx
                    
                    mov bx, 0b800h
                    mov es, bx
                    pop bx
                    
                    mov si, 0
                    
                    mov cx, 14
                    $$all_video_record: mov dx, 16
                                        $$string_video_record:  mov  ax,  es:[si]
                                                                mov [bx], ax

                                                                xor ax, ax
                                                                add bx, 2
                                                                add si, 2

                                                                dec dx
                                                                cmp dx, 0
                                                                jne $$string_video_record
                                        add  si, 128
                                        loop $$all_video_record
                    pop ds es si dx cx bx ax
                    ret
old_video_to_buffer endp
;=========================================== 


;===========================================
; PRINTF VIDEO BUFFER 
;===========================================
; Entry:    BX = pointer to buffer
; Exit:     None
; Expects:  None
; Destroys: BX, CX, DX, SI
;=========================================== 
printf_video_buffer proc
                    push bx cx dx si es ds
                    push bx
                    mov bx, 0b800h
                    mov es, bx
                    pop bx

                    mov si, 0
                    mov cx, 14
                    $$all_printf_video: mov dx, 16
                                        $$string_printf_video:  push bx
                                                                mov  bx,[bx]
                                                                mov  es:[si], bx
                                                                pop  bx
                                                                
                                                                add  bx, 2
                                                                add  si, 2

                                                                dec  dx
                                                                cmp  dx, 0
                                                                jne $$string_printf_video
                                        add si, 128
                                        loop $$all_printf_video

                    pop ds es si dx cx bx
                    ret
printf_video_buffer endp
;=========================================== 

;===========================================
; CMP BUFFER AND VIDEO AND UPDATE
;===========================================
; Entry:    BX = pointer to buffer for cmp
;           DI = pointer to buffer for write
; Exit:     None
; Expects:  None
; Destroys: AX, BX, DX, SI, DI, ES
;=========================================== 
cmp_buffer  proc
            push bx cx dx si di es ds
            push bx
            mov  bx, 0b800h
            mov  es, bx
            pop  bx

            mov si, 0
            mov cx, 14
            $$all_cmp:  mov dx, 16
                        $$string_cmp:   mov ax, es:[si]
                                        cmp ax, [bx]
                                        jne $$change
                                        jmp $$not_change

                        $$change:       mov [di], ax

                        $$not_change:   add di, 2
                                        add bx, 2
                                        add si, 2

                                        xor ax, ax
                                        dec dx
                                        cmp dx, 0
                                        jne $$string_cmp
                        add si, 128
                        loop $$all_cmp

            pop ds es di si dx cx bx
            ret
cmp_buffer  endp
;===========================================