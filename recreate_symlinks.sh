#!/bin/bash

rm -rf ./.pi
mkdir -p ./.pi/skills
cd ./.pi/skills

ln -s ../../qwen-image-21-prompting/ qwen-image-21-prompting
ln -s ../../boogu-image-01-turbo-prompting/ boogu-image-01-turbo-prompting
ln -s ../../boogu-image-01-edit-turbo-prompting/ boogu-image-01-edit-turbo-prompting

