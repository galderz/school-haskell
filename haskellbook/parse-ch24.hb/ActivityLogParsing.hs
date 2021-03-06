{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

import Control.Applicative
import Data.ByteString (ByteString)
import Data.Char (digitToInt)
import Test.Hspec
import Text.RawString.QQ
import Text.Trifecta


-- aka area code
type Date =
    String


type Activities =
    [Activity]


type Activity =
    (Time, Description)


type Time =
    Int


type Description =
    String


type History =
    [(Date, Activities)]


data Log =
    Log History Int
    deriving (Eq, Show)


skipWhitespace :: Parser ()
skipWhitespace =
    skipMany (char ' ' <|> char '\n')


-- | Skip end of line and
--   whitespace beyond.
skipEOL :: Parser ()
skipEOL =
    skipMany (oneOf "\n")


skipComments :: Parser ()
skipComments =
    skipMany (
    do  _ <- string "--"
        skipMany (noneOf "\n")
        skipEOL)


parseDate :: Parser Date
parseDate =
    do  skipMany (noneOf "#")
        _ <- char '#'
        skipMany (oneOf " ")
        y1 <- digit
        y2 <- digit
        y3 <- digit
        y4 <- digit
        _ <- char '-'
        m1 <- digit
        m2 <- digit
        _ <- char '-'
        d1 <- digit
        d2 <- digit
        skipMany (noneOf "\n")
        skipEOL -- important!
        return (y1 : y2 : y3 : y4 : '-' : m1 : m2 : '-' : d1 : d2 : [])


stringToInt :: String -> Int
stringToInt s =
    foldl (\z x -> (z * 10) + digitToInt x) 0 s


parseTime :: Parser Time
parseTime =
    do  h1 <- digit
        h2 <- digit
        _ <- char ':'
        m1 <- digit
        m2 <- digit
        return $ (100 * stringToInt (h1 : h2 : []))
            + (stringToInt (m1 : m2 : []))


parseActivity :: Parser Activity
parseActivity =
    do  time <- parseTime
        _ <- char ' '
        desc <- try
            (manyTill (noneOf "\n") comment)
            <|> many (noneOf "\n")
        skipOptional skipRestOfLine
        return (time, desc)


skipRestOfLine :: Parser ()
skipRestOfLine =
    skipMany (noneOf "\n") >> skipOptional (char '\n') >> return ()


comment :: Parser String
comment =
    try (someSpace >> string "--") <|> string "--"


parseActivities :: Parser Activities
parseActivities =
    do  activities <- some parseActivity
        return activities


parseDateActivities :: Parser (Date, Activities)
parseDateActivities =
    do  date <- parseDate
        activities <- parseActivities
        return (date, activities)


parseHistory :: Parser History
parseHistory =
    do  history <- some parseDateActivities
        return history


parseLog :: Parser Log
parseLog =
    do  skipWhitespace
        skipComments
        history <- parseHistory
        return $ Log history 0


maybeSuccess :: Result a -> Maybe a
maybeSuccess (Success a) =
    Just a
maybeSuccess _ =
    Nothing


sumActivities :: Activities -> Int
sumActivities as =
    toMins $ fst (foldl sumActivityWithPrev (0, 0) as)


sumActivityWithPrev :: (Int, Int) -> (Int, String) -> (Int, Int)
sumActivityWithPrev z x =
    (fst z + cnt (fst x) (snd z), fst x)
    where
        cnt x' z' =
            if (z' == 0) then 0
            else (x' - z')


toMins :: Int -> Int
toMins x =
    let
        dm = divMod x 100
    in
        ((fst dm) * 60) + snd dm


avgActivities :: Activities -> Double
avgActivities as =
    fromIntegral ((sumActivities as)) / (fromIntegral ((length as) - 1))


main :: IO ()
main =
    hspec $
    do
        describe "Activity averaging: " $ do
            it "can avg time in a 1h activity" $ do
                let as =
                        [ (800, "Breakfast")
                        , (900, "Sanitizing moisture collector")
                        ]
                avgActivities as `shouldBe` 60.0
            it "can avg time in a two 1h activities" $ do
                let as =
                        [ (800, "Breakfast")
                        , (900, "Sanitizing moisture collector")
                        , (1000, "Exercising")
                        ]
                avgActivities as `shouldBe` 60.0
            it "can avg time in multiple activities" $ do
                let as =
                        [ (800, "Breakfast")
                        , (900, "Sanitizing moisture collector")
                        , (1100, "Exercising in high-grav gym")
                        , (1730, "R&R")
                        ]
                avgActivities as `shouldBe` 190.0
        describe "Activity summing: " $ do
            it "can count time in a 1h activity" $ do
                let as =
                        [ (800, "Breakfast")
                        , (900, "Sanitizing moisture collector")
                        ]
                sumActivities as `shouldBe` 60
            it "can count time in a 1h30m activity" $ do
                let as =
                        [ (800, "Breakfast")
                        , (930, "Sanitizing moisture collector")
                        ]
                sumActivities as `shouldBe` 90
            it "can count time in a two 1h activities" $ do
                let as =
                        [ (800, "Breakfast")
                        , (900, "Sanitizing moisture collector")
                        , (1000, "Exercising")
                        ]
                sumActivities as `shouldBe` 120
            it "can count time in multiple activities" $ do
                let as =
                        [ (800, "Breakfast")
                        , (900, "Sanitizing moisture collector")
                        , (1100, "Exercising in high-grav gym")
                        , (1730, "R&R")
                        ]
                sumActivities as `shouldBe` 570
        describe "Log parsing:" $ do
            it "can parse a full log" $ do
                let p =
                        parseLog
                    i =
                        sampleLog
                    m =
                        parseByteString p mempty i
                    r' =
                        maybeSuccess m
                print m
                r' `shouldBe` Just (
                    Log [
                            ("2025-02-05",
                             [
                                 (800, "Breakfast")
                                 , (900, "Sanitizing moisture collector")
                                 , (1100, "Exercising in high-grav gym")
                                 , (1200, "Lunch")
                                 , (1300, "Programming")
                                 , (1700, "Commuting home in rover")
                                 , (1730, "R&R")
                                 , (1900, "Dinner")
                                 , (2100, "Shower")
                                 , (2115, "Read")
                                 , (2200, "Sleep")
                             ])
                            , ("2025-02-07",
                               [
                                   (800, "Breakfast")
                                   , (900, "Bumped head, passed out")
                                   , (1336, "Wake up, headache")
                                   , (1337, "Go to medbay")
                                   , (1340, "Patch self up")
                                   , (1345, "Commute home for rest")
                                   , (1415, "Read")
                                   , (2100, "Dinner")
                                   , (2115, "Read")
                                   , (2200, "Sleep")
                               ])
                        ] 0
                    )

        describe "Comment parsing:" $ do
            it "skips comment before date" $ do
                let p =
                        skipComments >> parseDate
                    i =
                        "-- wheee a comment\n\n# 2025-02-05"
                    m =
                        parseByteString p mempty i
                    r' =
                        maybeSuccess m
                print m
                r' `shouldBe` Just "2025-02-05"

        describe "Date parsing:" $ do
            it "can parse a date" $ do
                let p =
                        skipComments >> parseDate
                    i =
                        "# 2025-02-05"
                    m =
                        parseByteString p mempty i
                    r' =
                        maybeSuccess m
                print m
                r' `shouldBe` Just "2025-02-05"

            it "can parse a date followed by comment" $ do
                let p =
                        skipComments >> parseDate
                    i =
                        "# 2025-02-05 -- dates not nececessarily sequential"
                    m =
                        parseByteString p mempty i
                    r' =
                        maybeSuccess m
                print m
                r' `shouldBe` Just "2025-02-05"

        describe "Day activities parsing:" $ do
            it "can parse a single activity" $ do
                let p =
                        parseActivity
                    i =
                        "08:00 Breakfast"
                    m =
                        parseByteString p mempty i
                    r' =
                        maybeSuccess m
                print m
                r' `shouldBe` Just (800, "Breakfast")

            it "can parse a day followed by a single activity" $ do
                let p =
                        skipWhitespace >> skipComments >> parseDate
                        >> parseActivity
                    i =
                        activityDay
                    m =
                        parseByteString p mempty i
                    r' =
                        maybeSuccess m
                print m
                r' `shouldBe` Just (800, "Breakfast")

            it "can parse a day followed by a multiple activities" $ do
                let p =
                        skipWhitespace >> skipComments >> parseDate
                        >> parseActivities
                    i =
                        activitiesDay
                    m =
                        parseByteString p mempty i
                    r' =
                        maybeSuccess m
                print m
                r' `shouldBe` Just [
                    (800, "Breakfast")
                    , (900, "Sanitizing moisture collector")
                    , (1100, "Exercising in high-grav gym")
                    , (1730, "R&R")
                    ]

            it "can parse a date followed by comment, followed by an activity" $ do
                let p =
                        skipComments >> parseDate >> parseActivity
                    i =
                        "# 2025-02-05 -- dates\n08:00 Gym"
                    m =
                        parseByteString p mempty i
                    r' =
                        maybeSuccess m
                print m
                r' `shouldBe` Just (800, "Gym")

            it "can parse a day followed by a single activity, followed by comment" $ do
                let p =
                        skipWhitespace >> skipComments >> parseDate
                        >> parseActivity
                    i =
                        "# 2025-02-05\n08:00 Breakfast -- are you sure?"
                    m =
                        parseByteString p mempty i
                    r' =
                        maybeSuccess m
                print m
                r' `shouldBe` Just (800, "Breakfast")
            it "can parse a day -> activity -> comment -> activity" $ do
                let p =
                        skipWhitespace >> skipComments >> parseDate
                        >> parseActivities
                    i =
                        "# 2025-02-05\n08:00 Breakfast -- are you sure?\n09:00 Gym"
                    m =
                        parseByteString p mempty i
                    r' =
                        maybeSuccess m
                print m
                r' `shouldBe` Just [(800, "Breakfast"), (900, "Gym")]
            it "can parse a day -> activity -> day -> activity" $ do
                let p =
                        skipWhitespace >> skipComments >> parseHistory
                    i =
                        "# 2025-02-05\n08:00 Breakfast\n\n# 2025-02-06\n09:00 Gym"
                    m =
                        parseByteString p mempty i
                    r' =
                        maybeSuccess m
                print m
                r' `shouldBe` Just [
                      ("2025-02-05", [(800, "Breakfast")])
                    , ("2025-02-06", [(900, "Gym")])
                    ]


activityDay :: ByteString
activityDay = [r|
# 2025-02-05
08:00 Breakfast
|]


activitiesDay :: ByteString
activitiesDay = [r|
# 2025-02-05
08:00 Breakfast
09:00 Sanitizing moisture collector
11:00 Exercising in high-grav gym
17:30 R&R
|]


sampleLog :: ByteString
sampleLog = [r|
-- wheee a comment

# 2025-02-05
08:00 Breakfast
09:00 Sanitizing moisture collector
11:00 Exercising in high-grav gym
12:00 Lunch
13:00 Programming
17:00 Commuting home in rover
17:30 R&R
19:00 Dinner
21:00 Shower
21:15 Read
22:00 Sleep

# 2025-02-07 -- dates not nececessarily sequential
08:00 Breakfast -- should I try skippin bfast?
09:00 Bumped head, passed out
13:36 Wake up, headache
13:37 Go to medbay
13:40 Patch self up
13:45 Commute home for rest
14:15 Read
21:00 Dinner
21:15 Read
22:00 Sleep
|]
