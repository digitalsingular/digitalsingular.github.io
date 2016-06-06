#!/bin/bash
rm -rf output
jbake -b
git add .
git commit
git push origin master
rm -rf ../agustinventura.github.io/*
cp -R output/* ../agustinventura.github.io/
cd ../agustinventura.github.io/
git add .
git commit
git push origin master
