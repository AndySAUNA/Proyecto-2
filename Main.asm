; Notas: se usa 'dh' como auxiliar de anti-repeticion y se usa 'cl' para dar la tecla detectada sin repeticion, se usa 'ch' para posicion de flecha vertical y luego dl para estado del loop principal del juego, entonces, use push y pop con esos!

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
    posy db 0
    posx db 0

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

                

                cmp cl, 5 ; enter
                jne nomenu0
                    mov dl, 1
                    push ax
                    push dx
                    mov dl, '1'
                    mov ah, 02h
                    int 21h
                    pop dx
                    pop ax
                    jmp salida0
                nomenu0:

                cmp cl, 6 ; esc
                jne nosalir0
                    mov dl, 10
                    jmp salida0
                nosalir0:

                salida0:
                mov cl, 0
                cmp dl, 0
            je inicio0
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; procedimiento para pantalla de menu
;------------------------------------------------------------------------------------------------------------------------------------
;   este proc es para el menu, ciclicamente revisa el teclado: pantalla de inicio con esc, entra a otro proc con enter segun pos vertical seleccionada
    proceso1 proc               

        inicio1:
            
            teclazo

            cmp cl, 5; enter
            jne noenter1
                mov dl, 2
                jmp salida1
            noenter1:
            cmp cl, 6 ; esc
            jne nosalir1
                mov dl, 0
                jmp salida1
            nosalir1:
            cmp cl, 1 ; arriba w
            jne now1
                cmp posy, 4
                jne vuelta_positiva1
                    mov posy, 0
                vuelta_positiva1:
                je no_vuelta
                    add posy, 1
                no_vuelta:
            now1:
            cmp cl, 2 ; abajo s
            jne nos1
                cmp posy, 1
                jne vuelta_negativa1
                    mov posy,4
                vuelta_negativa1:

            
            nos1:


                
            salida1:
            mov cl, 0
        cmp dl, 1
        je inicio1

        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; procedimiento para pantalla de instrucciones de juego
;------------------------------------------------------------------------------------------------------------------------------------
;este proc solo dibuja las instrucciones del juego, de aqui solo se puede activar la tecla "esc"
        proceso2 proc near          
            ; aqui se agrega instruccion de dibujo*************************************************************************************************
        inicio2:
            teclazo
            cmp cl, 6 ; esc
            jne nosalir2
                mov dl, 1
            nosalir2:
        cmp dl, 2
        je inicio2
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; procedimiento para pantalla de juego
;------------------------------------------------------------------------------------------------------------------------------------
        proceso3 proc near          
            inicio3:
                teclazo
                cmp cl, 6 ; esc
                jne noesc3
                    mov dl, 1
                noesc3:
                cmp cl, 5; enter
                jne noenter3
                    mov dl, 1
                noenter3:
            cmp dl, 3
            je inicio3
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; procedimiento para pantalla de pantalla de victoria
;------------------------------------------------------------------------------------------------------------------------------------
; solo presenta pantalla de victoria hasta que se toque esc o enter
        proceso4 proc   
            inicio4:
                teclazo
                cmp cl, 6 ; esc
                jne noesc4
                    mov dl, 1 ; menu
                noesc4:
                cmp cl, 5; enter
                jne noenter4
                    mov dl, 6 ; post juego
                noenter4:
            cmp dl, 4
            je inicio4
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; procedimiento para pantalla de pantalla de derrota
;------------------------------------------------------------------------------------------------------------------------------------
; solo presenta pantalla de derrota hasta que se toque esc o enter
        proceso5 proc near
            inicio5:
                teclazo
                cmp cl, 6 ; esc
                jne noesc5
                    mov dl, 1 ; menu
                noesc5:
                cmp cl, 5; enter
                jne noenter5
                    mov dl, 6 ; post juego
                noenter5:
            cmp dl, 5
            je inicio5
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; procedimiento para pantalla de post juego
;------------------------------------------------------------------------------------------------------------------------------------
        proceso6 proc near
            inicio6:
                teclazo
                cmp cl, 6 ; esc
                jne noesc6
                    mov dl, 1 ; menu
                noesc6:
                cmp cl, 5; enter
                jne noenter6
                    mov dl, 3 ; juego
                noenter6:
            cmp dl, 6
            je inicio6
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
;final
;------------------------------------------------------------------------------------------------------------------------------------
    main endp
    end main
