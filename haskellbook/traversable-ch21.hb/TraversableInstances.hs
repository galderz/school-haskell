import Control.Applicative
import Test.QuickCheck
import Test.QuickCheck.Checkers
import Test.QuickCheck.Classes


newtype Identity a =
    Identity a
    deriving (Eq, Ord, Show)


newtype Constant a b =
    Constant { getConstant :: a }
    deriving (Eq, Ord, Show)


data Optional a =
    Nada
    | Yep a
    deriving (Eq, Ord, Show)


data List a =
    Nil
    | Cons a (List a)
    deriving (Eq, Ord, Show)


data Three a b c =
    Three a b c
    deriving (Eq, Ord, Show)


data Three' a b =
    Three' a b b
    deriving (Eq, Ord, Show)


data S n a =
    S (n a) a
    deriving (Eq, Ord, Show)


data Tree a =
    Empty
    | Leaf a
    | Node (Tree a) a (Tree a)
    deriving (Eq, Ord, Show)


instance Functor Identity where
    fmap f (Identity x) =
        Identity (f x)


instance Functor (Constant a) where
    fmap _ (Constant a) =
        Constant a


instance Functor Optional where
    fmap _ Nada =
        Nada
    fmap f (Yep x) =
        Yep (f x)


instance Functor List where
    fmap _ Nil =
        Nil
    fmap f (Cons x l) =
        Cons (f x) (fmap f l)


instance Functor (Three a b) where
    fmap f (Three a b x) =
        Three a b (f x)


instance Functor (Three' a) where
    fmap f (Three' a x x')=
        Three' a (f x) (f x')


instance Functor n => Functor (S n) where
    fmap f (S n x) =
        S (fmap f n) (f x)


instance Functor Tree where
    fmap _ Empty =
        Empty
    fmap f (Leaf x) =
        Leaf (f x)
    fmap f (Node t1 x t2) =
        Node (fmap f t1) (f x) (fmap f t2)


instance Foldable Identity where
    foldr f z (Identity x) =
        f x z

    foldMap f (Identity x) =
        f x


instance Foldable (Constant a) where
    foldr f z (Constant a) =
        z

    foldMap f (Constant a) =
        mempty


instance Foldable Optional where
    foldr _ z Nada =
        z
    foldr f z (Yep x) =
        f x z

    foldMap _ Nada =
        mempty
    foldMap f (Yep x) =
        f x


instance Foldable List where
    foldr _ z Nil =
        z
    foldr f z (Cons x l) =
        foldr f (f x z) l

    foldMap _ Nil =
        mempty
    foldMap f (Cons x l) =
        mappend (f x) (foldMap f l)


instance Foldable (Three a b) where
    foldr f z (Three a b x) =
        f x z

    foldMap f (Three a b x) =
        f x


