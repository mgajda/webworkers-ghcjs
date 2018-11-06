{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE JavaScriptFFI #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE TypeFamilies #-}

module Main where

import GHCJS.Types (JSVal)
import GHCJS.DOM.Types (Request, Headers)
import GHCJS.DOM.Response (Response(..))
import GHCJS.DOM.Request (getUrl)


import Data.JSString (JSString, splitOn, intercalate)
import Data.Monoid ((<>))

import Control.Monad.IO.Class (liftIO)

import WebWorker.WebWorker (WebWorkerIO, getSelf, runWebWorkerIOAction, fetch)
import WebWorker.FetchEvent (FetchEvent, respondWith, getRequest)
import WebWorker.Response (text)
import WebWorker.Promise (promiseGet, runPromiseM)

-- TODO: Enable once request routing is required. Commenting this out
-- speeds up compilation by not requiring TH
-- import Routing

foreign import javascript unsafe "window.alert($1)" js_alert :: JSString -> IO ()
foreign import javascript unsafe "console.log($1)" console_log :: JSString -> IO ()

-- TODO: Use the GHCJS.DOM.Request version of newRequest. Make a better version of newHeaders
foreign import javascript unsafe "new Request($1)" js_newRequest :: JSString -> IO Request
foreign import javascript unsafe "new Headers($1)" js_newHeaders :: Headers -> IO Headers

-- TODO: Make a better version of new Response
foreign import javascript unsafe "new Response($2, {status : $1.status, statusText : $1.statusText, headers : $1.headers})" js_newResponse :: Response -> JSString -> IO JSVal

splitComponents :: JSString -> Maybe (JSString, JSString)
splitComponents s = case splitOn "/" s of
  [] -> Nothing
  xs -> Just (intercalate "/" $ init xs, last xs)

dynamicEndpoint :: JSString
dynamicEndpoint = "https://jsonplaceholder.typicode.com/todos/1"

staticEndpoint :: JSString
staticEndpoint = "https://jsonplaceholder.typicode.com/posts/1"

dynamicFetchHandler :: FetchEvent -> WebWorkerIO ()
dynamicFetchHandler e = do
  self <- getSelf
  req1 <- liftIO $ js_newRequest staticEndpoint
  req2 <- liftIO $ js_newRequest dynamicEndpoint

  p1 <- fetch self req1
  p2 <- fetch self req2

  let p = do
        resp1 <- promiseGet p1
        resp2 <- promiseGet p2
        p3 <- liftIO $ text resp1
        p4 <- liftIO $ text resp2
        text1 <- promiseGet p3
        text2 <- promiseGet p4
        liftIO $ js_newResponse resp1 ("[" <> text1 <> "," <> text2 <> "]")

  respondWith e =<< (liftIO $ runPromiseM p)

fetchHandler :: FetchEvent -> IO ()
fetchHandler e = runWebWorkerIOAction $ do
  self <- getSelf
  r <- getRequest e
  -- r <- routeRequest req
  url <- getUrl r
  case splitComponents url of
    Just (_, "static-dynamic") -> dynamicFetchHandler e
    _ -> respondWith e =<< fetch self r

main :: IO ()
main = console_log ("Dummy main" :: JSString)
