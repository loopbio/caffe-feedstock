#!/bin/bash

# Setup CMake build location
mkdir build
cd build

# Configure, build, test, and install.
if [ "$(uname)" == "Linux" ];
then
    # Stop Boost from using libquadmath.
    export CXXFLAGS="${CXXFLAGS} -DBOOST_MATH_DISABLE_FLOAT128"
fi

if [ $PY3K -eq 1 ]; then
    # This is not inferred correctly by cmake
    PY_MAJOR=3
else
    PY_MAJOR=2
fi

cmake .. -LAH                              \
      -DBLAS="open"                        \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}"   \
      -Dpython_version="$PY_MAJOR"
make -j$CPU_COUNT
make -j$CPU_COUNT runtest
make install

# Python installation is non-standard. So, we're fixing it.
mv "${PREFIX}/python/caffe" "${SP_DIR}/"
for FILENAME in $( cd "${PREFIX}/python/" && find . -name "*.py" | sed 's|./||' );
do
    chmod +x "${PREFIX}/python/${FILENAME}"
    cp "${PREFIX}/python/${FILENAME}" "${PREFIX}/bin/${FILENAME//.py}"
done
rm -rf "${PREFIX}/python/"
