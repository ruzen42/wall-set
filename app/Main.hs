module Main ( main ) where

import BackgroundSet (backgroundSet, getFilesInDirectory)
import Options.Applicative
import System.Exit (exitFailure)
import Control.Monad (when, mapM_)

data Command
  = Set FilePath  
  | List FilePath
  deriving (Show)

data Options = Options
  { optCommand :: Command
  , optVerbose :: Bool
  } deriving (Show)

setParser :: Parser Command
setParser = Set <$> argument str (metavar "PATH" <> help "Path to file or directory")

listParser :: Parser Command
listParser = List <$> argument str (metavar "PATH" <> help "Path to directory to list")

commandParser :: Parser Command
commandParser = subparser
  ( command "set" (info setParser (progDesc "Set background, background-set set image.png"))
  <> command "list" (info listParser (progDesc "List available backgrounds, background-set list images"))
  )

optionsParser :: Parser Options
optionsParser = Options
  <$> commandParser
  <*> switch (long "verbose" <> short 'v' <> help "Enable verbose output")

main :: IO ()
main = do
  opts <- execParser (info (optionsParser <**> helper) fullDesc)
  
  case optCommand opts of
    Set path -> do
      when (optVerbose opts) $ putStrLn $ "Setting background from: " ++ path
      result <- backgroundSet path
      case result of
        Right () -> when (optVerbose opts) $ putStrLn "Background set successfully!"
        Left err -> putStrLn ("Error: " ++ err) >> exitFailure
    
    List path -> do
      when (optVerbose opts) $ putStrLn $ "Listing backgrounds in: " ++ path
      maybeFiles <- getFilesInDirectory path
      case maybeFiles of
        Nothing    -> putStrLn "No files found or doesn't exist"
        Just files -> mapM_ putStrLn files
