asm :
	..\z_tools\nask.exe meiyouos.nas meiyouos.img

clear :
	-del meiyouos.img
	-del ..\z_tools\qemu\fdimage0.bin

run :
	..\z_tools\make.exe asm
	copy meiyouos.img ..\z_tools\qemu\fdimage0.bin
	..\z_tools\make.exe	-C ../z_tools/qemu