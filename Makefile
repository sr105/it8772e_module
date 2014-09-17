obj-m := f71808e_wdt.o
KVERSION := 3.13.0-34-generic
KDIR := /lib/modules/$(KVERSION)/build
PWD := $(shell pwd)

all: f71808e_wdt.ko watchdog_test partial_clean

f71808e_wdt.ko:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules

partial_clean:
	$(RM) -r $(shell cat .hgignore | sed '1,3d')

clean: partial_clean
	$(RM) -r *.ko watchdog_test
