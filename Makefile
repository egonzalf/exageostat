# Common binaries
CC             := gcc
LD             := $(CC)
OPTS           := -c -fPIC -DEXAGEOSTAT_USE_HICMA

flagsc += $(shell pkg-config hicma --cflags)
flagsc += $(shell pkg-config starsh --cflags)
flagsc += $(shell pkg-config chameleon --cflags)
flagsc += $(shell pkg-config libstarpu --cflags)
flagsc += $(shell pkg-config nlopt --cflags)
flagsc += $(shell pkg-config gsl --cflags)
flagsc += $(shell pkg-config lapacke --cflags)

flagsl += $(shell pkg-config hicma --libs)
flagsl += $(shell pkg-config starsh --libs)
flagsl += $(shell pkg-config chameleon --libs)
flagsl += $(shell pkg-config libstarpu --libs)
flagsl += $(shell pkg-config nlopt --libs)
flagsl += $(shell pkg-config gsl --libs)
flagsl += $(shell pkg-config lapacke --libs --static)


#user flags
EXTRA_LDFLAGS   = -O3  -w -Ofast -lstarpu-1.2   -lchameleon  -lchameleon_starpu -lhicma -lcoreblas -lstdc++ $(flagsl) $(LAPACK_LIBS) $(BLAS_LIBS) $(shell pkg-config lapacke --libs --static) 
EXTRA_CFLAGS    = -O3  -w -Ofast -Wall -I./include/ -I./src/include/ -I./exageostat_exact/core/include/ -I./exageostat_exact/runtime/starpu/include/ -I./misc/include/ -I./exageostat_exact/src/include/ -I./r-wrappers/include  -I./exageostat_approx/runtime/starpu/include/ -I./exageostat_approx/src/include/ $(flagsc) -I./hicma/chameleon/include -I./hicma/chameleon/coreblas/include/coreblas -I./hicma/chameleon/build/include $(shell pkg-config lapacke --cflags)

MAIN =  ./examples/zgen_mle_testr.c
SOURCE_FILES = $(filter-out $(MAIN), $(wildcard ./src/compute/*.c ./exageostat_exact/core/compute/*.c ./exageostat_exact/src/compute/*.c ./exageostat_exact/runtime/starpu/codelets/*.c  ./misc/compute/flat_file.c  ./misc/compute/MLE_misc.c    ./r-wrappers/compute/*.c ./exageostat_approx/runtime/starpu/codelets/*.c ./exageostat_approx/src/compute/*.c))

OBJ_FILES = $(patsubst %.c,%.o,$(SOURCE_FILES))

exageostat.so:    $(OBJ_FILES)
	R CMD SHLIB -o exageostat.so $(OBJ_FILES) $(LDFLAGS) $(EXTRA_LDFLAGS) 

#####################
# default make rule #
#####################

TARGET = ./examples/zgen_mle_testr

.PHONY: all
all: $(TARGET)


$(TARGET): $(MAIN) $(SOURCE_FILES)
	$(LD) $(OPTS) $(CFLAGS) $(EXTRA_CFLAGS) $^ -o $@ $(LDFLAGS) $(EXTRA_LDFLAGS)
%.o: %.c
	$(CC) $(OPTS) -c $(CFLAGS) $(EXTRA_CFLAGS) $^ -o $@

.PHONY: clean
clean:
	rm -rf *.o *.so
	rm -f $(TARGET)
	find . -name "*.o" -type f -delete
