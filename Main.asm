; Notas: se usa dh para guardar auxiliar de antirebote y se usa dl para guardar estado de juego, ademas se usa cl y ch para contar posicion de botones, y bl para posicion de seleccion vertical y bh para posicion horizontal entonces use push y pop con esos

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
; para manejar uso de teclas de control de estado, hace uso de 'ch' para caracter a revisar, 'cl' para estado a activar, 'dh' para antirebote y 'dl' para estado de sistema a activar
        teclazo proc near
            mov ah, 01h
            int 16h

            jnz notecla1
                cmp al, dh
                je antirebote1
                    cmp al, ch
                    jne nocaracter1
                        mov dl, cl

                        mov ah, 02h
                        push ax
                        add al, '0'
                        int 21h
                        pop ax

                    nocaracter1:
                antirebote1:
            notecla1:
            mov dh, al
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; para manejar uso de flechas, exactamente igual al macro teclazo, solo que para flechas, hace uso de 'ch' para caracter a revisar, 'cl' para movimiento a activar, 'dh' para antirebote y 'bl' para estado de seleccion
        teclazo2 proc near ; para manejar uso de flechas, exactamente igual al proc teclazo, solo que para flechas
            mov ah, 00h
            int 16h

            CMP AL, 00h

            jnz notecla2
                cmp al, dh
                je antirebote2
                    cmp al, ch
                    jne nocaracter2
                        mov bl, ch

                        mov ah, 02h
                        push ax
                        add al, '0'
                        int 21h
                        pop ax

                    nocaracter2:             ; fin salto de no caracter
                antirebote2:                 ; fin salto antirebote
            notecla2:                        ; fin salto tecla vacia
            mov dh, al                      ; resetea el auxiliar de tecla con lo que se encuentra en el buffer del teclado
        endp
;------------------------------------------------------------------------------------------------------------------------------------

        proceso0 proc near          ; procedimiento para pantalla de presentacion
            ; aqui va el dibujo###################################################################################################
            inicio0:
                ; aqui va el dibujo animado ###################################################################################################

                mov ch, 0Dh         ;tecla Enter
                mov cl, 1           ;menu
                call teclazo

                mov ch, 1Bh         ;tecla ESC
                mov cl, 10          ;salida
                call teclazo

            cmp dl, 0               ; revisa que el estado sea igual al actual
            jne inicio0             ; si el estado no ha cambiado, reinicia el loop
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso1 proc               ; procedimiento para pantalla de menu
            mov bl, 0
            inicio1:
                mov ch, 48h ;tecla arriba
                mov cl, 0   ;funcion
                call teclazo2
                mov ch, 50h ;tecla abajo
                mov cl, 1   ;funcion
                call teclazo2

                ; logica salvaje de seleccion de modos

                
                
                ; aqui va el dibujo###################################################################################################

                mov ch, 0Dh ;tecla Enter
                mov cl, bl  ;opcion de menu resaltada
                call teclazo          
                mov ch, 1Bh ;tecla ESC
                mov cl, 1   ;menu
                call teclazo                    ; revisa esc em el teclado y cambia estado a 0 para pantalla de presentacion

            cmp dl, 1
            je inicio1
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso2 proc near          ; procedimiento para pantalla de instrucciones de juego

        inicio2:
            call teclazo           ; revisa enter
            call teclazo         ; revisa esc em el teclado y sale del programa
        cmp dl, 2
        je inicio2

        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso3 proc near          ; procedimiento para pantalla de juego
            
        inicio3:

            mov ch, 48h ;tecla arriba
                mov cl, 1   ;funcion
                call teclazo2
                mov ch, 50h ;tecla abajo
                mov cl, 2   ;funcion
                call teclazo2
                mov ch, 4Bh ;tecla izquierda
                mov cl, 3   ;funcion
                call teclazo2
                mov ch, 4Dh ;tecla derecha
                mov cl, 4   ;funcion
                call teclazo2

            call teclazo           ; revisa enter
            call teclazo          ; revisa esc em el teclado y sale al menu
        cmp dl, 3
        je inicio3
 
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso4 proc ; procedimiento para pantalla de pantalla de victoria
                        
        inicio4:
            call teclazo
            call teclazo     ; revisa esc em el teclado y sale del programa
        cmp dl, 4
        je inicio4
 
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso5 proc near ; procedimiento para pantalla de pantalla de derrota
                        
        inicio5:
            call teclazo
            call teclazo    ; revisa esc em el teclado y sale del programa
        cmp dl, 5
        je inicio5
 
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso6 proc near ; procedimiento para pantalla de post juego
                        
        inicio6:
            call teclazo
            call teclazo     ; revisa esc em el teclado y sale del programa
        cmp dl, 6
        je inicio6
 
        ret
        endp

    main endp
    end main
