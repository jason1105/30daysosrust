TOOLPATH = ../z_tools/
MAKE     = $(TOOLPATH)make.exe -r
NASK     = $(TOOLPATH)nask.exe
EDIMG    = $(TOOLPATH)edimg.exe
IMGTOL   = $(TOOLPATH)imgtol.com
COPY     = copy
DEL      = del

# デフォルト動作

default :
	$(MAKE) img

# ファイル生成規則

ipl.bin : ipl.nas Makefile
	$(NASK) ipl.nas ipl.bin ipl.lst

meiyou.sys : meiyou.nas Makefile
	$(NASK) meiyou.nas meiyou.sys meiyou.lst

meiyou.img : ipl.bin meiyou.sys Makefile
	$(EDIMG)   imgin:../z_tools/fdimg0at.tek \
		wbinimg src:ipl.bin len:512 from:0 to:0 \
		copy from:meiyou.sys to:@: \
		imgout:meiyou.img

# コマンド

asm :
	$(MAKE) ipl.bin

img :
	$(MAKE) meiyou.img

run :
	$(MAKE) img
	$(COPY) meiyou.img ..\z_tools\qemu\fdimage0.bin
	$(MAKE) -C ../z_tools/qemu

install :
	$(MAKE) img
	$(IMGTOL) w a: meiyou.img

clean :
	-$(DEL) ipl.bin
	-$(DEL) ipl.lst
	-$(DEL) meiyou.img
	-$(DEL) meiyou.sys
	-$(DEL) meiyou.lst

src_only :
	$(MAKE) clean
	-$(DEL) meiyou.img
