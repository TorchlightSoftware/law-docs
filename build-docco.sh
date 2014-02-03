#!/usr/bin/env bash

src=./node_modules/law/test/examples.coffee
template=./src/docco/docco.jst
output=./tmp

docco $src \
  --template $template \
  --output $output

cp ./tmp/examples.html ./src/partials
