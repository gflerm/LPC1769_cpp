###########################################################################
# Dawid Bazan <dawidbazan@gmail.com>
#
# makefile
#
# Supported commands:
# make all = Build software
# make clean = Clean out files generated by make all command
# make flash = Flash microcontroller with compiled software
#
###########################################################################
include sources.mk

###########################################################################
# Tool chain files and shell commands
###########################################################################
TCHAIN_PREFIX = arm-none-eabi-
CC      = $(TCHAIN_PREFIX)gcc
CPP     = $(TCHAIN_PREFIX)g++
AR      = $(TCHAIN_PREFIX)ar
OBJCOPY = $(TCHAIN_PREFIX)objcopy
OBJDUMP = $(TCHAIN_PREFIX)objdump
SIZE    = $(TCHAIN_PREFIX)size
NM      = $(TCHAIN_PREFIX)nm
RM  	  = rm -f

###########################################################################
# Target name and input/output path definitions
###########################################################################
# Directory for output files (lst, obj, dep, elf, sym, map, hex, bin etc.)
OUTDIR = release
OUTOBJDIR = $(OUTDIR)/obj
OUTDEPDIR = $(OUTDIR)/dep
OUTLSTDIR = $(OUTDIR)/lst

# Add all subfolders with source codes and includes to the makefile path
VPATH = $(SUBDIRS)

# List of all source files without directory and file-extension.
ALLSRCBASE = $(notdir $(basename $(SRCS_ALL)))

# Define all object files
OBJECTS     = $(addprefix $(OUTOBJDIR)/, $(addsuffix .o, $(ALLSRCBASE)))

#OBJECTS = $(CSRCS:.c=.o) $(CSRCARM:.c=.o) $(CPPSRC:.cpp=.o)

# SRCS_ALL = $(CSRC) $(SRCARM) $(CPPSRC) $(CPPSRCARM) $(ASRC) $(ASRCARM)

# Target file name
TARGET = lpc1769

###########################################################################
# Compiler settings
###########################################################################
# C/C++ compiler flags
#	-mcpu=cortex-m3 					# CPU name
#	-mthumb-interwork 					# Compile with using mixed instructions ARM and Thumb
#	-gdwarf-2  						    # Debugging format
#	-O2  								# Optimalization level
#	-fpromote-loop-indices   			# Convert loop indices to word-sized quantities
#	-Wall -Wextra 						# Turn all optional warnings plus extra optional
#   #optional warnings from -Wall and -Wextra below above line
#	-MD -MP -MF $(OUTDEPDIR)/$(@F).d 	# Compiler flags to generate dependency files
#	# -Wa -pass to the assembler, -adhlns -create assembler listing
#   $(patsubst %,-I%,$(SUBDIRS)) -I.    # Seach thru all subdirs
CFLAGS =  \
	-mcpu=cortex-m3 \
	-mthumb \
	-mthumb-interwork \
	-gdwarf-2 \
	-O2 \
	-fpromote-loop-indices \
	-Wall -Wextra \
	-Wimplicit -Wcast-align -Wpointer-arith -Wredundant-decls -Wshadow -Wcast-qual -Wcast-align \
	-MD -MP -MF $(OUTDEPDIR)/$(@F).d \
	-Wa,-adhlns=$(addprefix $(OUTLSTDIR)/, $(notdir $(addsuffix .lst, $(basename $<)))) \
	$(patsubst %,-I%,$(SUBDIRS)) -I.

# C only compiler flags
#   -Wnested-externs      				# Warn if an extern declaration is encountered within a function
#   -std=gnu99							# Defined standard: c99 plus GCC extensions
#   $(patsubst %,-I%,$(SUBDIRS)) -I.    # Seach thru all subdirs
CONLYFLAGS = \
	-Wnested-externs \
	-std=gnu99 \
	$(patsubst %,-I%,$(SUBDIRS)) -I.					

# C++ only compiler flags
#   -fno-rtti -fno-exceptions           # If you will not use virtual functions 
#                                       # those setting flags will optimalize the code
#   $(patsubst %,-I%,$(SUBDIRS)) -I.    # Seach thru all subdirs
CPPFLAGS = \
	-fno-rtti -fno-exceptions \
	$(patsubst %,-I%,$(SUBDIRS)) -I.		

# Assembler compliler flags
#	-mcpu=cortex-m3 \					# CPU name
#	-mthumb-interwork \					# Compile with using mixed instructions ARM and Thumb
#	-Wa, -gdwarf-2 \ 					# Debugging format
#	-x assembler-with-cpp \				# Source files C++ for assembler
#	-D__ASSEMBLY__ \					# Allows include files in assemler
#	# -Wa -pass to the assembler, -adhlns -create assembler listing
#   $(patsubst %,-I%,$(SUBDIRS)) -I.    # Seach thru all subdirs
ASFLAGS  = \
	-mcpu=cortex-m3 \
	-Wa, -gdwarf-2 \
	-x assembler-with-cpp \
	-D__ASSEMBLY__ \
	-Wa,-adhlns=$(addprefix $(OUTLSTDIR)/, $(notdir $(addsuffix .lst, $(basename $<)))) \
	$(patsubst %,-I%,$(SUBDIRS)) -I.

