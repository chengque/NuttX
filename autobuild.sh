#!/bin/bash
find nuttx/configs -name \*defconfig -print | xargs -L1 nuttx/tools/build_config.sh