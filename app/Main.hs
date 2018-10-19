{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TemplateHaskell #-}

module Main where

import Data.JSString (JSString)
import GHCJS.Types
import GHCJS.DOM.Types (JSM, Request, toJSVal, Nullable)
import GHCJS.DOM.EventTarget
import GHCJS.DOM.Event
import GHCJS.DOM.EventTargetClosures
import GHCJS.DOM.Response (Response)
import GHCJS.DOM.WorkerGlobalScope (WorkerGlobalScope)
import GHCJS.DOM.Request
import GHCJS.DOM.Headers

import Data.HashMap.Strict (HashMap)

import Data.FileEmbed
import GHC.Generics
import Data.Aeson
import Data.Aeson.Types (parseEither)
import Data.Either (either)
import Language.Haskell.TH
import Data.List

foreign import javascript safe "$r = self" getSelf :: IO WorkerGlobalScope
foreign import javascript unsafe "window.alert($1)" js_alert :: JSString -> IO ()
foreign import javascript unsafe "console.log($1)" console_log :: JSString -> IO ()

newtype Promise = Promise JSVal

foreign import javascript safe "$r = $1[$2]" lookup :: JSVal -> JSVal -> Nullable JSVal
foreign import javascript unsafe "$1.respondWith($2)" respondWith :: Event -> Promise -> IO ()
foreign import javascript unsafe "$1.request" getRequest :: Event -> Request
foreign import javascript unsafe "$1.fetch($2)" fetch :: WorkerGlobalScope -> Request -> IO Promise

type OctetMap a = HashMap String (Either a String)
type ServerMap = OctetMap (OctetMap (OctetMap (HashMap String String)))

serverMap :: ServerMap
serverMap = ((either error id) . (parseEither parseJSON)) $ $(embedStringFile "config/server_map.json")

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
