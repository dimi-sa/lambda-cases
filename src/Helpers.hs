module Helpers where

import System.Directory
import Control.Applicative
import Control.Monad.State
import Data.List.Split

-- types
type Lcases = String
type ProgramFileName = FileName
type ProgramStr = String
type FileName = String
type HsFileName = String
type FileString = String
type TestExample = String

-- paths
grules_dir :: FilePath
grules_dir = "grammar_rules/"

in_dir :: FilePath
in_dir = "test/inputs/"

out_dir :: FilePath
out_dir = "test/outputs/"

-- func app/comp
(.>) :: (a -> b) -> (b -> c) -> a -> c
(.>) = flip (.)

(&>) :: a -> (a -> b) -> b
(&>) = flip ($)

-- Functor
mapf :: Functor f => f a -> (a -> b) -> f b
mapf = flip fmap

(>$>) :: Functor f => f a -> (a -> b) -> f b
(>$>) = flip fmap

(<++) :: Functor f => f [a] -> [a] -> f [a]
fas <++ as = (++ as) <$> fas

(++>) :: Functor f => [a] -> f [a] -> f [a]
as ++> fas = (as ++) <$> fas

-- Applicative
nothing :: Applicative f => f ()
nothing = pure ()

(++<) :: Applicative f => f a -> f b -> f (a, b)
pa ++< pb = liftA2 (,) pa pb

(+++<) :: Applicative f => f (a, b) -> f c -> f (a, b, c)
pab +++< pc = liftA2 (\(a, b) -> (,,) a b) pab pc

(++++<) :: Applicative f => f (a, b, c) -> f d -> f (a, b, c, d)
pabc ++++< pd = liftA2 (\(a, b, c) -> (,,,) a b c) pabc pd

(>:<) :: Applicative f => f a -> f [a] -> f [a]
a >:< as = liftA2 (:) a as

(>++<) :: Applicative f => f [a] -> f [a] -> f [a]
fas1 >++< fas2 = liftA2 (++) fas1 fas2

-- other
ind_lvl_to_spaces :: Int -> String
ind_lvl_to_spaces = \i -> replicate (2 * i) ' '

make_extension_hs :: FileName -> FileName
make_extension_hs = takeWhile (/= '.') .> (++ ".hs")

read_exs_file :: FileName -> IO FileString
read_exs_file = \file_name -> readFile $ in_dir ++ grules_dir ++ file_name

read_examples :: FileName -> IO [FileString]
read_examples = \file_name -> read_exs_file file_name >$> file_str_to_examples

file_str_to_examples :: FileString -> [ TestExample ]
file_str_to_examples = endBy "#\n\n"

do_nothing :: Monad m => m ()
do_nothing = return ()

-- ASTTypes.hs
-- Test.hs
