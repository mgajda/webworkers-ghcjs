{-# LANGUAGE JavaScriptFFI #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module WebWorker.Response
  (
    text
  ) where

import WebWorker.Promise (Promise)

import Data.JSString (JSString)
import GHCJS.DOM.Response (Response)

foreign import javascript safe "$1.text()" text :: Response -> IO (Promise JSString)
