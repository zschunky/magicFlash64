
.data
.export tickPtr
tickPtr:
  .byte 0,0

.code

.export tick
tick:
  lda tickPtr
  bne :+
  lda tickPtr+1
  bne :+

  rts

:
  jmp (tickPtr)

