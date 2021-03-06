{-# OPTIONS_GHC -fno-warn-type-defaults #-}
module ReaderPractice where

import Control.Applicative
import Data.Maybe


x :: [Integer]
x =
    [1, 2, 3]


y :: [Integer]
y =
    [4, 5, 6]


z :: [Integer]
z =
    [7, 8, 9]


-- lookup :: Eq a => a -> [(a, b)] -> Maybe b
-- lookup x l =
--     fmap snd found
--     where
--         found = find (\(a, b) -> if (a == x) then True else False) l


-- zip x and y using 3 as the lookup key
xs :: Maybe Integer
xs =
    lookup 3 $ zip x y


-- zip y and z using 6 as the lookup key
ys :: Maybe Integer
ys =
    lookup 6 $ zip y z


-- it's also nice to have one tha
-- will return Nothing, like this one
-- zip x and y using 4 as the lookup key
zs :: Maybe Integer
zs =
    lookup 4 $ zip x y


-- now zip x and z using a variable lookup key
z' :: Integer -> Maybe Integer
z' n =
    lookup n $ zip x z


x1 :: Maybe (Integer, Integer)
x1 =
    liftA2 (,) xs ys
    -- (fmap (,) xs) <*> ys
    -- (,) <$> xs <*> ys


x2 :: Maybe (Integer, Integer)
x2 =
    liftA2 (,) ys zs


x3 :: Integer -> (Maybe Integer, Maybe Integer)
x3 n =
    (z' n, z' n)


summed :: Num c => (c, c) -> c
summed =
    uncurry (+)


bolt :: Integer -> Bool
bolt =
    liftA2 (&&) (>3) (<8)


sequA :: Integral a => a -> [Bool]
sequA m =
    sequenceA [(>3), (<8), even] m


s' :: Maybe Integer
s' =
    summed <$> ((,) <$> xs <*> ys)


main :: IO ()
main =
    do  print $ xs
        print $ ys
        print $ zs
        print $ z' 2
        print $ z' 5
        print $ x1
        print $ x2
        print $ x3 3
        print $ summed (0, 0)
        print $ summed (1, 2)
        print $ bolt 7
        print $ bolt 2
        print $ bolt 8
        print $ fromMaybe 0 xs
        print $ fromMaybe 0 zs
        print $ sequenceA [Just 3, Just 2, Just 1]
        print $ sequenceA [x, y]
        print $ sequenceA [xs, ys]
        print $ summed <$> ((,) <$> xs <*> ys)
        print $ fmap summed ((,) <$> xs <*> zs)
        print $ bolt 7
        print $ fmap bolt z
        -- sequenceA :: (Applicative f, Traversable t) => t (f a) -> f (t a)
        -- -- f ~ (->) a, and t ~ []
        -- so, you end up calling f (t a) with 7
        print $ sequenceA [(>3), (<8), even] 7
        print $ foldr (&&) True (sequA 7)
        print $ foldr (&&) True (sequA 6)
        print $ sequA (fromMaybe 0 s')
        print $ bolt (fromMaybe 0 ys)
