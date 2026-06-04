#!/bin/bash

rm -rf build i18n/*.qm

cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DAPP_DISTRIBUTION=Quentium-builds
cmake --build build -j $(nproc)

./build/src/NotepadNext
