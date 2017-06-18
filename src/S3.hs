{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}

module S3 where

import           Control.Lens
import           Control.Monad
import           Control.Monad.IO.Class
import qualified Data.Conduit.Binary as CB
import qualified Data.Text as T
import           Network.AWS
import           Network.AWS.S3
import           System.IO

import           Errors
import           Utils

load :: [String] -> IO ()
load [fileName] = do
    log <- newLogger Debug stdout
    env <- newEnv Discover <&> set envLogger log
    let dst = (BucketName "donair-safe", ObjectKey $ T.pack fileName)

    runResourceT . runAWS env $ do
        rs <- send $ getObject (fst dst) (snd dst)
        view gorsBody rs `sinkBody` CB.sinkFile fileName
        liftIO . putStrLn $ "done"
load [] = Errors.die "Please provide a filename to load"

save :: [String] -> IO ()
save [fileName] = do
    log <- newLogger Debug stdout
    env <- newEnv Discover <&> set envLogger log
    body <- toBody <$> hashedFile fileName
    let dst = (BucketName "donair-safe", ObjectKey $ T.pack fileName)

    runResourceT . runAWS env $ do
        void . send $ putObject (fst dst) (snd dst) body
        liftIO . putStrLn $ "done"
save [] = Errors.die "Please provide a filename to load"
