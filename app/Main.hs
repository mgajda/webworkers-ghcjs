{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Data.JSString (JSString)
import GHCJS.Types
import GHCJS.DOM.Types (JSM, Request, toJSVal, Nullable)
import GHCJS.DOM.Response (Response)
import GHCJS.DOM.WorkerGlobalScope (WorkerGlobalScope, fetch)
import GHCJS.DOM.Request
import GHCJS.DOM.Headers

import qualified Data.HashMap.Strict as HM

import Data.FileEmbed
import Data.Aeson
import Data.Aeson.Types (parseEither)
import Data.Either (either)
import Language.Haskell.TH
import Data.List
import Control.Monad.IO.Class (MonadIO)

import GHCJS.DOM.WebWorker (WebWorkerIO, getSelf, runWebWorkerIOAction)
import GHCJS.DOM.FetchEvent (FetchEvent, getRequest, respondWith)

foreign import javascript unsafe "window.alert($1)" js_alert :: JSString -> IO ()
foreign import javascript unsafe "console.log($1)" console_log :: JSString -> IO ()

type OctetMap a = HM.HashMap String (Either String a)
type ServerMap = OctetMap (OctetMap (OctetMap (HM.HashMap String String)))

serverMap :: ServerMap
serverMap = ((either error id) . (parseEither parseJSON)) $ $(embedStringFile "config/server_map.json")

lookupServer :: [String] -> ServerMap -> Maybe String
lookupServer [a, b, c, d] sm = f a (f b (f c (HM.lookup d))) sm
  where
    f x c m = maybe Nothing (either return c) (HM.lookup x m)
lookupServer _ _ = Nothing

splitIp :: String -> [String]
splitIp = foldr go [""]
  where
    go '.' acc = "" : acc
    go c (x : xs) = (c : x) : xs

-- TODO: Request routing logic
routeRequest :: MonadIO m => Request -> m Request
routeRequest r = do
  h <- getHeaders r
  cfip <- (get h ("cf-connecting-ip" :: String)) -- ::  IO (Maybe String)
  case cfip of
    Nothing -> return r
    Just (t :: String)  -> return r

fetchHandler :: FetchEvent -> IO ()
fetchHandler e = runWebWorkerIOAction $ do
  self <- getSelf
  req <- getRequest e
  r <- routeRequest req
  resp <- fetch self r Nothing
  respondWith e resp

main :: IO ()
main = console_log "Dummy main"
