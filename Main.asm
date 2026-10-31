; Notas: se usa 'dh' como auxiliar de anti-repeticion y se usa 'cl' para dar la tecla detectada sin repeticion y luego dl para estado del loop principal del juego, entonces, use push y pop con esos!

; nota para Andy: se usa IA para revisar errores y para buscar funciones y informacion sobre como se usa, principalmente gemini y copilot.

;------------------------------------------------------------------------------------------------------------------------------------
;Macros
;------------------------------------------------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------------------------------------------------
; teclazo -  Funciona perfectamente, no lo toque!
;------------------------------------------------------------------------------------------------------------------------------------
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

bichito macro n
    mov ah, 02h
    mov dl, bichos[n]
    add dl, '0'
    int 21h
    mov ah, 02h
    mov dl, ','
    int 21h
ret
endm
;------------------------------------------------------------------------------------------------------------------------------------
;iniciliza programa
;------------------------------------------------------------------------------------------------------------------------------------
.model small
.stack 100h
;------------------------------------------------------------------------------------------------------------------------------------
; variabbles
;------------------------------------------------------------------------------------------------------------------------------------
.data
    estado db 0
    posy   db 0 ; new
    posx   db 0 ; new
    modoy  db 0 ; lim
    modox  db 0 ; lim
    sely   db 0 ; old
    selx   db 0 ; old
    dificultad db 0
    bichos db 1, 1, 1, 1, 1
    dif    db 0 
;------------------------------------------------------------------------------------------------------------------------------------
; codigo
;------------------------------------------------------------------------------------------------------------------------------------
.code
    main proc
        mov ax, @data
        mov ds, ax
        mov dl, estado
        xor dh,dh
;------------------------------------------------------------------------------------------------------------------------------------
; loop a base de estados, segun el estado en el registro 'dl' llama un procedimiento para una pantalla en especifico
;------------------------------------------------------------------------------------------------------------------------------------
    inicio:
        cmp dl, 0 ; inicio
        jne sig0
            call proceso0
            jmp inicio
        sig0:
        cmp dl, 1 ; menu
        jne sig1
            call proceso1
            jmp inicio
        sig1:
        cmp dl, 2 ; instrucciones
        jne sig2
            call proceso2
            jmp inicio
        sig2:
        cmp dl, 3 ; juego
        jne sig3
            call proceso3
            jmp inicio
        sig3:
        cmp dl, 4 ; victoria
        jne sig4
            call proceso4
            jmp inicio
        sig4:
        cmp dl, 5 ; derrota
        jne sig5
            call proceso5
            jmp inicio
        sig5:
        cmp dl, 6 ; post juego
        jne sig6
            call proceso6
            jmp inicio
        sig6:
        cmp dl, 7  ; creditos
        jne sig7
            call proceso7
            jmp inicio
        sig7:
        cmp dl, 8 ; dificultad
        jne sig8
            call proceso8
            jmp inicio
        sig8:
            
        mov dl, 'X'
        mov ah, 02h
        int 21h

        mov ah, 0fh ; salida controlada segun requerimiento del proyecto
        int 10h
        mov ah, 4ch
        int 21h

