{-# LANGUAGE OverloadedStrings #-}
module Main where

import Data.JSString (JSString)
import GHCJS.Types
import GHCJS.DOM.EventTarget
import GHCJS.DOM.Event
import GHCJS.DOM.EventTargetClosures

foreign import javascript unsafe "self || $1" self ::  Int -> EventTarget
foreign import javascript unsafe "window.alert($1)" js_alert :: JSString -> IO ()
foreign import javascript unsafe
  "console.log($1)" console_log :: JSString -> IO ()

installHandler :: Event -> IO ()
installHandler e = console_log "Installed!"

main :: IO ()
main = do
  l <- eventListenerNew installHandler
  addEventListener (self 0) ("install" :: String) (Just l) False
