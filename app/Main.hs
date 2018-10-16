{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.JSString (JSString)
import GHCJS.Types
import GHCJS.DOM.Types (JSM, Request, toJSVal)
import GHCJS.DOM.EventTarget
import GHCJS.DOM.Event
import GHCJS.DOM.EventTargetClosures
import GHCJS.DOM.Response
import GHCJS.DOM.WorkerGlobalScope (WorkerGlobalScope)

foreign import javascript safe "$r = self" getSelf :: IO WorkerGlobalScope
foreign import javascript unsafe "window.alert($1)" js_alert :: JSString -> IO ()
foreign import javascript unsafe
  "console.log($1)" console_log :: JSString -> IO ()

newtype Promise = Promise JSVal

foreign import javascript unsafe "$1.respondWith($2)" respondWith :: Event -> Promise -> IO ()
foreign import javascript unsafe "$1.request" getRequest :: Event -> Request
foreign import javascript unsafe "$1.fetch($2)" fetch :: WorkerGlobalScope -> Request -> IO Promise

installHandler :: Event -> IO ()
installHandler e = console_log "Installed service worker!"

-- TODO: Request routing logic
routeRequest :: Request -> Request
routeRequest = id

fetchHandler :: Event -> IO ()
fetchHandler e = do
  self <- getSelf
  console_log "Fetching.."
  resp <- (fetch self (routeRequest $ getRequest e))
  respondWith e resp

main :: IO ()
main =  do
  self <- getSelf;
  il <- eventListenerNew installHandler
  addEventListener self ("install" :: String) (Just il) False

  fl <- eventListenerNewSync fetchHandler
  addEventListener self ("fetch" :: String) (Just fl) True