;------------------------------------------------------------------------------------------------------------------------------------
; Area de procedimientos
;------------------------------------------------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------------------------------------------------
; control ws
;------------------------------------------------------------------------------------------------------------------------------------
; revisa 'cl' para las teclas ws y modifica la variable posy que se usa para seleccion y dibujado, su tamaño controlado por modoy
        ws proc near
            push cx
            mov ch, modoy
            cmp cl, 1 ; arriba w
            jne finw
                cmp posy, ch
                jne novueltaw
                    mov posy, 1
                    call prueba2 ; ////////////////////////////////////////////////////////////////////// eliminar
                    jmp fins
                novueltaw:
                je vueltaw
                    add posy, 1
                    call prueba2 ; ////////////////////////////////////////////////////////////////////// eliminar
                    jmp fins
                vueltaw:
            finw:
            cmp cl, 2 ; abajo s
            jne fins
                cmp posy, 1
                jne novueltas
                    mov posy, ch
                    call prueba2 ; ////////////////////////////////////////////////////////////////////// eliminar
                    jmp fins
                novueltas:
                je vueltas
                    sub posy, 1
                    call prueba2 ; ////////////////////////////////////////////////////////////////////// eliminar
                    jmp fins
                vueltas:
            fins:
            pop cx
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; control ad
;------------------------------------------------------------------------------------------------------------------------------------
; revisa 'cl' para las teclas ad y modifica la variable posy que se usa para seleccion y dibujado, su tamaño controlado por modox
        ad proc near
            push cx
            mov ch, modox
            cmp cl, 3 ; arriba a
            jne fina
                cmp posx, ch
                jne novueltaa
                    mov posx, 0
                    call prueba2 ; ////////////////////////////////////////////////////////////////////// eliminar
                novueltaa:
                je vueltaa
                    add posx, 1
                    call prueba2 ; ////////////////////////////////////////////////////////////////////// eliminar
                vueltaa:
            fina:
            cmp cl, 4 ; abajo d
            jne find
                cmp posx, 0
                jne novueltad
                    mov posx, ch
                    call prueba2 ; ////////////////////////////////////////////////////////////////////// eliminar
                novueltad:
                je vueltad
                    sub posx, 1
                    call prueba2 ; ////////////////////////////////////////////////////////////////////// eliminar
                vueltad:
            find:
            pop cx
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; selector de menu
;------------------------------------------------------------------------------------------------------------------------------------
; esto convierte las posiciones en variable posy a selecciones para diferentes pantallas en el menu
        selector_menu proc near
            cmp posy, 5
            jne nose5
                mov sely, 8 ; jugar -  manda a selector de dificultad
                ; aqui se agrega instruccion de dibujo*************************************************************************************************
                jmp salselmenu
            nose5:
            cmp posy, 4
            jne nose4
                mov sely, 1 ; nivel de dificultad (no implementado aun)
                ; aqui se agrega instruccion de dibujo*************************************************************************************************
                jmp salselmenu
            nose4:
            cmp posy, 3
            jne nose3
                mov sely, 2 ; instrucciones
                ; aqui se agrega instruccion de dibujo*************************************************************************************************
                jmp salselmenu
            nose3:
            cmp posy, 2
            jne nose2
                mov sely, 7 ; creditos
                ; aqui se agrega instruccion de dibujo*************************************************************************************************
                jmp salselmenu
            nose2:
            cmp posy, 1
            jne nose1
                mov sely, 10 ; salir
                ; aqui se agrega instruccion de dibujo*************************************************************************************************
                jmp salselmenu
            nose1:
            salselmenu:
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; selector de dificultad
;------------------------------------------------------------------------------------------------------------------------------------
; asume teclazo seguido por ws, convierte posy a instrucciones para el juego en dif
        selector_dificultad proc near
            ; aqui se agrega instruccion de dibujo*************************************************************************************************
            cmp posy, 3
            jne nodef3
                mov dif, 0 ; facil
                ; aqui se agrega instruccion de dibujo*************************************************************************************************
                jmp salseldif
            nodef3:
            cmp posy, 2
            jne nodef2
                mov dif, 1 ; normal
                ; aqui se agrega instruccion de dibujo*************************************************************************************************
                jmp salseldif
            nodef2:
            cmp posy, 1
            jne nodef1
                mov dif, 2 ; dificil
                ; aqui se agrega instruccion de dibujo*************************************************************************************************
            nodef1:
            salseldif:
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; seleccion de juego
;------------------------------------------------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------------------------------------------------
;actualizarjuegoxy
;------------------------------------------------------------------------------------------------------------------------------------
        actualizarjuegoxy proc near
            call ad ; revisa teclado y actualiza posx
            call ws ; revisa teclado y actualiza posy
            push bx
            push cx
            mov ch, posx ; teclado actual
            mov cl, posy ; teclado actual
            mov bh, 0 ; aparentemente hay que limpiar la parte alta para direccionamiento (me di cuenta gracias al IA)
            mov bl, posx ; luegoo se agrega al bajo se le agrega el indice (me di cuenta gracias al IA)
            cmp ch, selx ; revisa si cambio de posicion x
            je nocambiox
                 ; aqui se agrega instruccion de dibujo*************************************************************************************************
                 ; aqui se agrega instruccion de dibujo*************************************************************************************************
                 mov selx, ch
            nocambiox:
            
            cmp cl, bichos[bx] ; revisa si cambio de posicion (me di cuenta que hay que usar bx para esto gracias al IA)
            je nocambioy
                 ; aqui se agrega instruccion de dibujo*************************************************************************************************
                 ; aqui se agrega instruccion de dibujo*************************************************************************************************
                mov bichos[bx], cl
            nocambioy:
            
            
            
            pop cx
            pop bx
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
;setjuego
;------------------------------------------------------------------------------------------------------------------------------------
        setjuego proc near
            call resetbichos
            cmp dif, 0 ; facil
            jne dif0
                mov modox,3
                mov modoy,6
                mov posx, 0
                mov posy, 1
                mov selx, 0
                mov sely, 1
            dif0:
            cmp dif, 1 ; normal
            jne dif1
                mov modox,3
                mov modoy,6
                mov posx, 0
                mov posy, 1
                mov selx, 0
                mov sely, 1
            dif1:
            cmp dif, 2 ; dificil
            jne dif2
                mov modox,4
                mov modoy,8
                mov posx, 0
                mov posy, 1
                mov selx, 0
                mov sely, 1
            dif2:
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
;compararjuego
;------------------------------------------------------------------------------------------------------------------------------------
        compararjuego proc near
        
        
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
;ejecutar
;------------------------------------------------------------------------------------------------------------------------------------
        ejecutar proc near
        
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
;resetear bichos
;------------------------------------------------------------------------------------------------------------------------------------
; bara bing, bara bum! se resetea los bichos facilin facilon! (no me complico)
        resetbichos proc near
            cmp dif, 2
            jne noduro
                mov bichos[0], 1
                mov bichos[1], 1
                mov bichos[2], 1
                mov bichos[3], 1
                mov bichos[4], 1
            noduro:
            je nofacil
                mov bichos[0], 1
                mov bichos[1], 1
                mov bichos[2], 1
                mov bichos[3], 1
                mov bichos[4], 0
            nofacil:
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; ; procedimiento para pantalla de presentacion | en teoria listo
;------------------------------------------------------------------------------------------------------------------------------------
; ciclo para pantalla de intro
        proceso0 proc near          

            inicio0:
                ; aqui se agrega instruccion de dibujo*************************************************************************************************
                teclazo
                cmp cl, 5 ; detecta enter
                jne nomenu0
                    mov dl, 1 ; ir menu
                    call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
                    jmp salida0
                nomenu0:
                cmp cl, 6 ; detecta esc
                jne nosalir0
                    mov dl, 10 ; ir salida
                    call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
                    jmp salida0
                nosalir0:
                salida0:
                mov cl, 0
            cmp dl, 0
            je inicio0
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; procedimiento para pantalla de menu | en teoria listo
;------------------------------------------------------------------------------------------------------------------------------------
;   este proc es para el menu, ciclicamente revisa el teclado: pantalla de inicio con esc, entra a otro proc con enter segun pos vertical seleccionada por proc ws
        proceso1 proc
            mov modoy, 5 ; 5 modos de menu
            mov sely, 5 ; inicializa posicion 5
            mov posy,5
            ; aqui se agrega instruccion de dibujo*************************************************************************************************
            inicio1:
                teclazo
                cmp cl, 5 ; detecta enter
                jne noenter1
                    mov dl, sely ; ir seleccionado
                    call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
                    jmp salida1
                noenter1:
                cmp cl, 6 ; detecta esc
                jne nosalir1
                    mov dl, 0 ; ir presentacion
                    call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
                    jmp salida1
                nosalir1:
                call ws
                call selector_menu
                salida1:
                mov cl, 0 ; muy importante
            cmp dl, 1
            je inicio1

        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; procedimiento para pantalla de instrucciones de juego | en teoria listo
