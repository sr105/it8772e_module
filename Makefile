obj-m := f71808e_wdt.o
obj-m := it87_wdt.o
# We're going to create a script that calls make and
# passes in a value for KDIR
#KVERSION := 3.13.0-34-generic
#KDIR := /lib/modules/$(KVERSION)/build
PWD := $(shell pwd)

all: f71808e_wdt.ko watchdog_test partial_clean

modules: f71808e_wdt.ko it87_wdt.ko partial_clean

watchdog_test:

f71808e_wdt.ko it87_wdt.ko:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules

partial_clean:
	$(RM) -r $(shell cat .hgignore | sed '1,3d')

clean: partial_clean
	$(RM) -r *.ko watchdog_test
