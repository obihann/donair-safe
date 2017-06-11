module Errors where

import System.Exit

die :: String -> IO ()
die (msg) = do
    putStrLn msg
    exitWith (ExitFailure 1)
