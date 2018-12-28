#!/bin/bash
jbake -b
git add .
git commit
git push origin master
cp -R output/* ../agustinventura.github.io/
cd ../agustinventura.github.io/
git add .
git commit
git pull
git push origin master
