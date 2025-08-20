module BackgroundSet ( backgroundSet ) where

import System.Process (callCommand)
import System.Random (randomRIO)
import System.Directory (doesDirectoryExist, doesFileExist, listDirectory)
import System.FilePath.Posix ((</>))
import Control.Monad (filterM)

backgroundSet :: FilePath -> IO (Either String ())
backgroundSet filePath = do 
  maybeType <- getPathType filePath
  case maybeType of
    Just "Directory" -> do
      maybeFiles <- getFilesInDirectory filePath
      case maybeFiles of
        Nothing -> return $ Left $ "Directory is empty: " ++ filePath
        Just files -> do
          background <- selectRandom files
          callCommand $ "/usr/bin/feh --bg-center " ++ background 
          return $ Right ()
    Just "File" -> do
      callCommand $ "/usr/bin/feh --bg-center " ++ filePath
      return $ Right ()
    Nothing -> return $ Left $ "Path does not exist: " ++ filePath

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
