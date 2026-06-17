module Main ( main ) where

import BackgroundSet (backgroundSet, getSessionType)
import Options.Applicative
import System.Exit (exitFailure)
import Control.Monad (when)

data Options = Options
  { optPath    :: FilePath
  , optVerbose :: Bool
  } deriving (Show)

optionsParser :: Parser Options
optionsParser = Options
  <$> argument str (metavar "PATH" <> help "Path to file or directory for background")
  <*> switch (long "verbose" <> short 'v' <> help "Enable verbose output")

main :: IO ()
main = do
  opts <- execParser (info (optionsParser <**> helper) fullDesc)

  session <- getSessionType 
  
  let path = optPath opts
  when (optVerbose opts) $ putStrLn $ "Setting background from: " ++ path
  
  result <- backgroundSet session path
  case result of
    Right () -> when (optVerbose opts) $ putStrLn "Background set successfully!"
    Left err -> putStrLn ("Error: " ++ err) >> exitFailure
