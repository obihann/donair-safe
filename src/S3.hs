{-# LANGUAGE OverloadedStrings #-}

module S3 where

import Data.Text (pack)
import Control.Lens
import Network.AWS
import Network.AWS.S3
import System.IO
import Errors

bucket = "donair-safe"

load :: [String] -> IO ()
{-load [fileName] = do-}
    {-cfg <- Aws.baseConfiguration-}
    {-let s3cfg = Aws.defServiceConfig :: S3.S3Configuration Aws.NormalQuery-}

    {-withManager $ \mgr -> do-}
        {-S3.GetObjectResponse { S3.gorResponse = rsp } <--}
            {-Aws.pureAws cfg s3cfg mgr $-}
                {-S3.getObject bucket (pack fileName)-}

        {-responseBody rsp $$+- sinkFile fileName-}
load [] = Errors.die "Please provide a filename to load"

save :: [String] -> IO ()
save [fileName] = do
    env <- newEnv Discover
    log <- newLogger Debug stdout
    body <- toBody <$> hashedFile fileName

    let bucketName = BucketName "donair-safe"
    let objectKey = ObjectKey $ pack fileName

    runResourceT . runAWS (env & envLogger .~ log) $
        send (putObject bucketName objectKey body)

    putStrLn "done"

save [] = Errors.die "Please provide a filename to load"
