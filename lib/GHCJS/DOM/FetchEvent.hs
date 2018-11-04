module GHCJS.DOM.FetchEvent
  ( FetchEvent
  , getRequest
  , respondWith
  ) where

import GHCJS.DOM.Types (JSVal)
import GHCJS.DOM.Request (Request)
import GHCJS.DOM.Response (Response)

import Control.Monad.IO.Class (MonadIO, liftIO)

foreign import javascript unsafe "$1.request" js_getRequest :: FetchEvent -> IO Request
foreign import javascript unsafe "$1.respondWith($2)" js_respondWith :: FetchEvent -> Response -> IO ()

newtype FetchEvent = FetchEvent JSVal

getRequest :: MonadIO m => FetchEvent -> m Request
getRequest = liftIO . js_getRequest

respondWith :: MonadIO m => FetchEvent -> Response -> m ()
respondWith e resp = liftIO $ js_respondWith e resp

