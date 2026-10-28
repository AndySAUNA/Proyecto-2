; Notas: se usa dh para guardar auxiliar de antirebote y se usa dl para guardar estado de juego, ademas se usa cl y ch para contar posicion de botones, entonces use push y pop con esos

teclazo macro caracter, estado ; para manejar uso de teclas 
    local notecla, antirebote, nocaracter
    mov al, 01h ; para leer el teclado
    int 16h

    jz notecla                  ; salta si no hubo tecla
        cmp al, dh              ; compara tecla con auxiliar para antirebote (dh)
        jne antirebote          ; salta si hay rebote
            cmp dh, caracter    ; compara con la tecla "caracter"
            jne nocaracter      ; salta si no es caracter
                mov dl, estado  ; si es caracter, cambia estado al nuevo (dl)
            nocaracter:         ; fin salto de no caracter
        antirebote:             ; fin salto antirebote
    notecla:                    ; fin salto tecla vacia
    mov dh, al                  ; resetea el auxiliar de tecla con lo que se encuentra en el buffer del teclado
endm
teclazo2 macro caracter, pos ; para manejar uso de flechas, exactamente igual al macro teclazo, solo que para flechas
    local notecla, antirebote, nocaracter
    mov al, 01h ; para leer el teclado
    int 16h

    jz notecla                  ; salta si no hubo tecla
        cmp al, dh              ; compara tecla con auxiliar para antirebote (dh)
        jne antirebote          ; salta si hay rebote
            cmp dh, caracter    ; compara con la tecla "caracter"
            jne nocaracter      ; salta si no es caracter
                mov cl, estado  ; si es caracter, da cambio de posicion (cl)
            nocaracter:         ; fin salto de no caracter
        antirebote:             ; fin salto antirebote
    notecla:                    ; fin salto tecla vacia
    mov dh, al                  ; resetea el auxiliar de tecla con lo que se encuentra en el buffer del teclado
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
            
            teclazo2 48H,1          ; revisa tecla arriba
            teclazo2 50H,1          ; revisa tecla abajo
            teclazo2 4BH,1          ; revisa tecla izquierda
            teclazo2 4DH,1          ; revisa tecla derecha
            
            teclazo 01h, 0          ; revisa esc em el teclado y cambia estado a 0 para pantalla de presentacion
            teclazo 0DH, 1          ; revisa enter en el teclado y pasa al estado 1

        cmp dl, 1
        jne inicio1

        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso2 proc near          ; procedimiento para pantalla de instrucciones de juego

        inicio2:
            teclazo 0DH,1           ; revisa enter
            teclazo 01h, 10         ; revisa esc em el teclado y sale del programa
        cmp dl, 2
        jne inicio2

        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso3 proc near          ; procedimiento para pantalla de juego
            
        inicio3:
            teclazo 0DH,1           ; revisa enter
            teclazo 01h, 1          ; revisa esc em el teclado y sale al menu
        cmp dl, 3
        jne inicio3
 
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso4 proc ; procedimiento para pantalla de pantalla de victoria
                        
        inicio4:
            teclazo 0DH,1
            teclazo 01h, 10     ; revisa esc em el teclado y sale del programa
        cmp dl, 4
        jne inicio4
 
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso5 proc near ; procedimiento para pantalla de pantalla de derrota
                        
        inicio5:
            teclazo 0DH,1
            teclazo 01h, 10     ; revisa esc em el teclado y sale del programa
        cmp dl, 5
        jne inicio5
 
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso6 proc near ; procedimiento para pantalla de post juego
                        
        inicio6:
            teclazo 0DH,1
            teclazo 01h, 10     ; revisa esc em el teclado y sale del programa
        cmp dl, 6
        jne inicio6
 
        ret
        endp

    main endp
    end main
