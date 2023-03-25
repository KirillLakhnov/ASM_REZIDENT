.286
.model tiny
.code
locals $$
org 100h

;===========================================
; Exit Programm
;===========================================
; Entry:     None
; Exit:      None
; Expects:   None
; Destroys:  AX, DX
;===========================================
EXIT macro
  
     mov ax, 3100h
     mov dx, offset EOP
     shr dx, 4
     inc dx
     int 21h
                
     endm
;===========================================

;===========================================
; Print " = " to video memory
;===========================================
; Entry:     None
; Exit:      None
; Expects:   None
; Destroys:  AX
;===========================================
PRINT_EQUALS macro       
     
             mov registr_buffer + bx, 4e20h
             add bx, 2
          
             mov registr_buffer + bx, 4e3dh
             add bx, 2
              
             mov registr_buffer + bx, 4e20h
             add bx, 2
             
             endm
;===========================================


;===========================================
; Print " | " to video memory
;===========================================
; Entry:     None
; Exit:      None
; Expects:   None
; Destroys:  AX
;===========================================
PRINT_DECOR  macro    
     
             mov registr_buffer + bx, 4e20h
             add bx, 2
          
             mov registr_buffer + bx, 4eB3h
             add bx, 2
              
             mov registr_buffer + bx, 4e20h
             add bx, 2
             
             endm
;===========================================


Start: sti
       xor bx, bx
       mov es, bx
       mov bx, 4*8    
       mov ax, es:[bx]
       mov old08ofs, ax    
       mov es:[bx], offset new_08      
       mov ax, es:[bx + 2]
       mov old08seg, ax   
       mov ax, cs
       mov es:[bx + 2], ax
       cli
       
       cli
       xor bx, bx
       mov es, bx
       mov bx, 4*9
       mov ax, es:[bx]
       mov old09ofs, ax
       mov es:[bx], offset new_09
       mov ax, es:[bx + 2]
       mov old09seg, ax
       mov ax, cs
       mov es:[bx + 2], ax
       sti 
       
       next: in  al, 60h
             cmp al, 1
             jne next
       
       EXIT

;===========================================
; Print vertical line to "registr_buffer"
;===========================================
; Entry:     CX = wigth
; Exit:      None
; Expects:   None
; Destroys:  None
;===========================================
print_vline  proc      
             
             $$draw_line: mov registr_buffer + bx, 4eC4h
                          add bx, 2
             
                          loop $$draw_line            
             ret
print_vline  endp
;===========================================

;===========================================
; PRINT HEX VALUE IN "REGISTR_BUFFER"
;===========================================
; Entry:     AX = value
; Exit:      BX = BX + 10
; Expects:   ES = 0b800h
;            BX = coordinate start printing
; Destroys:  None
;=========================================== 
HEX_print proc
          push si cx
          
          mov si, 0Fh
             
          add bx, 6
          mov cx, 4
          
          $$print_value: push ax 
          
                         and ax, si
                         
                         cmp al, 09h
                         jle $$if_ax_jle_09h
                         jmp $$else_ax_jle_09h
                         
                         $$if_ax_jle_09h:     add al, 30h
                                              jmp $$end_if_ax_jle_09h
                                              
                         $$else_ax_jle_09h:   add ax, 37h
                                              jmp $$end_if_ax_jle_09h
                                              
                         $$end_if_ax_jle_09h:
                         
                         mov ah, 4eh
                         mov registr_buffer + bx, ax
                         sub bx, 2
                         
                         pop ax
                         shr ax, 4
                         loop $$print_value
          
		  add bx, 10
          mov registr_buffer + bx, 4e68h
          add bx, 2
          
          pop cx si
          
          ret
HEX_print endp
;===========================================

include tests.asm

;===========================================
; NEW 09
;===========================================
; Entry:     None
; Exit:      None
; Expects:   None
; Destroys:  None
;===========================================  
new_09             	proc
                   	push ax bx cx dx
                   	push si di
                   	push bp sp
                   	push ds es ss cs

                    $$view: in  al, 60h
                           	cmp al, 0dh ; al equaly scan code "+="
                           	je  $$print_value_registrs
                           	jmp $$sleep_view 
				
                    $$print_value_registrs: mov al, mode
											cmp al, 00h
											je  $$on_registrs
											cmp al, 01h
											je $$off_registrs
				   
				   	$$on_registrs:			mov mode, 01h
											call old_video_to_buffer 
											call registrs_to_buffer
                                           	lea bx, registr_buffer
										   	call printf_video_buffer
                                           	jmp  $$end_view

					$$off_registrs:        	mov mode, 00h
											lea bx, old_screen_buffer
											call printf_video_buffer
											jmp  $$end_view
                                           
                   	$$end_view:
                   
                   	in  al, 61h
                   	or  al, 80h
                   	out 61h, al
                   	and al, not 80h
                   	out 61h, al
      
                   	mov al, 20h
                   	out 20h, al
              
                   	add sp, 2
                   
                   	pop ss es ds
                   	pop sp bp
                   	pop di si
                   	pop dx cx bx ax
                   
                   	iret
       
$$sleep_view:      	add sp, 2

                   	pop ss es ds
                   	pop sp bp
                   	pop di si
                   	pop dx cx bx ax

                             db 0eah
                   	old09ofs dw 0
                   	old09seg dw 0

new_09           	endp
;=========================================== 


;===========================================
; NEW 08
;===========================================
; Entry:     None
; Exit:      None
; Expects:   None
; Destroys:  None
;===========================================  
new_08 				proc
					push ax bx cx dx
                   	push si di
                   	push bp sp
                   	push ds es ss 

					mov al, mode
					cmp al, 01h
					je  $$update_registrs
					jmp $$off_update

					pop ss es ds
                   	pop sp bp
                   	pop di si
                   	pop dx cx bx ax
                   
                   	iret
new_08 				endp
;===========================================ё
old09ofs dw 0
old09seg dw 0

registr_buffer    dw 224 dup (0)
old_screen_buffer dw 224 dup (0)

mode db 00h

EOP: end Start