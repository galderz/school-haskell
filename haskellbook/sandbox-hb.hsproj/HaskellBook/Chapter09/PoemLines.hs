module HaskellBook.Chapter09.PoemLines where

mySplit :: String -> Char -> [String]
mySplit "" _ = 
    []
mySplit s ch = 
    word : (mySplit rest ch)
    where word = 
            takeWhile (/=ch) s
          rest = 
            dropWhile (==ch) (dropWhile (/=ch) s)


myWords :: String -> [String]
myWords s =
    mySplit s ' '


--myWords :: String -> [String]
--myWords "" = 
--    []
--myWords s = 
--    word : (myWords rest)
--    where word = 
--            takeWhile (/=' ') s
--          rest = 
--            dropWhile (==' ' ) (dropWhile (/=' ') s)


-- Book solution
myWords' :: String -> [String]
myWords' [] = []
myWords' (' ':xs) = myWords' xs
myWords' xs =
  takeWhile (/= ' ') xs : 
    myWords' (dropWhile (/= ' ') xs)


firstSen = "Tyger Tyger, burning bright\n"


secondSen = "In the forests of the night\n"


thirdSen = "What immortal hand or eye\n"


fourthSen = "Could frame thy fearful symmetry?"
sentences = firstSen ++ secondSen
  ++ thirdSen ++ fourthSen
-- Tyger Tyger, burning bright
-- In the forests of the night
-- What immortal hand or eye
-- Could frame thy fearful symmetry?
-- Implement this
myLines :: String -> [String]
myLines s =
    mySplit s '\n'

--myLines :: String -> [String]
--myLines "" = []
--myLines s = word : (myLines rest)
--  where word = takeWhile (/='\n') s
--        rest = dropWhile (=='\n' ) (dropWhile (/='\n') s)


shouldEqual = 
  ["Tyger Tyger, burning bright"
  , "In the forests of the night"
  , "What immortal hand or eye"
  , "Could frame thy fearful symmetry?"
  ]
--main :: IO ()
--main = print $ "Are they equal? "
--  ++ show (myLines sentences == shouldEqual)
              