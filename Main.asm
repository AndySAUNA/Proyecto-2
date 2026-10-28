; Notas: se usa 'dh' como auxiliar de anti-repeticion y se usa 'dl' para dar la tecla detectada sin repeticion, entonces, use push y pop con esos!

teclazo macro ; para manejar uso de teclas, solo cambia 'dl' si detecta cambio de tecla, usa 'dh' pra anti-repeticion
    local notecla, antirebote, noflecha, arriba, abajo, izquierda, derecha,noesc,noenter
    ; la busqueda para el uso de la instruccion de deteccion de teclas int 16h con 00h y informacion sobre su uso fue asistida por gemini, su implementacion a partir de ahi seria en cierta medida una implementacion propia, (cierta medida porque vi como se implemento en gemini, pero lo necesito diferente)
    ; para deteccion de teclas, se cambia 'dl', enter es 1, esc es 2, flechas: arriba 3, abajo 4, izquierda 5, derecha 6
    mov al, 00h 
    int 16h
    

    jz notecla
        cmp al, dh
        jne antirebote
            mov dh, al
            cmp ah, 00h
            jne noflecha

                cmp ah, 48h ;arriba
                jne arriba
                    mov dl, 3
                arriba:
                cmp ah, 48h ;abajo
                jne abajo
                    mov dl, 4
                abajo:
                cmp ah, 48h ;izquierda
                jne izquierda
                    mov dl, 5
                izquierda:
                cmp ah, 48h ;derecha
                jne derecha
                    mov dl, 6
                derecha:
            
            noflecha:

            cmp al, 0DH ;enter
            jne noenter
                mov dl, 1
            noenter:

            
            cmp al, 01h ;esc
            jne noesc
                mov dl, 2
            noesc:

        antirebote:
    notecla:
    
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
    
    inicio: ; aqui inicial el loop principal del programa
        cmp dl, 0 ; aqui ejecuta la pantalla de presencacion para estado 0
        jne sig0
            call proceso0
            jmp inicio
        sig0:
        cmp dl, 1 ; aqui ejecuta la pantalla del menu para el estado 1
        jne sig1
            call proceso1
            jmp inicio
        sig1:
        cmp dl, 2 ; aqui ejecuta la pantalla de instrucciones de juego para el estado 2
        jne sig2
            call proceso2
            jmp inicio
        sig2:
        cmp dl, 3 ; aqui ejecuta la pantalla de juego para el estado 3
        jne sig3
            call proceso3
            jmp inicio
        sig3:
        cmp dl, 4 ; aqui ejecuta la pantalla de victoria de juego para el estado 4
        jne sig4
            call proceso4
            jmp inicio
        sig4:
        cmp dl, 5 ; aqui ejecuta la pantalla de perder de juego para estado 5
        jne sig5
            call proceso5
            jmp inicio
        sig5:
        cmp dl, 6 ; aqui ejecuta la pantalla de post juego para estado 6
        jne sig6
            call proceso6
            jmp inicio
        sig6:
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
                ; aqui se agrega instruccion de dibujo
                teclazo 0DH, 1      ; revisa enter en el teclado y pasa al estado 1
                teclazo 01h, 10     ; revisa esc em el teclado y sale del programa
            cmp dl, 0               ; revisa que el estado sea igual al actual
            jne inicio0             ; si el estado no ha cambiado, reinicia el loop
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso1 proc               ; procedimiento para pantalla de menu

        inicio1:
            
            teclazo

        cmp dl, 1
        jne inicio1

        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso2 proc near          ; procedimiento para pantalla de instrucciones de juego

        inicio2:
            teclazo
        cmp dl, 2
        jne inicio2

        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso3 proc near          ; procedimiento para pantalla de juego
            
        inicio3:
            teclazo
        cmp dl, 3
        jne inicio3
 
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso4 proc ; procedimiento para pantalla de pantalla de victoria
                        
        inicio4:
            teclazo
        cmp dl, 4
        jne inicio4
 
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso5 proc near ; procedimiento para pantalla de pantalla de derrota
                        
        inicio5:
            teclazo
        cmp dl, 5
        jne inicio5
 
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso6 proc near ; procedimiento para pantalla de post juego
                        
        inicio6:
            teclazo
        cmp dl, 6
        jne inicio6
 
        ret
        endp

    main endp
    end main
