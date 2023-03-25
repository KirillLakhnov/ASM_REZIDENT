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


Start: 	sti
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

		;mov cx, offset registr_buffer
		;mov cx, offset old_screen_buffer
		;mov cx, offset mode

		;mov cl, 0dh
		;int 9h
		;int 8h
		;mov cl, 21h
		;int 9h
		;int 8h

       	mov ah, 09h
	    mov dx, offset rezident_active
	    int 21h
       
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
					push es ds
                   	push ax	

                    $$view: 		;mov al, cl
									in  al, 60h
                           			cmp al, 0dh 		; al equaly scan code "+="
                           			je  $$pressed		;
                           			jmp $$sleep_view 	;
				
                    $$pressed: 		mov al, cs:[mode]	 
									cmp al, 00h				 
									je  $$on_view			 
									cmp al, 01h				 
									je  $$off_view			 
															 
				   	$$on_view:		mov cs:[mode],      01h	;-->; if  (mode == 0) then (mode = 1)
									mov cs:[sleep_prg], 01h ;-->; and (sleep_prg = 1)
									mov cs:[flaunch],   01h ;-->; and (flaunch   = 1)  
                                    jmp $$end_view			 
															 
					$$off_view:		mov cs:[mode],   00h ;-->; if (mode == 1) then (mode = 0)
									mov cs:[launch], 00h ;-->; and (launch = 0)  
									jmp $$end_view		 
	
                   	$$end_view:
                   
                   	in  al, 61h
                   	or  al, 80h
                   	out 61h, al
                   	and al, not 80h
                   	out 61h, al
      
                   	mov al, 20h
                   	out 20h, al
                   
                   	pop ax
                    pop ds es
                   	iret
       
$$sleep_view:      	pop ax
					pop ds es

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
new_08 			proc 
				pushf     ; push flags
				db 09ah   ; call far
       old08ofs dw 0
       old08seg dw 0

	   			push ax bx cx dx
                push si di
                push bp sp
                push ds es ss cs

				mov al, cs:[mode]
				cmp al, 01h
				je  $$update_registers
				jmp $$sleep_update

				;==============================================
				$$update_registers:	mov al, cs:[launch]
									cmp al, 00h 
									je  $$save_old_video
									jmp $$draw_registers
									 
				$$draw_registers:	lea  bx, cs:[registr_buffer]
									lea  di, cs:[old_screen_buffer]
									call cmp_buffer
									call registrs_to_buffer
                                    lea  bx, cs:[registr_buffer]
									call printf_video_buffer
									jmp  $$end_time

				$$save_old_video:   mov ah, 09h
	    							mov dx, offset cs:[help1]
	    							int 21h
									lea bx, cs:[old_screen_buffer]
									call old_video_to_buffer
									mov  cs:[launch], 01h
									jmp  $$draw_registers
				;==============================================
				$$sleep_update: 	mov al, cs:[flaunch]
									cmp al, 00h
									je  $$end_time

									mov al, cs:[sleep_prg]
									cmp al, 00h
									jne $$draw_old_video
									jmp $$end_time

				$$draw_old_video:	mov  cs:[sleep_prg], 00h        ;-->; if (sleep_prg == 0) then (sleep_prg = 1)
									lea  bx, cs:[old_screen_buffer] 
									call printf_video_buffer
									jmp  $$end_time
				;==============================================
				$$end_time: 

				add sp, 2

				pop ss es ds
                pop sp bp
                pop di si
                pop dx cx bx ax
                   
                iret
new_08 			endp
;===========================================
registr_buffer    dw 225 dup (0)
old_screen_buffer dw 225 dup (0)

mode   		db 00h ; mode      == 0 --> draw registers off (pressed) 		; mode      == 1 --> draw registers on (pressed)         ;
flaunch 	db 00h ; flaunch   == 0 --> there was no first launch    		; flaunch   == 1 --> there was first launch              ; 
launch      db 00h ; launch    == 0 --> draw registers off                  ; launch    == 1 --> draw registers on					 ;
sleep_prg	db 00h ; sleep_prg == 0 --> drawing in video memory is disabled ; sleep_prg == 1 --> draw registers was on 				 ;


rezident_active db 29 dup (20h), 0C9h, 0CDh,     18 dup (0CDh),    0CDh, 0BBh, 0dh, 0ah
             	db 29 dup (20h), 0BAh, 020h, "Resident activated", 020h, 0BAh, 0dh, 0ah
	     		db 29 dup (20h), 0C8h, 0CDh,     18 dup (0CDh),    0CDh, 0BCh, '$'

EOP: end Start