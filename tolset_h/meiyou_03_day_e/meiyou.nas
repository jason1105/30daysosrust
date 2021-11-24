    ORG 0xc200
    MOV AL,0x13     ;vedio mode, 320 * 200 * 8. 
    MOV AH,0x00
    int 0x10
fin:
    HLT
    JMP fin