# Linker flags
#   -lc -lm -lgc -lstdc++				# Link to standard libraries (lLibrary)
#	-T$(LINKERSCRIPT)					# Use this linker script
#   -nostartfiles						# Do not use the standard system startup files when linking
# 	-Wl-pass to the linker, -Map -create map file, 
# 	--cref -Output a cross reference table, 
# 	--gc-sections -Enable garbage collection of unused input sections
LDFLAGS = \
	-lc -lm -lgcc -lstdc++ \
	-Wl,-Map=$(OUTDIR)/$(TARGET).map,--cref,--gc-sections \
	-T$(LINKERSCRIPT) -nostartfiles

###########################################################################
# Options for OpenOCD flash-programming
###########################################################################
# see openocd.pdf/openocd.texi for further information
############################################################TBD: adjust to linux/lpc1769
#OOCD_LOADFILE+=$(OUTDIR)/$(TARGET).elf
## Open OCD exec file
#OOCD_EXE=./OpenOCD/bin/openocd
## debug level
#OOCD_CL=-d0
##OOCD_CL=-d3
## interface and board/target settings (using the OOCD target-library here)
### OOCD_CL+=-f interface/jtagkey2.cfg -f target/stm32.cfg
#OOCD_CL+=-f interface/jtagkey.cfg -f target/stm32.cfg
## initialize
#OOCD_CL+=-c init
## enable "fast mode" - can be disabled for tests
#OOCD_CL+=-c "fast enable"
## show the targets
#OOCD_CL+=-c targets
## commands to prepare flash-write
#OOCD_CL+= -c "reset halt"
## increase JTAG frequency a little bit - can be disabled for tests
#OOCD_CL+= -c "jtag_khz 1200"
## flash-write and -verify
#OOCD_CL+=-c "flash write_image erase $(OOCD_LOADFILE)" -c "verify_image $(OOCD_LOADFILE)"
## reset target
#OOCD_CL+=-c "reset run"
## terminate OOCD after programming
#OOCD_CL+=-c shutdown

###########################################################################
# Targets
###########################################################################
# Listing of phony targets.
.PHONY : all begin end size gccversion build elf hex bin lss sym clean createdirs

# Default target.
all: begin createdirs gccversion build size end
	
# Output files to be build
elf: $(OUTDIR)/$(TARGET).elf
lss: $(OUTDIR)/$(TARGET).lss 
sym: $(OUTDIR)/$(TARGET).sym
hex: $(OUTDIR)/$(TARGET).hex
bin: $(OUTDIR)/$(TARGET).bin

# Build all outputs
build: elf hex bin lss sym

# Create output directories.
createdirs:
	-@mkdir $(OUTDIR) 2>/dev/null || echo "" >/dev/null
	-@mkdir $(OUTDEPDIR) 2>/dev/null || echo "" >/dev/null
	-@mkdir $(OUTLSTDIR) 2>/dev/null || echo "" >/dev/null
	-@mkdir $(OUTOBJDIR) 2>/dev/null || echo "" >/dev/null
	@echo $(OBJECTS)
	@echo $(ALLSRCBASE)
	
# Begin message
begin:
	@echo '!!!!!!!!!!!!!!!!!!! Building target !!!!!!!!!!!!!!!!!!!'
	@echo ' '

# End message
end:
	@echo ' '
	@echo '!!!!!!!!!!!!!!!!!!! Finished building target !!!!!!!!!!!!!!!!!!!'

# Calculate sizes of sections
size:
	@echo ' '	
	@echo '---- Calculating size of sections in elf file:'
	$(SIZE) -A -x $(OUTDIR)/$(TARGET).elf
	
# Display compiler version information.
gccversion : 
	@$(CC) --version

