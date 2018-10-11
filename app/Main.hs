{-# LANGUAGE OverloadedStrings #-}
module Main where

import Data.JSString (JSString)
import GHCJS.Types
import GHCJS.DOM.EventTarget
import GHCJS.DOM.Event
import GHCJS.DOM.EventTargetClosures
import GHCJS.DOM.Response

foreign import javascript unsafe "self || $1" self ::  Int -> EventTarget
foreign import javascript unsafe "window.alert($1)" js_alert :: JSString -> IO ()
foreign import javascript unsafe
  "console.log($1)" console_log :: JSString -> IO ()

foreign import javascript unsafe "$1.respondWith($2)" respondWith :: Event -> Response -> IO ()

installHandler :: Event -> IO ()
installHandler e = console_log "Installed!"

fetchHandler :: Event -> IO ()
fetchHandler e = do
  console_log "Fetching.."
  respondWith e (Response nullRef)

main :: IO ()
main =  do
  il <- eventListenerNew installHandler
  addEventListener (self 0) ("install" :: String) (Just il) False

  fl <- eventListenerNew fetchHandler
  addEventListener (self 0) ("fetch" :: String) (Just fl) False

