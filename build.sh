# Copy over the javascript
stack build
rm -f server/static/all.js
cp $(stack path --local-install-root)/bin/webworker-ghcjs.jsexe/all.js html
