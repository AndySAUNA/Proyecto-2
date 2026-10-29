; Notas: se usa 'dh' como auxiliar de anti-repeticion y se usa 'cl' para dar la tecla detectada sin repeticion y luego dl para estado del loop principal del juego, entonces, use push y pop con esos!

; nota para Andy: se usa IA para revisar errores y para buscar funciones y informacion sobre como se usa, principalmente gemini y copilot.

teclazo macro ; para manejar uso de teclas, solo cambia 'dl' si detecta cambio de tecla, usa 'dh' pra anti-repeticion
    local notecla, antirep, noflecha, arriba, abajo, izquierda, derecha, noesc, noenter, fin
    ; la busqueda para el uso de la instruccion de deteccion de teclas int 16h con 01h y informacion sobre su uso fue asistida por gemini, su implementacion a partir de ahi seria en cierta medida una implementacion propia, (cierta medida porque vi como se implemento en gemini, pero lo necesito diferente)
    ; para deteccion de teclas, se cambia 'dl', flechas (wasd): arriba 1, abajo 2, izquierda 3, derecha 4 y teclas normales: enter es 5, esc es 6 
    mov ah, 01h 
    int 16h

    jz notecla
        mov ah, 00h ; resetear buffer del teclado (muy importante!)
        int 16h
        cmp al, dh
        je antirep
            mov dh, al

            cmp al, 77h ;arriba W
            jne arriba
                mov cl, 1
            arriba:
            cmp al, 73h ;abajo S
            jne abajo
                mov cl, 2
            abajo:
            cmp al, 61h ;izquierda A
            jne izquierda
                mov cl, 3
            izquierda:
            cmp al, 64h ;derecha D
            jne derecha
                mov cl, 4
            derecha:
            cmp al, 0DH ;enter
            jne noenter
                mov cl, 5
            noenter:
            cmp al, 1Bh ;esc
            jne noesc
                mov cl, 6
            noesc:

        antirep:
    jmp fin
    notecla: ; no se puede confiar en el buffer cuando no hay tecla aparentemente
    mov dh, 0
    fin:
    
    
endm

.model small
.stack 100h

.data
    estado db 0


.code
    main proc
        mov ax, @data
        mov ds, ax
        mov dl, estado
        xor dh,dh
    ; loop a base de estados, segun el estado llama un procedimiento para esa pantalla en especifico
    inicio:
        cmp dl, 0
        jne sig0
            call proceso0
            jmp inicio
        sig0:
        cmp dl, 1
        jne sig1
            call proceso1
            jmp inicio
        sig1:
        cmp dl, 2
        jne sig2
            call proceso2
            jmp inicio
        sig2:
        cmp dl, 3
        jne sig3
            call proceso3
            jmp inicio
        sig3:
        cmp dl, 4
        jne sig4
            call proceso4
            jmp inicio
        sig4:
        cmp dl, 5
        jne sig5
            call proceso5
            jmp inicio
        sig5:
        cmp dl, 6
        jne sig6
            call proceso6
            jmp inicio
        sig6:
        mov dl, 'X'
        mov ah, 02h
        int 21h
;------------------------------------------------------------------------------------------------------------------------------------
; salida controlada segun requerimiento del proyecto
        mov ah, 0fh 
        int 10h
        mov ah, 4ch
        int 21h
;------------------------------------------------------------------------------------------------------------------------------------
; area de procedimientos
;------------------------------------------------------------------------------------------------------------------------------------
        proceso0 proc near          ; procedimiento para pantalla de presentacion

            inicio0:
                ; aqui se agrega instruccion de dibujo*************************************************************************************************
                teclazo

                

                cmp cl, 5
                jne nomenu0
                    mov dl, 1
                    push ax
                push dx
                mov dl, '1'
                mov ah, 02h
                int 21h
                pop dx
                pop ax
                nomenu0:
                cmp cl, 6
                jne nosalir0
                    

                    mov dl, 10
                    
                nosalir0:
                mov cl, 0

            cmp dl, 0
            je inicio0
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso1 proc               ; procedimiento para pantalla de menu

        inicio1:
            
            teclazo

            cmp cl, 5; tecla enter,
            jne noenter
                mov dl, 2
                push ax
                push dx
                mov dl, '2'
                mov ah, 02h
                int 21h
                pop dx
                pop ax
            noenter:

            cmp cl, 6 ; tecla esc
            jne nosalir1
                mov dl, 0
                push ax
                push dx
                mov dl, '0'
                mov ah, 02h
                int 21h
                pop dx
                pop ax
            nosalir1:
                
            
            mov cl, 0

        cmp dl, 1
        je inicio1

        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso2 proc near          ; procedimiento para pantalla de instrucciones de juego

        inicio2:

            teclazo

        cmp dl, 2
        je inicio2

        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso3 proc near          ; procedimiento para pantalla de juego
            
        inicio3:

            teclazo

        cmp dl, 3
        je inicio3
 
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso4 proc ; procedimiento para pantalla de pantalla de victoria
                        
        inicio4:

            teclazo

        cmp dl, 4
        je inicio4
 
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso5 proc near ; procedimiento para pantalla de pantalla de derrota
                        
        inicio5:

            teclazo

        cmp dl, 5
        je inicio5
 
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso6 proc near ; procedimiento para pantalla de post juego
                        
        inicio6:

            teclazo

        cmp dl, 6
        je inicio6
 
        ret
        endp

    main endp
    end main
