module KMS where

import Control.Lens
import Network.AWS.Data
import Network.AWS.S3
import System.IO
import Errors

encrypt :: [String] -> IO ()
encrypt [] = Errors.die "Please provide a filename to encrypt"
encrypt [fileName] = Errors.die "Please provide an encryption key"
