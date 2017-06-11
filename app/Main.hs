import System.Environment
import System.Exit
import System.Directory
import System.IO

import S3
import Errors

dispatch :: [(String, [String] -> IO ())]
dispatch =  [ ("load", S3.load)
            , ("save", S3.save)
            , ("view", view)
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

view :: [String] -> IO ()
view [fileName] = do
    contents <- readFile fileName
    putStr contents
view [] = do
    Errors.die "Please provide a filename"

exit :: IO ()
exit = exitWith ExitSuccess
