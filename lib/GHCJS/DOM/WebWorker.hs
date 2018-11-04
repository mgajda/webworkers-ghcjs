
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module GHCJS.DOM.WebWorker
  (WebWorkerIO
  , getSelf
  , runWebWorkerIOAction
  ) where

import GHCJS.DOM.WorkerGlobalScope (WorkerGlobalScope, fetch)
import Control.Monad.IO.Class (MonadIO, liftIO)

foreign import javascript safe "$r = self" js_getSelf :: IO WorkerGlobalScope

newtype WebWorkerIO a = WebWorkerIO {unWebWorker :: IO a} deriving (Functor, Applicative, Monad, MonadIO)

getSelf :: WebWorkerIO WorkerGlobalScope
getSelf = liftIO js_getSelf

runWebWorkerIOAction :: WebWorkerIO a -> IO a
runWebWorkerIOAction (WebWorkerIO x) = x
