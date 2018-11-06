{-# LANGUAGE JavaScriptFFI #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module WebWorker.Response where

import WebWorker.Promise (Promise)

import Data.JSString (JSString)

import GHCJS.DOM.Response (Response)
import GHCJS.DOM.WorkerGlobalScope (WorkerGlobalScope, fetch)
import Control.Monad.IO.Class (MonadIO, liftIO)

foreign import javascript safe "$1.text()" text :: Response -> IO (Promise JSString)
