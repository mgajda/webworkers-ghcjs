
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
import GHCJS.DOM.Request (getUrl)


import Data.JSString (JSString, splitOn, intercalate)
import Data.Monoid ((<>))

import Control.Monad.IO.Class (liftIO)

import WebWorker.WebWorker (WebWorkerIO, getSelf, runWebWorkerIOAction, fetch)
import WebWorker.FetchEvent (FetchEvent, respondWith, getRequest)
import WebWorker.Response (text)
import WebWorker.Promise (Promise, promiseRead, runPromiseM)

-- TODO: Enable once request routing is required. Commenting this out
-- speeds up compilation by not requiring TH
-- import Routing

foreign import javascript unsafe "window.alert($1)" js_alert :: JSString -> IO ()
foreign import javascript unsafe "console.log($1)" console_log :: JSString -> IO ()

-- TODO: Use the GHCJS.DOM.Request version of newRequest. Make a better version of newHeaders
foreign import javascript unsafe "new Request($1)" js_newRequest :: JSString -> IO Request
foreign import javascript unsafe "new Headers($1)" js_newHeaders :: Headers -> IO Headers

-- TODO: Make a better version of new Response
foreign import javascript unsafe "new Response($1, {headers: {'content-type': 'application/json'}})" js_newJSONResponse :: JSString -> IO JSVal

splitComponents :: JSString -> Maybe (JSString, JSString)
splitComponents s = case splitOn "/" s of
  [] -> Nothing
  xs -> Just (intercalate "/" $ init xs, last xs)

dynamicEndpoint :: JSString
dynamicEndpoint = "https://jsonplaceholder.typicode.com/todos/1"

staticEndpoint :: JSString
staticEndpoint = "https://jsonplaceholder.typicode.com/posts/1"

httpGet :: JSString -> WebWorkerIO (Promise JSString)
httpGet url = do
  self <- getSelf
  req <- liftIO $ js_newRequest url
  reqP <- fetch self req
  let p = do
        resp <- promiseRead reqP
        textP <- liftIO $ text resp
        promiseRead textP

  liftIO $ runPromiseM p

dynamicFetchHandler :: FetchEvent -> WebWorkerIO ()
dynamicFetchHandler e = do
  p1 <- httpGet staticEndpoint
  p2 <- httpGet dynamicEndpoint
  let p = do
        text1 <- promiseRead p1
        text2 <- promiseRead p2
        liftIO $ js_newJSONResponse ("[" <> text1 <> "," <> text2 <> "]")

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
