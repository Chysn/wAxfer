; wAxfer Plug-In
; '
; Start the wAxfer IRQ process and start listening for data on
; the serial port. When data is received, add it to the keyboard
; buffer.
; 
; Press STOP/RESTORE to stop wAxfer

; VIA Registers
DDR         = $9112             ; Data Direction Register
UPORT       = $9110             ; User Port
PCR         = $911c             ; Peripheral Control Register
IFR         = $911d             ; Interrupt flag register

; Interrupt
IRQ         = $0314             ; IRQ vector
RFI         = $eb18             ; PLA, TAY ... RTI

; Keyboard buffer
KEYBUFF     = $0277             ; Keyboard buffer and size, for automatically
KBSIZE      = $c6               ;   advancing the assembly address

; Vector
READY       = $c002             ; BASIC warm start with READY.

; wAxfer Storage
PREVISR     = $024d             ; Previous ISR (from $0314/$0315)

* = $7500

Install:    lda #0              ; Set DDR to listen to all 8 data lines,
            sta DDR             ; ,,
            sta PCR             ; And set peripheral control to interrupt input
            sei                 ; Preserve the previous interrupt in plug-in
            lda IRQ             ;   storage
            sta PREVISR         ;   ,,
            lda IRQ+1           ;   ,,
            sta PREVISR+1       ;   ,,
            lda #<ISR           ; Install the new service routine, which will
            sta IRQ             ;   listen for data on the User Port
            lda #>ISR           ;   ,,
            sta IRQ+1           ;   ,,
            cli
            jmp (READY)

ISR:        lda #%00001000      ; Check the interrupt flag bit 3
            bit IFR             ; If it's set, User Port data is available
            bne recv            ; ,,
            jmp (PREVISR)       ; Otherwise, it's a normal old IRQ
recv:       lda UPORT           ; Get the User Port byte
            cmp #127            ; Convert terminal delete to VIC delete
            bne add_char        ; ,,
            lda #20             ; ,,
add_char:   ldy KBSIZE          ; Add the character received to the keyboard
            sta KEYBUFF,y       ;   buffer
            inc KBSIZE          ; Increment the buffer size
ser_r:      jmp RFI             ; Return from the User Port interrupt
