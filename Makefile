# Makefile for SVM-perf, 31.10.05
UNAME := $(shell uname)

ifeq ($(UNAME), Darwin)
    MATLABROOT ?= /Applications/MATLAB_R2015a.app
endif
ifeq ($(UNAME), Linux)
    MATLABROOT ?= /usr/local/MATLAB/R2014b/
endif

MEX = $(MATLABROOT)/bin/mex
#Use the following to compile under unix or cygwin
CC = gcc
LD = gcc

#Call 'make' using the following line to make CYGWIN produce stand-alone Windows executables
#		make 'SFLAGS=-mno-cygwin'

CFLAGS =   $(SFLAGS) -O3 -fomit-frame-pointer -ffast-math -Wall 
LDFLAGS =  $(SFLAGS) -O3 -lm -Wall
#CFLAGS =  $(SFLAGS) -pg -Wall
#LDFLAGS = $(SFLAGS) -pg -Wall 
LIBS=-L. -lm                    # used libraries

all: svm_rank_learn svm_rank_classify

.PHONY: clean
clean: svm_light_clean svm_struct_clean
	rm -f *.o *.tcov *.d core gmon.out *.stackdump 

#-----------------------#
#----   SVM-light   ----#
#-----------------------#
svm_light_hideo_noexe: 
	cd svm_light; make svm_learn_hideo_noexe

svm_light_clean: 
	cd svm_light; make clean

#----------------------#
#----  STRUCT SVM  ----#
#----------------------#

svm_struct_noexe: 
	cd svm_struct; make svm_struct_noexe

svm_struct_clean: 
	cd svm_struct; make clean


#---------------------#
#----  SVM rank   ----#
#---------------------#

svm_rank_classify: svm_light_hideo_noexe svm_struct_noexe svm_struct_api.o svm_struct/svm_struct_classify.o svm_struct/svm_struct_common.o svm_struct/svm_struct_main.o 
	$(MEX) -largeArrayDims svm_struct_api.o svm_struct/svm_struct_classify.o svm_light/svm_common.o svm_struct/svm_struct_common.o -output svm_rank_classify
	#$(LD) $(LDFLAGS) svm_struct_api.o svm_struct/svm_struct_classify.o svm_light/svm_common.o svm_struct/svm_struct_common.o -o svm_rank_classify $(LIBS)

svm_rank_learn: svm_light_hideo_noexe svm_struct_noexe svm_struct_api.o svm_struct_learn_custom.o svm_struct/svm_struct_learn.o svm_struct/svm_struct_common.o svm_struct/svm_struct_main.o
	#$(LD) $(LDFLAGS) svm_struct/svm_struct_learn.o svm_struct_learn_custom.o svm_struct_api.o svm_light/svm_hideo.o svm_light/svm_learn.o svm_light/svm_common.o svm_struct/svm_struct_common.o svm_struct/svm_struct_main.o -o svm_rank_learn $(LIBS)
	$(MEX) -largeArrayDims svm_struct/svm_struct_learn.o svm_struct_learn_custom.o svm_struct_api.o svm_light/svm_hideo.o svm_light/svm_learn.o svm_light/svm_common.o svm_struct/svm_struct_common.o svm_struct/svm_struct_main.o -output svm_rank_learn

svm_struct_api.o: svm_struct_api.c svm_struct_api.h svm_struct_api_types.h svm_light/svm_common.h svm_struct/svm_struct_common.h
	$(MEX) -largeArrayDims -O CFLAGS='-std=c99 -fPIC' -c  svm_struct_api.c  svm_struct_api.o

svm_struct_learn_custom.o: svm_struct_learn_custom.c svm_struct_api.h svm_light/svm_common.h svm_struct_api_types.h svm_struct/svm_struct_common.h
	$(MEX) -largeArrayDims -O CFLAGS='-std=c99 -fPIC' -c svm_struct_learn_custom.c  svm_struct_learn_custom.o