instance Foldable (Three' a) where
    foldr f z (Three' a x x')=
        f x' (f x z)

    foldMap f (Three' a x x') =
        mappend (f x) (f x')


instance Foldable n => Foldable (S n) where
    foldr f z (S na x) =
        f x (foldr f z na)

    foldMap f (S na x) =
        mappend (foldMap f na) (f x)


instance Foldable Tree where
    foldr _ z Empty =
        z
    foldr f z (Leaf x) =
        f x z
    foldr f z (Node t1 x t2) =
        foldr f (f x (foldr f z t1)) t2

    foldMap _ Empty =
        mempty
    foldMap f (Leaf x) =
        f x
    foldMap f (Node t1 x t2) =
        mappend (mappend (foldMap f t1) (f x)) (foldMap f t2)


instance Traversable Identity where
    traverse f (Identity x) =
        fmap Identity (f x)


instance Traversable (Constant a) where
    traverse _ (Constant a) =
        pure (Constant a)


instance Traversable Optional where
    traverse _ Nada =
        pure Nada
    traverse f (Yep x) =
        fmap Yep (f x)


instance Traversable List where
    traverse _ Nil =
        pure Nil
    traverse f (Cons x l) =
        (fmap Cons (f x)) <*> (traverse f l)


instance Traversable (Three a b) where
    traverse f (Three a b x) =
        fmap (Three a b) (f x)


instance Traversable (Three' a) where
    traverse f (Three' a x x') =
        liftA2 (Three' a) (f x) (f x')


instance Traversable n => Traversable (S n) where
    traverse f (S na x)=
        liftA2 S (traverse f na) (f x)


instance Traversable Tree where
    traverse _ Empty =
        pure Empty
    traverse f (Leaf x) =
        fmap Leaf (f x)
    traverse f (Node t1 x t2) =
        liftA3 Node (traverse f t1) (f x) (traverse f t2)

instance (Arbitrary a) => Arbitrary (Identity a) where
    arbitrary =
        do  x <- arbitrary
            return $ Identity x


instance (Arbitrary a, Arbitrary b) => Arbitrary (Constant a b) where
    arbitrary =
        do  x <- arbitrary
            return $ Constant x


instance (Arbitrary a) => Arbitrary (Optional a) where
    arbitrary =
        do  x <- arbitrary
            oneof [ return Nada
                  , return $ Yep x]


instance Arbitrary a => Arbitrary (List a) where
    arbitrary =
        sized arbList


-- Not yet know what "<*>" does exactly, but it's neat :)
arbList :: Arbitrary a => Int -> Gen (List a)
arbList 0 =
    return Nil
arbList n =
    frequency [
        (1, return Nil)
        , (4, fmap Cons arbitrary <*> (arbList (n - 1)))
    ]


instance (Arbitrary a, Arbitrary b, Arbitrary c) => Arbitrary (Three a b c) where
    arbitrary =
        do  x <- arbitrary
            y <- arbitrary
            z <- arbitrary
            return $ Three x y z


instance (Arbitrary a, Arbitrary b) => Arbitrary (Three' a b) where
    arbitrary =
        do  x <- arbitrary
            y <- arbitrary
            y' <- arbitrary
            return $ Three' x y y'


instance (Arbitrary a, Arbitrary (n a)) => Arbitrary (S n a) where
    arbitrary =
        liftA2 S arbitrary arbitrary


instance Arbitrary a => Arbitrary (Tree a) where
    arbitrary =
        sized arbTree


-- Not yet know what "<*>" does exactly, but it's neat :)
arbTree :: Arbitrary a => Int -> Gen (Tree a)
arbTree 0 =
    return Empty
arbTree n =
    frequency [
        (1, return Empty)
        , (1, fmap Leaf arbitrary)
        , (2, liftA3 Node (arbTree (n - 1)) arbitrary (arbTree (n -1)))
    ]


instance (Eq a) => EqProp (Identity a) where
    (=-=) =
        eq


instance (Eq a, Eq b) => EqProp (Constant a b) where
    (=-=) =
        eq


instance (Eq a) => EqProp (Optional a) where
    (=-=) =
        eq


instance (Eq a) => EqProp (List a) where
    (=-=) =
        eq


instance (Eq a, Eq b, Eq c) => EqProp (Three a b c) where
    (=-=) =
        eq


instance (Eq a, Eq b) => EqProp (Three' a b) where
    (=-=) =
        eq


instance (Eq a, Eq (n a)) => EqProp (S n a) where
    (=-=) =
        eq


instance (Eq a) => EqProp (Tree a) where
    (=-=) =
        eq


type TI =
    Identity


type TC =
    Constant


type TO =
    Optional


type TL =
    List


type TH =
    Three


type TH' =
    Three'


type TR =
    Tree


main :: IO ()
main =
    do  let
            ti =
                undefined :: TI (Int, Int, [Int])
            tc =
                undefined :: TC (Int, Int, [Int]) (Int, Int, [Int])
            to =
                undefined :: TO (Int, Int, [Int])
            tl =
                undefined :: TL (Int, Int, [Int])
            tt =
                undefined :: TH (Int, Int, [Int]) (Int, Int, [Int]) (Int, Int, [Int])
            tt' =
                undefined :: TH' (Int, Int, [Int]) (Int, Int, [Int])
            ts =
                undefined :: S [] (Int, Int, [Int])
            tr =
                undefined :: TR (Int, Int, [Int])
        -- quickBatch (functor ti)
        -- quickBatch (traversable ti)
        -- quickBatch (functor tc)
        -- quickBatch (traversable tc)
        -- quickBatch (functor to)
        -- quickBatch (traversable to)
        -- quickBatch (functor tl)
        -- quickBatch (traversable tl)
        -- quickBatch (functor tt)
        -- quickBatch (traversable tt)
        -- quickBatch (functor tt')
        -- quickBatch (traversable tt')
        -- quickBatch (functor ts)
        -- quickBatch (traversable ts)
        -- quickBatch (functor tr)
        quickBatch (traversable tr)
