module HaskellBook.Chapter11.ConstructingValues where
  


data GuessWhat =


trivialValue :: GuessWhat
trivialValue = Chickenbutt

data Id a =


idInt :: Id Integer
idInt = MkId 10    


idIdentity :: Id (a -> a)
idIdentity = MkId $ \x -> x


data Product a b =
    
type Awesome = Bool

type Name' = String

person :: Product Name' Awesome
person = Product "Simon" True    


data Sum a b = 
    First a
    

data Twitter =
    

data AskFm =


socialNetwork :: Sum Twitter AskFm
socialNetwork = First Twitter


data RecordProduct a b = 
    RecordProduct 
      { pfirst :: a
      } 
      deriving (Eq, Show)


myRecord :: RecordProduct Integer Float
myRecord = RecordProduct 42 0.00001


myRecord' :: RecordProduct Integer Float
myRecord' = RecordProduct 
  { pfirst = 42
  }
  

newtype NumCow = 
    NumCow Int
    

newtype NumPig = 
    NumPig Int
    deriving (Eq, Show)
    

data Farmhouse = Farmhouse
    NumCow NumPig 
    deriving (Eq, Show)
    

type Farmhouse' = Product NumCow NumPig


newtype NumSheep = 
    NumSheep Int 
    deriving (Eq, Show)
    

data BigFarmhouse =
    deriving (Eq, Show)
    

type BigFarmhouse' =
    

type Name = String
type Age = Int
type LovesMud = Bool


type PoundsOfWool = Int


data CowInfo = CowInfo Name Age
    deriving (Eq, Show)
    

data PigInfo =
    deriving (Eq, Show)
    

data SheepInfo =
    deriving (Eq, Show)
    

data Animal =

-- Try to avoid using type synonyms with 
-- unstructured data like text or binary.

-- Alternately
type Animal' =
    

data OperatingSystem =
    GnuPlusLinux
    | Mac
    | Windows
    deriving (Eq, Show)


data ProgrammingLanguage =
    

data Programmer =
    { os :: OperatingSystem
    } deriving (Eq, Show)
    

nineToFive :: Programmer
nineToFive = Programmer 
  { os = Mac
  }
  

feelingWizardly :: Programmer
feelingWizardly = Programmer 
  { lang = Agda
  }
  

allOperatingSystems :: [OperatingSystem]
allOperatingSystems =
    , Mac
    , Windows
    ]
    
allLanguages :: [ProgrammingLanguage]
allLanguages =
    [Haskell, Agda, Idris, PureScript]


allProgrammers :: [Programmer]
allProgrammers = 
    concat (map (\os -> 
      map (\pl -> Programmer os pl) allLanguages) 
        allOperatingSystems)

    
-- Partial application to construct data

data ThereYet =
    deriving (Eq, Show)

-- who needs a "builder pattern"?
nope :: Float -> String -> Bool -> ThereYet
nope = There 10


notYet :: String -> Bool -> ThereYet
notYet = nope 25.5


notQuite :: Bool -> ThereYet
notQuite = notYet "woohoo"


yusssss :: ThereYet
yusssss = notQuite False


