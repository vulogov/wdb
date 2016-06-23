all: whitepy.so
clean:
	rm -rf build whitepy.c whitepy.so
whitepy.so: setup.py whitepy.pyx cwhitedb.pxd
	python setup.py build_ext --inplace
