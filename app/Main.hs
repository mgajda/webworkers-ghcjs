{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.JSString (JSString)
import GHCJS.Types
import GHCJS.DOM.Types (JSM, Request, toJSVal)
import GHCJS.DOM.EventTarget
import GHCJS.DOM.Event
import GHCJS.DOM.EventTargetClosures
import GHCJS.DOM.Response
import GHCJS.DOM.WorkerGlobalScope
import GHCJS.DOM.Response 

foreign import javascript unsafe "self || $1" self ::  Int -> WorkerGlobalScope
foreign import javascript unsafe "window.alert($1)" js_alert :: JSString -> IO ()
foreign import javascript unsafe
  "console.log($1)" console_log :: JSString -> IO ()

foreign import javascript unsafe "$1.respondWith($2)" respondWith :: Event -> JSVal -> IO ()
foreign import javascript unsafe "$1.request" getRequest :: Event -> Request
foreign import javascript unsafe "$1.fetch($2)" myFetch :: WorkerGlobalScope -> Request -> IO JSVal

installHandler :: Event -> IO ()
installHandler e = console_log "Installed! Wow"

fetchHandler :: Event -> IO ()
fetchHandler e = do
  console_log "Fetching.."
  resp <- (myFetch (self 0) (getRequest e))
  respondWith e resp

main :: IO ()
main =  do
  il <- eventListenerNew installHandler
  addEventListener (self 0) ("install" :: String) (Just il) False

  fl <- eventListenerNewSync fetchHandler
  addEventListener (self 0) ("fetch" :: String) (Just fl) True


