import System.Environment
import System.Exit
import System.Directory
import System.IO

import S3
import Errors

dispatch :: [(String, [String] -> IO ())]
dispatch =  [ ("load", S3.load)
            , ("save", S3.save)
            , ("encrypt", S3.encrypt)
            , ("help", help)
            , ("version", version)
            ]

main :: IO ()
main = do
    (command:args) <- getArgs
    let (Just action) = lookup command dispatch
    action args

help :: [String] -> IO ()
help [] = putStrLn "Usage: donair [add|load|remove|help|version]"

version :: [String] -> IO ()
version [] = putStrLn "Donair Safe 0.0.1"

exit :: IO ()
exit = exitWith ExitSuccess
