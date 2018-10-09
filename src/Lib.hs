{-# LANGUAGE OverloadedStrings #-}
module Lib
    ( someFunc
    ) where

import Data.JSString ()
import GHCJS.Types

newtype ServiceClient = ServiceClient JSVal

foreign import javascript safe "self" self :: ServiceClient

foreign import javascript unsafe "window.alert($1)" js_alert :: JSString -> IO ()

someFunc :: IO ()
someFunc = js_alert "Hello from GHCJS!"

oninstall :: IO ()
oninstall =
