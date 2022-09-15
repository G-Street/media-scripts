#!/bin/sh
jexec $(jls | awk '/computation/ {print $1}') /usr/local/bin/bash
