{-# LANGUAGE JavaScriptFFI #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module WebWorker.WebWorker
  ( WebWorkerIO
  , getSelf
  , runWebWorkerIOAction
  , fetch
  ) where

import WebWorker.Promise

import GHCJS.DOM.Response (Response)
import GHCJS.DOM.Types (Request)
import GHCJS.DOM.WorkerGlobalScope (WorkerGlobalScope)
import Control.Monad.IO.Class (MonadIO, liftIO)

foreign import javascript safe "$r = self" js_getSelf :: IO WorkerGlobalScope
foreign import javascript safe "$1.fetch($2)" js_fetch :: WorkerGlobalScope -> Request -> IO (Promise Response)

newtype WebWorkerIO a = WebWorkerIO {unWebWorker :: IO a} deriving (Functor, Applicative, Monad, MonadIO)

getSelf :: WebWorkerIO WorkerGlobalScope
getSelf = liftIO js_getSelf

runWebWorkerIOAction :: WebWorkerIO a -> IO a
runWebWorkerIOAction (WebWorkerIO x) = x

fetch :: WorkerGlobalScope -> Request -> WebWorkerIO (Promise Response)
fetch wgs r = liftIO $ js_fetch wgs r
