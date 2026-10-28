; Notas: se usa dh para guardar auxiliar de antirebote y se usa dl para guardar estado de juego, ademas se usa cl y ch para contar posicion de botones, entonces use push y pop con esos

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
; para manejar uso de teclas de control de estado, hace uso de ch para caracter a revisar, cl para estado a activar, dh para antirebote y dl para estado de sitema
        teclazo proc near
            mov al, 01h                     ; para leer el teclado
            int 16h

            jz notecla1                      ; salta si no hubo tecla
                cmp al, dh                  ; compara tecla con auxiliar para antirebote (dh)
                jne antirebote1              ; salta si hay rebote
                    cmp dh, ch       ; compara con la tecla "caracter"
                    jne nocaracter1          ; salta si no es caracter
                        mov dl, cl          ; si es caracter, cambia estado al nuevo (dl)
                        mov ah, 02h         ; para probar
                        int 21h
                    nocaracter1:             ; fin salto de no caracter
                antirebote1:                 ; fin salto antirebote
            notecla1:                        ; fin salto tecla vacia
            mov dh, al                      ; resetea el auxiliar de tecla con lo que se encuentra en el buffer del teclado
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; para manejar uso de flechas, exactamente igual al macro teclazo, solo que para flechas, hace uso de ch para caracter a revisar, cl para estado a activar, dh para antirebote y dl para estado de sitema
        teclazo2 proc near ; para manejar uso de flechas, exactamente igual al proc teclazo, solo que para flechas
            mov al, 01h                     ; para leer el teclado
            int 16h

            jz notecla2                      ; salta si no hubo tecla
                cmp al, dh                  ; compara tecla con auxiliar para antirebote (dh)
                jne antirebote2              ; salta si hay rebote
                    cmp dh, ch        ; compara con la tecla "caracter"
                    jne nocaracter2          ; salta si no es caracter
                        mov cl, ch          ; si es igual al contenido de ch, da cambio de posicion en cl
                        mov ah, 02h         ; para probar
                        int 21h
                    nocaracter2:             ; fin salto de no caracter
                antirebote2:                 ; fin salto antirebote
            notecla2:                        ; fin salto tecla vacia
            mov dh, al                      ; resetea el auxiliar de tecla con lo que se encuentra en el buffer del teclado
        endp
;------------------------------------------------------------------------------------------------------------------------------------

        proceso0 proc near          ; procedimiento para pantalla de presentacion
            
            inicio0:
                ; aqui se agrega instruccion de dibujo
                call teclazo      ; revisa enter en el teclado y pasa al estado 1
                call teclazo     ; revisa esc em el teclado y sale del programa
            cmp dl, 0               ; revisa que el estado sea igual al actual
            jne inicio0             ; si el estado no ha cambiado, reinicia el loop
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso1 proc               ; procedimiento para pantalla de menu

        inicio1:
            
            call teclazo2          ; revisa tecla arriba
            call teclazo2          ; revisa tecla abajo
            call teclazo2          ; revisa tecla izquierda
            call teclazo2          ; revisa tecla derecha
            
            call teclazo          ; revisa esc em el teclado y cambia estado a 0 para pantalla de presentacion
            call teclazo          ; revisa enter en el teclado y pasa al estado 1

        cmp dl, 1
        jne inicio1

        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso2 proc near          ; procedimiento para pantalla de instrucciones de juego

        inicio2:
            call teclazo           ; revisa enter
            call teclazo         ; revisa esc em el teclado y sale del programa
        cmp dl, 2
        jne inicio2

        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso3 proc near          ; procedimiento para pantalla de juego
            
        inicio3:
            call teclazo           ; revisa enter
            call teclazo          ; revisa esc em el teclado y sale al menu
        cmp dl, 3
        jne inicio3
 
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso4 proc ; procedimiento para pantalla de pantalla de victoria
                        
        inicio4:
            call teclazo
            call teclazo     ; revisa esc em el teclado y sale del programa
        cmp dl, 4
        jne inicio4
 
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso5 proc near ; procedimiento para pantalla de pantalla de derrota
                        
        inicio5:
            call teclazo
            call teclazo    ; revisa esc em el teclado y sale del programa
        cmp dl, 5
        jne inicio5
 
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
        proceso6 proc near ; procedimiento para pantalla de post juego
                        
        inicio6:
            call teclazo
            call teclazo     ; revisa esc em el teclado y sale del programa
        cmp dl, 6
        jne inicio6
 
        ret
        endp

    main endp
    end main
