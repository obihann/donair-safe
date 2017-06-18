{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}

module Utils where

import           Data.Monoid
import qualified Data.Text as T
import           Network.AWS.S3
import           Network.URI

parseS3URI :: String -> Either String (BucketName, ObjectKey)
parseS3URI s3u = do
    -- bind all fields from the URI record
    URI{..} <- case parseURI s3u
                of Nothing -> Left $ "Failed to parse " <> s3u
                   Just a -> Right a

    -- if we don't have an s3 schema why even bother
    _ <- if uriScheme == "s3:"
        then Right ()
        else Left $ "Expected s3: URI scheme"

    URIAuth{..} <- case uriAuthority
        of Nothing -> Left $ "Expected authority part in an s3 uri, got " <> s3u
           Just a -> Right a

    objKey <- if null uriPath
              then Left $ "URI path must not be empty (object key part) in " <> s3u
              else Right . T.tail . T.pack $ uriPath
    
    return (BucketName .T.pack $ uriRegName, ObjectKey objKey)
