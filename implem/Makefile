## Parameters
PROG ?= lui
TOP  ?= PROC_complet
TIME ?= 10000ns
VERB ?= 0
SEQUENCE  ?= program/sequence_tag
TESTS_DIR ?= program/autotest/


.PHONY: compile simulation synthesis fpga autotest clean realclean

## Main rule
all: help

## Directories
include config/directory.mk

# Sub Makefiles
SIMULATION_MK:=config/simulation.mk
SYNTHESIS_MK:=config/synthesis.mk
AUTOTEST_MK:=config/autotest.mk
COMPILE_MK:=config/compile_RISCV.mk

## Rules

# Compile
compile: export PROG:=$(PROG)
compile: |clean_log
	@$(MAKE) -s -f $(COMPILE_MK)

# Simulation with GUI
simulation: export TOP:=$(TOP)
simulation: compile |clean_log
	@$(MAKE) -s -f $(SIMULATION_MK) GUI

# Simulation whithout gui
simulation_cli: export TIME:=$(TIME)
simulation_cli: export TOP:=$(TOP)
simulation_cli: compile |clean_log
	@$(MAKE) -s -f $(SIMULATION_MK) run trace

# FPGA
synthesis: export TOP:=$(TOP)
synthesis: compile |clean_log
	@$(MAKE) -s -f $(SYNTHESIS_MK)

fpga: export TOP:=$(TOP)
fpga: compile
	@$(MAKE) -s -f $(SYNTHESIS_MK) run


# Autotests
autotest: export SEQUENCE_TAG:=$(SEQUENCE)
autotest: export TESTS_DIR:=$(TESTS_DIR)
autotest: |clean_log
	@$(MAKE) -s -f $(AUTOTEST_MK) print


clean_log:
	rm -f log

clean:
	@$(MAKE) -s -f $(COMPILE_MK) clean
	@$(MAKE) -s -f $(AUTOTEST_MK) clean
	@$(MAKE) -s -f $(SYNTHESIS_MK) clean
	@$(MAKE) -s -f $(SIMULATION_MK) clean

clean_femto:
	@$(MAKE) -s -f $(COMPILE_MK) clean_femto

realclean:
	@$(MAKE) -s -f $(COMPILE_MK) realclean
	@$(MAKE) -s -f $(AUTOTEST_MK) realclean
	@$(MAKE) -s -f $(SYNTHESIS_MK) realclean
	@$(MAKE) -s -f $(SIMULATION_MK) realclean

# Help message
help:
	@echo "Usage:"
	@echo "  make <target> [<variable>]"
	@echo ""
	@echo "Targets:"
	@echo "  help            Affiche cette help."
	@echo "  clean           Suppression des fichiers générés."
	@echo "  simulation      Lance la simulation."
	@echo "  autotest        Lance les autotests."
	@echo "  synthesis       Lance la synthèse."
	@echo "  fpga            Lance la synthèse et programme le FPGA."
	@echo ""
	@echo "Variables:"
	@echo "  TOP=<top>       Definit le top design à synthétiser ou simuler."
	@echo "  PROG=<prog>     Definit le programme RISCV à executer."
	@echo "  TIME=<time>     Définit le temps de simulation maximum. (Exemple: TIME=100ns)"
	@echo "  SEQUENCE=<seq>  Définit une séquence de tests pour autotest."
	@echo ""
	@echo "Exemples:"
	@echo "make simulation PROG=counter TIME=1000ns"
	@echo "make autotest SEQUENCE=program/sequence_test0"
	@echo ""
