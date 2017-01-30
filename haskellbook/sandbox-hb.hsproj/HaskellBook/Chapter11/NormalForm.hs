module HaskellBook.Chapter11.NormalForm where
  

data Fiction = Fiction deriving Show


data Nonfiction = Nonfiction deriving Show


data BookType = 
    FictionBook Fiction
    

type AuthorName = String


data Author = Author (AuthorName, BookType)


-- After applying distributive property of:
-- a * (b + c) -> (a * b) + (a * c)


-- In normal form:
data Author' =
    Fiction' AuthorName
    | Nonfiction' AuthorName deriving (Eq, Show)    
    

-- Already in normal form
data Expr =


data FlowerType = 
    Gardenia

type Gardener = String

data Garden =
  
-- Normal form:

data Garden' =
  | Daisy' Gardener
  | Rose' Gardener
  | Lilac' Gardener
  deriving Show



