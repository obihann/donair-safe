{-# LANGUAGE OverloadedStrings #-}

module S3 where

import qualified Aws
import qualified Aws.S3 as S3
import           Data.Conduit (($$+-))
import           Data.Conduit.Binary (sinkFile)
import           Network.HTTP.Conduit (withManager, responseBody, RequestBody(..))
import Data.Text (pack)
import Control.Monad.IO.Class
import qualified Data.Text as T
import qualified Data.ByteString.Lazy as L
import qualified Data.ByteString as S
import System.Posix.Files
import System.IO
import Errors

bucket = "donair-safe"

load :: [String] -> IO ()
load [fileName] = do
    cfg <- Aws.baseConfiguration
    let s3cfg = Aws.defServiceConfig :: S3.S3Configuration Aws.NormalQuery

    withManager $ \mgr -> do
        S3.GetObjectResponse { S3.gorResponse = rsp } <-
            Aws.pureAws cfg s3cfg mgr $
                S3.getObject bucket (pack fileName)

        responseBody rsp $$+- sinkFile fileName
load [] = Errors.die "Please provide a filename to load"

save :: [String] -> IO ()
save [fileName] = do
    cfg <- Aws.baseConfiguration
    let s3cfg = Aws.defServiceConfig :: S3.S3Configuration Aws.NormalQuery

    withManager $ \mgr -> do
        let streamer sink = withFile fileName ReadMode $ \h -> sink $ S.hGet h 10240
        b <- liftIO $ L.readFile fileName
        size <- liftIO $ (fromIntegral . fileSize <$> getFileStatus fileName :: IO Integer)
        let body = RequestBodyStream (fromInteger size) streamer
        rsp <- Aws.pureAws cfg s3cfg mgr $
            (S3.putObject bucket (T.pack fileName) body)
                { S3.poMetadata =
                    [ ("mediatype", "texts")
                    , ("meta-description", "test Internet Archive item made via haskell aws library")
                    ]
                , S3.poAutoMakeBucket = True
                }
        liftIO $ print rsp
save [] = Errors.die "Please provide a filename to load"
