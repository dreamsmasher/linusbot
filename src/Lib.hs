{-# LANGUAGE OverloadedStrings, LambdaCase, TemplateHaskell #-}
module Lib where

import qualified Data.ByteString.Lazy as B
import Control.Monad
import Data.Aeson.TH ( deriveJSON, defaultOptions )
import Data.Aeson ( defaultOptions, decode )
import Data.Text.Lazy ( Text )
import Data.Array ((!))
import qualified Data.Array as A
import Web.Scotty.Trans as S
import Control.Monad.IO.Class ( MonadIO(liftIO) )
import Control.Monad.Trans.Reader ( ReaderT(runReaderT), ask )
import Control.Monad.Trans.Class ( MonadTrans(lift) )
import Network.HTTP.Types ( status200, status400 )
import System.Random ( getStdRandom, Random(randomR) )

data Rant = Rant { rant :: String
                 , hate :: Double
                 } deriving (Eq, Show)
                 
deriveJSON defaultOptions ''Rant

type Rants = A.Array Int Rant
type Linus a = ActionT Text (ReaderT Rants IO) a
type LinusM a = ScottyT Text (ReaderT Rants IO) a

dataPath :: FilePath
dataPath = "data/data.json"

rantBounds :: (Int, Int)
rantBounds = (0, 311)
-- length of the rants data set

getIndex :: Linus Int
getIndex = liftIO (getStdRandom $ randomR rantBounds)

getRant :: Linus Rant
getRant = liftM2 (!) (lift ask) getIndex

load :: IO Rants
load = B.readFile dataPath >>= maybe (error "couldn't load") (pure . A.listArray rantBounds) . decode 

handleGet :: Linus ()
handleGet = do
    count <- min 175 <$> param "count" `rescue` (pure . const 1) 
    replicateM count getRant >>= S.json >> status status200
    
