# Copy over the javascript
stack build
cp $(stack path --local-install-root)/bin/webworker-ghcjs.jsexe/all.js html
cp $(stack path --local-install-root)/bin/webworker-ghcjs.jsexe/all.js.externs html

# Remove the last line which runs main
sed 's/h$main(h$mainZCZCMainzimain)//g' html/all.js > html/all.dontrunmain.js

# cat the fetch install handler
cat html/all.dontrunmain.js html/install_fetch_handler.js > html/sw.js
