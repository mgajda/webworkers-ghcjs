{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE JavaScriptFFI #-}

module WebWorker.Promise
  ( Promise
  , promiseGet
  , runPromiseM
  ) where

import Control.Monad.Cont (ContT(..), runContT)

import GHCJS.DOM.Types (ToJSVal(..), fromJSValUnchecked, FromJSVal(..), JSVal)
import GHCJS.Foreign.Callback (syncCallback1', releaseCallback, Callback)

newtype Promise a = Promise JSVal deriving (ToJSVal, FromJSVal)
type PromiseM = ContT JSVal IO

foreign import javascript safe "$2.then($1)" js_then :: Callback (JSVal -> IO JSVal) -> JSVal -> IO JSVal
foreign import javascript safe "new Promise(function (resolve, reject) {resolve ($1)})" js_newPromise :: JSVal -> IO JSVal

promiseGet ::(FromJSVal a) => Promise a -> PromiseM a
promiseGet (Promise jsVal) = ContT $ \f -> do
  let cbM = syncCallback1' $ \x_js -> do
        x <- fromJSValUnchecked x_js
        ret <- f x
        releaseCallback =<< cbM
        return ret

  cb <- cbM
  js_then cb jsVal

runPromiseM :: (ToJSVal a) => PromiseM a -> IO (Promise a)
runPromiseM c = do
  p_js <- runContT c toJSVal
  Promise <$> js_newPromise p_js

