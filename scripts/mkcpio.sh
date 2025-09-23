#!/usr/bin/env bash

(find . -print0 | cpio --null --format=newc -o | gzip -9) > ../initramfs.cpio.gz
