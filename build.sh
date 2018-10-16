# Copy over the javascript
stack build
rm -f server/static/all.js
cp $(stack path --local-install-root)/bin/webworker-ghcjs.jsexe/all.js html
cp $(stack path --local-install-root)/bin/webworker-ghcjs.jsexe/all.js.externs html

# Remove the last line which runs main
sed -i 's/h$main(h$mainZCZCMainzimain)//g' html/all.js

# cat the fetch install handler
cat html/install_fetch_handler.js >> html/all.js
