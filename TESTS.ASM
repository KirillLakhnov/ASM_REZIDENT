;===========================================
; 
;===========================================
; Entry:    
; Exit:      
; Expects:   
; Destroys:  
;=========================================== 
registrs_to_buffer  proc  
                    push dx           
                    push bp               
                    mov  bp, sp

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
                    ;=============================
                    PRINT_DECOR
              
                    mov registr_buffer + bx, 4e41h  
                    add bx, 2
                    mov registr_buffer + bx, 4e58h
                    add bx, 2
              
                    PRINT_EQUALS
              
                    mov ax, [bp + 26] ; ax = old ax
                    call HEX_print
              
                    PRINT_DECOR
                    ;=============================
                    PRINT_DECOR
              
                    mov registr_buffer + bx, 4e42h   
                    add bx, 2
                    mov registr_buffer + bx, 4e58h
                    add bx, 2
              
                    PRINT_EQUALS
              
                    mov ax, [bp + 24] ; ax = old bx
                    call HEX_print
              
                    PRINT_DECOR
                    ;=============================
                    PRINT_DECOR
              
                    mov registr_buffer + bx, 4e43h   
                    add bx, 2
                    mov registr_buffer + bx, 4e58h
                    add bx, 2
              
                    PRINT_EQUALS
              
                    mov ax, [bp + 22] ; ax = old cx
                    call HEX_print
              
                    PRINT_DECOR
                    ;=============================
                    PRINT_DECOR
              
                    mov registr_buffer + bx, 4e44h   
                    add bx, 2
                    mov registr_buffer + bx, 4e58h
                    add bx, 2
              
                    PRINT_EQUALS
              
                    mov ax, [bp + 20] ; ax = old dx
                    call HEX_print
              
                    PRINT_DECOR
                    ;=============================
                    PRINT_DECOR
              
                    mov registr_buffer + bx, 4e53h   
                    add bx, 2
                    mov registr_buffer + bx, 4e49h
                    add bx, 2
              
                    PRINT_EQUALS
              
                    mov ax, [bp + 18] ; ax = old si
                    call HEX_print
              
                    PRINT_DECOR
                    ;=============================
                    PRINT_DECOR
              
                    mov registr_buffer + bx, 4e44h   
                    add bx, 2
                    mov registr_buffer + bx, 4e49h
                    add bx, 2
              
                    PRINT_EQUALS
              
                    mov ax, [bp + 16] ; ax = old di
                    call HEX_print
              
                    PRINT_DECOR
                    ;=============================
                    PRINT_DECOR
              
                    mov registr_buffer + bx, 4e42h   
                    add bx, 2
                    mov registr_buffer + bx, 4e50h
                    add bx, 2
              
                    PRINT_EQUALS
              
                    mov ax, [bp + 14] ; ax = old bp
                    call HEX_print
              
                    PRINT_DECOR
                    ;=============================
                    PRINT_DECOR
              
                    mov registr_buffer + bx, 4e53h   
                    add bx, 2
                    mov registr_buffer + bx, 4e50h
                    add bx, 2
              
                    PRINT_EQUALS
              
                    mov ax, [bp + 12] ; ax = old sp
                    call HEX_print
              
                    PRINT_DECOR
                    ;=============================
                    PRINT_DECOR
              
                    mov registr_buffer + bx, 4e44h   
                    add bx, 2
                    mov registr_buffer + bx, 4e53h
                    add bx, 2
              
                    PRINT_EQUALS
              
                    mov ax, [bp + 10] ; ax = old ds
                    call HEX_print
              
                    PRINT_DECOR
                    ;=============================
                    PRINT_DECOR
              
                    mov registr_buffer + bx, 4e45h   
                    add bx, 2
                    mov registr_buffer + bx, 4e53h
                    add bx, 2
              
                    PRINT_EQUALS
              
                    mov ax, [bp + 8] ; ax = old es
                    call HEX_print
              
                    PRINT_DECOR
                    ;=============================
                    PRINT_DECOR
              
                    mov registr_buffer + bx, 4e53h   
                    add bx, 2
                    mov registr_buffer + bx, 4e53h
                    add bx, 2
              
                    PRINT_EQUALS
              
                    mov ax, [bp + 6] ; ax = old ss
                    call HEX_print
              
                    PRINT_DECOR
                    ;=============================
                    PRINT_DECOR
              
                    mov registr_buffer + bx, 4e43h   
                    add bx, 2
                    mov registr_buffer + bx, 4e53h
                    add bx, 2
              
                    PRINT_EQUALS
              
                    mov ax, [bp + 4] ; ax = old cs
                    call HEX_print
              
                    PRINT_DECOR
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
              
                    xor bx, bx
                    pop bp   
                    pop dx
                    ret
registrs_to_buffer  endp
;=========================================== 

;===========================================
; SCANF OLD VIDEO BUFFER 
;===========================================
; Entry:    
; Exit:      
; Expects:   
; Destroys:  
;=========================================== 
old_video_to_buffer proc
                    mov bx, 0b800h
                    mov es, bx
                    
                    mov bx, 0
                    mov si, 0
                    
                    mov cx, 14
                    $$all_video_record: mov di, 16
                                        $$string_video_record:  mov ax, es:[si]
                                                                mov old_screen_buffer + bx, ax
                                                                xor ax, ax
                                                                add bx, 2
                                                                add si, 2

                                                                dec di
                                                                cmp di, 0
                                                                jne $$string_video_record
                                        add  si, 128
                                        loop $$all_video_record
                    
                    ret
old_video_to_buffer endp
;=========================================== 


;===========================================
; PRINTF VIDEO BUFFER 
;===========================================
; Entry:    BX = pointer to buffer
; Exit:      
; Expects:   
; Destroys:  
;=========================================== 
printf_video_buffer proc
                    push si cx di 

                    push bx
                    mov bx, 0b800h
                    mov es, bx
                    pop bx

                    mov si, 0
                    mov cx, 14
                    $$all_printf_video: mov di, 16
                                        $$string_printf_video:  push bx
                                                                mov  bx,[bx]
                                                                mov  es:[si], bx
                                                                pop  bx
                                                                
                                                                add  bx, 2
                                                                add  si, 2

                                                                dec  di
                                                                cmp  di, 0
                                                                jne $$string_printf_video
                                        add si, 128
                                        loop $$all_printf_video
                    pop di cx si
                    ret
printf_video_buffer endp
;=========================================== 