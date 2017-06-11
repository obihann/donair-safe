{-# LANGUAGE OverloadedStrings #-}

module S3 where

import qualified Aws
import qualified Aws.S3 as S3
import           Data.Conduit (($$+-))
import           Data.Conduit.Binary (sinkFile)
import           Network.HTTP.Conduit (withManager, responseBody)
{-import Control.Monad.Trans.Resource (runResourceT) -}
{-import           Network.HTTP.Conduit-}
import Data.Text (pack)
import Errors

load :: [String] -> IO ()
load [fileName] = do
    {-text <- getContents-}
    {-contents <- readFile fileName-}
    {-let todoTasks = lines contents-}
        {-numberedTasks = zipWith (\n line -> show n ++ " - " ++ line) [0..] todoTasks-}
    {-putStr $ unlines numberedTasks-}
    {-concat `fmap` mapM readFile fs-}
    cfg <- Aws.baseConfiguration
    let s3cfg = Aws.defServiceConfig :: S3.S3Configuration Aws.NormalQuery

    withManager $ \mgr -> do
        S3.GetObjectResponse { S3.gorResponse = rsp } <-
            Aws.pureAws cfg s3cfg mgr $
                S3.getObject "donair-safe" (pack fileName)

        responseBody rsp $$+- sinkFile "cloud-secret.txt"
load [] = do
    Errors.die "Please provide a filename to load"

