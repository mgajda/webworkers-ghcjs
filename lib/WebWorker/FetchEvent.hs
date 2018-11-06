module WebWorker.FetchEvent where

import WebWorker.Promise

import GHCJS.DOM.Types (Request)
import GHCJS.Types (JSVal)
import Control.Monad.IO.Class (MonadIO, liftIO)

newtype FetchEvent = FetchEvent JSVal

foreign import javascript safe "$1.respondWith($2)" js_respondWith :: FetchEvent -> Promise a -> IO ()
foreign import javascript safe "$1.request" js_getRequest :: FetchEvent -> IO Request

respondWith :: (MonadIO m) => FetchEvent -> Promise a -> m ()
respondWith fe p = liftIO $ js_respondWith fe p

getRequest :: (MonadIO m) => FetchEvent -> m Request
getRequest self = liftIO $ js_getRequest self
