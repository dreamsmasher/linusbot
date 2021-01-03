{-# LANGUAGE OverloadedStrings #-}
module Main where

import Lib
import Data.Maybe
import Web.Scotty.Trans as S
import Network.HTTP.Types
import Control.Monad.Trans.Reader
import System.Environment
import Data.Bool (bool)

isProd :: IO Bool
isProd = (/= Nothing) <$> lookupEnv "LINUS_ENV" 

main :: IO ()
main = do 
    defPort <- bool 3000 80 <$> isProd
    port <- fromMaybe defPort . fmap read <$> lookupEnv "PORT" -- heroku stuff
    rants <- load
    scottyT port (`runReaderT` rants) $ do
        get "/rants" handleGet
        notFound $ S.text "make a GET request to /rants to hear from Linus!" >> status status400
