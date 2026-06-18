{-# LANGUAGE BlockArguments           #-}
{-# LANGUAGE NondecreasingIndentation #-}

module BackgroundSet ( backgroundSet, getFilesInDirectory, SessionType(..), getSessionType ) where

import System.Process (callCommand)
import System.Random (randomRIO)
import System.Directory (doesDirectoryExist, doesFileExist, listDirectory)
import System.Environment (lookupEnv)
import System.FilePath.Posix ((</>))
import Control.Monad (filterM)

data SessionType 
  = X11 
  | Wayland 
  deriving (Show, Eq)

backgroundSet :: SessionType -> FilePath -> IO (Either String ())
backgroundSet sType filePath = do 
  maybeType <- getPathType filePath
  let setBackend = \s file -> case s of
        Wayland -> callCommand $ "swaybg -i " ++ file ++ " -m fill " 
        X11     -> callCommand $ "feh --bg-fill" ++ file

  case maybeType of
    Just "Directory" -> do
      maybeFiles <- getFilesInDirectory filePath
      case maybeFiles of
        Nothing -> return $ Left $ "Directory is empty: " ++ filePath
        Just files -> do
          background <- selectRandom files
          setBackend sType background
          return $ Right ()
    Just "File" -> do
      setBackend sType filePath
      return $ Right ()
    Nothing -> return $ Left $ "Path does not exist: " ++ filePath

getSessionType :: IO SessionType 
getSessionType = do
  s <- lookupEnv "XDG_SESSION_TYPE"
  case s of
    Just "wayland" -> pure Wayland 
    _              -> pure X11


getPathType :: FilePath -> IO (Maybe String)
getPathType path = do
    isDir <- doesDirectoryExist path
    isFile <- doesFileExist path
    case (isDir, isFile) of
        (True, _) -> return $ Just "Directory"
        (_, True) -> return $ Just "File"
        _ -> return Nothing

selectRandom :: [a] -> IO a
selectRandom [] = error "Empty list provided to selectRandom"
selectRandom backgrounds = do 
  let len = length backgrounds
  index <- randomRIO (0, len - 1)
  return $ backgrounds !! index

getFilesInDirectory :: FilePath -> IO (Maybe [FilePath])
getFilesInDirectory dir = do
  exists <- doesDirectoryExist dir
  if not exists
    then return Nothing
    else do
      allItems <- listDirectory dir
      if null allItems
        then return Nothing  
        else do
          let fullPaths = map (dir </>) allItems
          files <- filterM doesFileExist fullPaths
          if null files
            then return Nothing  
            else return $ Just files
