#!/bin/bash

rm -rf build i18n/*.qm

cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build -j $(nproc)

./build/src/NotepadNext
