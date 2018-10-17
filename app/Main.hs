{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.JSString (JSString)
import GHCJS.Types
import GHCJS.DOM.Types (JSM, Request, toJSVal)
import GHCJS.DOM.EventTarget
import GHCJS.DOM.Event
import GHCJS.DOM.EventTargetClosures
import GHCJS.DOM.Response (Response)
import GHCJS.DOM.WorkerGlobalScope (WorkerGlobalScope)
import GHCJS.DOM.Request
import GHCJS.DOM.Headers

foreign import javascript safe "$r = self" getSelf :: IO WorkerGlobalScope
foreign import javascript unsafe "window.alert($1)" js_alert :: JSString -> IO ()
foreign import javascript unsafe
  "console.log($1)" console_log :: JSString -> IO ()

newtype Promise = Promise JSVal

foreign import javascript safe "$r = $1[$2]" off :: JSVal -> JSVal -> JSVal
foreign import javascript safe "$r = {172: { 20: {4: 'eu-server.migamake.com'}}}" serverMap :: JSVal
foreign import javascript unsafe "$1.respondWith($2)" respondWith :: Event -> Promise -> IO ()
foreign import javascript unsafe "$1.request" getRequest :: Event -> Request
foreign import javascript unsafe "$1.fetch($2)" fetch :: WorkerGlobalScope -> Request -> IO Promise

-- TODO: Request routing logic
routeRequest :: Request -> IO Request
routeRequest r = do
  h <- getHeaders r
  cfip <- (get h ("cf-connecting-ip" :: String)) :: IO (Maybe String)
  case cfip of
    Nothing -> return r
    Just t  -> return r

fetchHandler :: Event -> IO()
fetchHandler e = do
  self <- getSelf
  console_log "Routing.."
  r <- routeRequest $ getRequest e
  resp <- fetch self r
  respondWith e resp

main :: IO ()
main = console_log "Dummy main"
