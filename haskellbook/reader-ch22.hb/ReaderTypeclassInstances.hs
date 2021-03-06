-- you'll need this pragma
{-# LANGUAGE InstanceSigs #-}

module ApplicativeOfFunctionsExercise where

-- import Test.QuickCheck
-- import Test.QuickCheck.Checkers
-- import Test.QuickCheck.Classes


myLiftA2 :: Applicative f =>
    (a -> b -> c)
    -> f a -> f b -> f c
myLiftA2 f fa fb =
    f <$> fa <*> fb


newtype Reader r a =
    Reader { runReader :: r -> a }
    -- deriving (Eq, Ord, Show)


asks :: (r -> a) -> Reader r a
asks f =
    Reader f


instance Functor (Reader r) where
    fmap f (Reader r) =
        Reader (f . r)


instance Applicative (Reader r) where
    pure :: a -> Reader r a
    pure a =
        Reader $ (\r -> a)

    (<*>) :: Reader r (a -> b) -> Reader r a -> Reader r b
    (<*>) (Reader f) (Reader ra) =
        Reader $ \r -> (f r) (ra r)


instance Monad (Reader r) where
    return =
        pure

    (>>=) :: Reader r a -> (a -> Reader r b) -> Reader r b
    (>>=) (Reader ra) aRb =
        Reader $ \r -> runReader (aRb (ra r)) r


-- type TR =
--     Reader


-- main :: IO ()
-- main =
--     do  let
--             tr = undefined :: TR (Int, Int, [Int]) (Int, Int,)
--         quickBatch (functor tr)
