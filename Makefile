GPPPARAMS = -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore
ASPARAMS = --32
LDPARAMS = -melf_i386

objects = loader.o kernel.o

# compile C++ kernel code into object file 
%.o: %.cpp
		g++ $(GPPPARAMS) -o $@ -c $<

# compile assebmly loader code into object file   
%.o: %.s
		as $(ASPARAMS) -o $@ $<

# use linker to combine assembly loader object file and C++ kernel object file into single binary
mykernel.bin: linker.ld $(objects)
		ld $(LDPARAMS) -T $< -o $@ $(objects)

# install new kernel bin into boot loader 
install: mykernel.bin
		sudo cp $< /boot/mykernel.bin

# create iso for new kernel on Linux machine. ### required packages; Virtualbox, grub2-common:i386, xorriso
mykernel.iso: mykernel.bin
		mkdir iso
		mkdir iso/boot
		mkdir iso/boot/grub
		cp $< iso/boot/
		echo 'set timeout=5' >> iso/boot/grub/grub.cfg
		echo 'set default=0' >> iso/boot/grub/grub.cfg
		echo '' >> iso/boot/grub/grub.cfg
		echo 'menuentry "My Operating System" {' >> iso/boot/grub/grub.cfg
		echo '  multiboot /boot/mykernel.bin' >> iso/boot/grub/grub.cfg
		echo '  boot' >> iso/boot/grub/grub.cfg
		echo '}' >> iso/boot/grub/grub.cfg
		grub-mkrescue --output=$@ iso
		rm -rf iso/