module BackgroundSet ( backgroundSet, getFilesInDirectory, SessionType(..), getSessionType ) where

import System.Process (callCommand)
import System.Random (randomRIO)
import System.Directory (doesDirectoryExist, doesFileExist, listDirectory)
import System.FilePath.Posix ((</>))
import Control.Monad (filterM)

data SessionType 
  = X11 
  | Wayland 
  deriving (Show, Eq)

backgroundSet :: SessionType -> FilePath -> IO (Either String ())
backgroundSet sType filePath = do 
  maybeType <- getPathType filePath
  let setBackend = \type file-> do
    case type of
      Wayland -> callCommand $ "swaybg -i -m fill " ++ file
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
      setBackend sType filepath
      return $ Right ()
    Nothing -> return $ Left $ "Path does not exist: " ++ filePath

getSessionType :: IO SessionType 
getSessionType = do
  type <- lookupEnv "XDG_SESSION_TYPE"
  case type of
    Just "wayland" -> Wayland 
    _              -> X11


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
