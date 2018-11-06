{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Routing where

import Control.Monad.IO.Class (MonadIO, liftIO)

import Data.FileEmbed
import Data.Aeson (parseJSON)
import Data.Aeson.Types (parseEither)

import GHCJS.DOM.Headers (get)
import GHCJS.DOM.Types (Request)
import GHCJS.DOM.Request (getHeaders)
import qualified Data.HashMap.Strict as HM

type OctetMap a = HM.HashMap String (Either String a)
type ServerMap = OctetMap (OctetMap (OctetMap (HM.HashMap String String)))

serverMap :: ServerMap
serverMap = ((either error id) . (parseEither parseJSON)) $ $(embedStringFile "config/server_map.json")

lookupServer :: [String] -> ServerMap -> Maybe String
lookupServer [a, b, c, d] sm = f a (f b (f c (HM.lookup d))) sm
  where
    f x r m = maybe Nothing (either return r) (HM.lookup x m)
lookupServer _ _ = Nothing

splitIp :: String -> [String]
splitIp = foldr go []
  where
    go '.' acc = "" : acc
    go x [] = go x [""]
    go c (x : xs) = (c : x) : xs

routeRequest :: MonadIO m => Request -> m Request
routeRequest r = do
  h <- getHeaders r
  cfip <- (get h ("cf-connecting-ip" :: String)) -- ::  IO (Maybe String)
  case cfip of
    Nothing -> return r
    Just (_ :: String)  -> return r