;------------------------------------------------------------------------------------------------------------------------------------
;este proc solo dibuja las instrucciones del juego, de aqui solo se puede activar la tecla "esc"
        proceso2 proc near          
            ; aqui se agrega instruccion de dibujo*************************************************************************************************
        inicio2:
            teclazo
            cmp cl, 6 ; detecta esc
            jne nosalir2
                mov dl, 1 ; ir menu
                call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
            nosalir2:
            cmp cl, 5; detecta enter
            jne noenter2
                mov dl, 1 ; ir menu
                call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
            noenter2:
        cmp dl, 2
        je inicio2
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; procedimiento para pantalla de juego | por implementar
;------------------------------------------------------------------------------------------------------------------------------------
; recibe modx y mody de la ventana de seleccion de dificultad para ajustes del juego
        proceso3 proc near
            call setjuego
            inicio3:
                teclazo
                cmp cl, 6 ; detecta esc
                jne noesc3
                    mov dl, 1 ; ir menu
                    call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
                noesc3:
                cmp cl, 5; detecta enter
                jne noenter3
                    ;call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
                    call pruebabichos
                    ;call compararjuego
                    ;call ejecutar
                    ; aqui se agrega instruccion de juego*************************************************************************************************
                noenter3:

                call actualizarjuegoxy

                mov cl, 0 ; muy importante
            cmp dl, 3
            je inicio3
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; procedimiento para pantalla de pantalla de victoria | en teoria listo
;------------------------------------------------------------------------------------------------------------------------------------
; solo presenta pantalla de victoria hasta que se toque esc o enter
        proceso4 proc
            ; aqui se agrega instruccion de dibujo*************************************************************************************************
            inicio4:
                teclazo
                cmp cl, 6 ; detecta esc
                jne noesc4
                    mov dl, 1 ; ir menu
                    call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
                noesc4:
                cmp cl, 5; detecta enter
                jne noenter4
                    mov dl, 6 ; ir post juego
                    call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
                noenter4:
            cmp dl, 4
            je inicio4
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; procedimiento para pantalla de pantalla de derrota | en teoria listo
;------------------------------------------------------------------------------------------------------------------------------------
; solo presenta pantalla de derrota hasta que se toque esc o enter
        proceso5 proc near
            ; aqui se agrega instruccion de dibujo*************************************************************************************************
            inicio5:
                teclazo
                cmp cl, 6 ; detecta esc
                jne noesc5
                    mov dl, 1 ; ir menu
                    call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
                noesc5:
                cmp cl, 5; detecta enter
                jne noenter5
                    mov dl, 6 ; ir post juego
                    call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
                noenter5:
            cmp dl, 5
            je inicio5
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; procedimiento para pantalla de post juego | en teoria listo
;------------------------------------------------------------------------------------------------------------------------------------
        proceso6 proc near
            ; aqui se agrega instruccion de dibujo*************************************************************************************************
            inicio6:
                teclazo
                cmp cl, 6 ; detecta esc
                jne noesc6
                    mov dl, 1 ; ir menu
                    call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
                noesc6:
                cmp cl, 5; detecta enter
                jne noenter6
                    mov dl, 3 ; ir juego
                    call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
                noenter6:
            cmp dl, 6
            je inicio6
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; pantalla de creditos | en teoria listo
;------------------------------------------------------------------------------------------------------------------------------------
        proceso7 proc near
            ; aqui se agrega instruccion de dibujo*************************************************************************************************
            inicio7:
                teclazo
                cmp cl, 6 ; detecta esc
                jne noesc7
                    mov dl, 1 ; ir menu
                    call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
                noesc7:
                cmp cl, 5; detecta enter
                jne noenter7
                    mov dl, 1 ; ir menu
                    call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
                noenter7:
            cmp dl, 7
            je inicio7
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; nivel de dificultad | en teoria listo
;------------------------------------------------------------------------------------------------------------------------------------
        proceso8 proc near
            ; aqui se agrega instruccion de dibujo*************************************************************************************************
            mov modoy, 3
            mov sely, 3
            mov posy, 3
            call prueba2 ; ////////////////////////////////////////////////////////////////////// eliminar
            inicio8:
                teclazo
                cmp cl, 6 ; detecta esc
                jne noesc8
                    mov dl, 1 ; ir menu
                    call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
                    jmp salir8
                noesc8:
                cmp cl, 5; detecta enter
                jne noenter8
                    mov dl, 3 ; ir juego
                    call prueba ; ////////////////////////////////////////////////////////////////////// eliminar
                    jmp salir8
                noenter8:
                    
                call ws
                call selector_dificultad

                salir8:
                mov cl, 0 ; muy importante
            cmp dl, 8
            je inicio8
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; esto es solo para probar logica de control
;------------------------------------------------------------------------------------------------------------------------------------
        prueba proc near
            push ax
            push cx
            push dx
            add dl, '0'
            mov ah, 02h
            int 21h
            pop dx
            pop cx
            pop ax
        ret
        endp
;------------------------------------------------------------------------------------------------------------------------------------
; esto es solo para probar logica de menu
;------------------------------------------------------------------------------------------------------------------------------------
        prueba2 proc near
            push ax
            push cx
            push dx
            mov dl, 'y'
            mov ah, 02h
            int 21h
            mov dl, posy
            add dl, '0'
            mov ah, 02h
            int 21h
            pop dx
            pop cx
            pop ax
        ret
        endp

;------------------------------------------------------------------------------------------------------------------------------------
; esto es solo para probar logica de menu
;------------------------------------------------------------------------------------------------------------------------------------
; lo hice asi porque era copy y paste, y no hay problema con memoria o tamaño del codigo
        pruebabichos proc
            push ax
            push dx
            mov ah, 02h
            mov dl, 13
            int 21h

            bichito 0
            bichito 1
            bichito 2
            bichito 3
            bichito 4

            mov ah, 02h
            mov dl, 13
            int 21h
            pop dx
            pop ax

        endp
;------------------------------------------------------------------------------------------------------------------------------------
;final
;------------------------------------------------------------------------------------------------------------------------------------
    main endp
    end main
;------------------------------------------------------------------------------------------------------------------------------------