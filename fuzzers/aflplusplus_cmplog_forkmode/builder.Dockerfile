# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARG parent_image
FROM $parent_image

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        python3-dev \
        python3-setuptools \
        automake \
        cmake \
        git \
        flex \
        bison \
        libglib2.0-dev \
        libpixman-1-dev \
        cargo \
        libgtk-3-dev \
        # for QEMU mode
        ninja-build \
        gcc-$(gcc --version|head -n1|sed 's/\..*//'|sed 's/.* //')-plugin-dev \
        libstdc++-$(gcc --version|head -n1|sed 's/\..*//'|sed 's/.* //')-dev

# Download afl++.
RUN git clone https://github.com/AFLplusplus/AFLplusplus /afl

# Checkout a current commit
RUN cd /afl && git checkout 149366507da1ff8e3e8c4962f3abc6c8fd78b222

# Build without Python support as we don't need it.
# Set AFL_NO_X86 to skip flaky tests.
RUN cd /afl && \
    unset CFLAGS CXXFLAGS && \
    export CC=clang AFL_NO_X86=1 NO_NYX=1 NO_PYTHON=1 && \
    make distrib && \
    make install

RUN wget https://raw.githubusercontent.com/llvm/llvm-project/llvmorg-15.0.7/compiler-rt/lib/fuzzer/standalone/StandaloneFuzzTargetMain.c \
    -O /StandaloneFuzzTargetMain.c

# Build standalone wrapper for AFL++ fork-mode
RUN /afl/afl-clang-fast -c \
        /StandaloneFuzzTargetMain.c \
        -o /StandaloneFuzzTargetMainAFL.o && \
    ar rc /libStandaloneFuzzTarget.a \
        /StandaloneFuzzTargetMainAFL.o && \
    rm /StandaloneFuzzTargetMainAFL.o
