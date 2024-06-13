from Cython.Build import cythonize
from setuptools import setup

setup(
    packages = ["dsp-tester"],
    ext_modules=cythonize(["dma.py", "fpga.py", "ocm.py"])
)