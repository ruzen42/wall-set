module Main where

import BackgroundSet (backgroundSet)
import Options.Applicative
import System.Exit (exitFailure)
import Control.Monad (when)

data Options = Options
  { optPath :: FilePath  
  , optVerbose :: Bool  
  } deriving (Show)

optionsParser :: Parser Options
optionsParser = Options
  <$> argument str (metavar "PATH" <> help "Path to file or directory with backgrounds")
  <*> switch (long "verbose" <> short 'v' <> help "Enable verbose output")

programInfo :: ParserInfo Options
programInfo = info (optionsParser <**> helper)
  ( fullDesc
  <> progDesc "Set random background from directory or specific file"
  <> header "background-set - utility for setting desktop backgrounds" )

main :: IO ()
main = do
  opts <- execParser programInfo
  let path = optPath opts
      verbose = optVerbose opts
  
  when verbose $ putStrLn $ "Processing path: " ++ path
  
  result <- backgroundSet path
  
  case result of
    Right () -> when verbose $ putStrLn "Background set successfully!"
    Left err -> do
      putStrLn $ "Error: " ++ err
      exitFailure