# Target: clean project.
clean:
	@echo ' '
	@echo '!!!!!!!!!!!!!!!!!!! Removing target !!!!!!!!!!!!!!!!!!!'
	$(RM) $(OUTDIR)/$(TARGET).map
	$(RM) $(OUTDIR)/$(TARGET).elf
	$(RM) $(OUTDIR)/$(TARGET).hex
	$(RM) $(OUTDIR)/$(TARGET).bin
	$(RM) $(OUTDIR)/$(TARGET).sym
	$(RM) $(OUTDIR)/$(TARGET).lss
	$(RM) $(OUTOBJDIR)/*.o >nul 2>&1
	$(RM) $(OUTLSTDIR)/*.lst >nul 2>&1
	$(RM) $(OUTDEPDIR)/*.o.d >nul 2>&1
	@echo '!!!!!!!!!!!!!!!!!!! Target removed !!!!!!!!!!!!!!!!!!!'
	
# TBD: program
program: #$(OUTDIR)/$(TARGET).elf
	@echo "Programming with OPENOCD"
	#$(OOCD_EXE) $(OOCD_CL)

###########################################################################
# Build release files
###########################################################################
# Create final output file (.hex) from ELF output file.
%.hex: %.elf
	@echo ' '
	@echo '---- Creating HEX file: ' $@
	$(OBJCOPY) -O ihex $< $@
	
# Create final output file (.bin) from ELF output file.
%.bin: %.elf
	@echo ' '
	@echo '---- Creating BINARY file: ' $@
	$(OBJCOPY) -O binary $< $@

# Create extended listing file/disassambly from ELF output file.
# using objdump testing: option -C
%.lss: %.elf
	@echo ' '
	@echo '---- Creating Extended Listing/Disassembly file: ' $@
	$(OBJDUMP) -h -S -C -r $< > $@

# Create a symbol table from ELF output file.
%.sym: %.elf
	@echo ' '
	@echo '---- Creating SYMBOL file: ' $@
	$(NM) -n $< > $@

# Link: create ELF output file from object files.
.SECONDARY : $(TARGET).elf
.PRECIOUS : $(OBJECTS)
%.elf:  $(OBJECTS)
	@echo ' '
	@echo '---- Linking, creating ELF file: ' $@
# use $(CC) for C-only projects or $(CPP) for C++-projects:
ifeq "$(strip $(CPPSRC)$(CPPSRCARM))" ""
	$(CC)  $(CFLAGS) $(OBJECTS) --output $@ -nostartfiles $(LDFLAGS)
else
	$(CPP)  $(CFLAGS) $(OBJECTS) --output $@ $(LDFLAGS)
endif

###########################################################################
# Compile
###########################################################################
# Assembler: create object files from assembler source files.
define ASSEMBLE_TEMPLATE
$(OUTOBJDIR)/$(notdir $(basename $(1))).o : $(1)
	@echo ' '
	@echo '---- Assembling: ' $$< to $$@
	$(CC) -c -mthumb -mthumb-interwork $$(ASFLAGS) $$< -o $$@ 
endef
$(foreach src, $(ASRC), $(eval $(call ASSEMBLE_TEMPLATE, $(src)))) 

# Assemble: create object files from assembler source files. ARM-only
define ASSEMBLE_ARM_TEMPLATE
$(OUTOBJDIR)/$(notdir $(basename $(1))).o : $(1)
	@echo ' '
	@echo '---- Assembling ARM-only: ' $$< to $$@
	$(CC) -c $$(ASFLAGS) $$< -o $$@ 
endef
$(foreach src, $(ASRCARM), $(eval $(call ASSEMBLE_ARM_TEMPLATE, $(src)))) 

# Compile: create object files from C source files.
define COMPILE_C_TEMPLATE
$(OUTOBJDIR)/$(notdir $(basename $(1))).o : $(1)
	@echo ' '
	@echo '---- Compiling C: ' $$< to $$@
	$(CC) -c -mthumb $$(CFLAGS) $$(CONLYFLAGS) $$< -o $$@ 
endef
$(foreach src, $(CSRC), $(eval $(call COMPILE_C_TEMPLATE, $(src)))) 

# Compile: create object files from C source files. ARM-only
define COMPILE_C_ARM_TEMPLATE
$(OUTOBJDIR)/$(notdir $(basename $(1))).o : $(1)
	@echo ' '
	@echo '---- Compiling C ARM-only: ' $$< to $$@
	$(CC) -c $$(CFLAGS) $$(CONLYFLAGS) $$< -o $$@ 
endef
$(foreach src, $(CSRCARM), $(eval $(call COMPILE_C_ARM_TEMPLATE, $(src)))) 


# Compile: create object files from C++ source files.
define COMPILE_CPP_TEMPLATE
$(OUTOBJDIR)/$(notdir $(basename $(1))).o : $(1)
	@echo ' '
	@echo '---- Compiling C++: ' $$< to $$@
	$(CC) -c -mthumb $$(CFLAGS) $$(CPPFLAGS) $$< -o $$@ 
endef
$(foreach src, $(CPPSRC), $(eval $(call COMPILE_CPP_TEMPLATE, $(src)))) 

# Compile: create object files from C++ source files. ARM-only
define COMPILE_CPP_ARM_TEMPLATE
$(OUTOBJDIR)/$(notdir $(basename $(1))).o : $(1)
	@echo ' '
	@echo '---- Compiling C++ ARM-only: ' $$< to $$@
	$(CC) -c $$(CFLAGS) $$(CPPFLAGS) $$< -o $$@ 
endef
$(foreach src, $(CPPSRCARM), $(eval $(call COMPILE_CPP_ARM_TEMPLATE, $(src)))) 

# Compile: create assembler files from C source files. ARM/Thumb
$(CSRC:.c=.s) : %.s : %.c
	@echo ' '
	@echo '---- Creating asm-File from C-Source: ' $< to $@
	$(CC) -mthumb -S $(CFLAGS) $(CONLYFLAGS) $< -o $@

# Compile: create assembler files from C source files. ARM only
$(CSRCARM:.c=.s) : %.s : %.c
	@echo ' '
	@echo '---- Creating asm-File from C-Source (ARM-only): ' $< to $@
	$(CC) -S $(CFLAGS) $(CONLYFLAGS) $< -o $@
