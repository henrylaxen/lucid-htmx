{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE QuasiQuotes #-}

module Core where

import Common
import Contravariant.Extras.Contrazip (contrazip3)
import Control.Monad.IO.Class (liftIO)
import Css3.Selector (csssel)
import Data.Functor.Identity (Identity)
import Data.Int
import Data.Functor.Contravariant
import Data.Profunctor
import Data.Proxy
import Data.Time
import Data.Text
import Data.Tuple.Curry
import Data.Vector (Vector)
import GHC.Generics
import GHC.TypeLits
import Hasql.TH
import Hasql.Session (Session)
import Hasql.Statement (Statement(..))
import Lucid
import Lucid.HTMX.Base (hx_include_, hx_target_)
import Lucid.HTMX.Safe hiding (hx_include_, hx_target_)
import Network.Wai.Handler.Warp
import Prelude
import Servant.API
import Servant.HTML.Lucid
import Servant.Links
import Servant.Server

import qualified Css3.Selector as Css3
import qualified Data.Aeson as Aeson
import qualified Data.HashSet as HashSet
import qualified Data.Text as Text
import qualified Data.Vector as Vector
import qualified Hasql.Session as Session
import qualified Hasql.Decoders as Decoders
import qualified Hasql.Encoders as Encoders
import qualified Hasql.Connection as Connection

newtype ID a = ID { unID :: Int32 }
    deriving stock (Eq)
    deriving newtype (Show)

newtype Name = Name { unName :: Text }
    deriving stock (Eq)
    deriving newtype (Show)

newtype Email = Email { unEmail :: Text }
    deriving stock (Eq)
    deriving newtype (Show)

newtype Password = Password { unPassword :: Text }
    deriving stock (Eq)
    deriving newtype (Show)

data UserAuth = UserAuth
    { userAuthEmail :: Email
    , userAuthPassword :: Password
    }
    deriving stock (Eq, Show)

newtype Tag = Tag { unTag :: Text }
    deriving stock (Eq)
    deriving newtype (Show)

-- Food instead of karma. If an animal reaches 0 food, they die
-- An animal consumes food according to size

data Animal =
    Elephant
    -- An elephant whose account is older than 2 months is immune to downvotes
    | Lion
    -- A lion can downvote a post/tweet up to three times
    | Zebra
    -- A zebra has the ability to delete their posts/tweets
    | Chameleon
    -- A chameleon can edit their posts/tweets
    | Parrot
    -- A parrot can post/comment as any other animal, but get's none of their benefits
    | Eagle
    -- Can see a zebra's deleted comments, a chameleon's edits, and a parrot through disguise
    | Scorpion
    -- If a scorpion replies to a comment and gets more votes than the post they reply to,
    -- the original comment/post poster is banned for 3 days. Doesn't work on other scorpions
    deriving stock (Eq, Show)

data NewUser = NewUser
    { userName :: Name
    , userEmail :: Email
    , userPassword :: Password
    , userConfirmPassword :: Password
    , userIntro :: Text
    , userTags :: [Tag]
    , userAnimal :: Animal
    }
    deriving stock (Eq, Show)

data AuthorizedUser = AuthorizedUser
    { authorizedUserID :: ID AuthorizedUser
    , authorizedUserName :: Name
    , authorizedUserEmail :: Email
    , authorizedUserIntro :: Text
    , authorizedUserTags :: [Tag]
    , authorizedUserAnimal :: Animal
    }
    deriving stock (Eq, Show)

-- | Analogous to a tweet
data Creet = Creet
    { creetTimestamp :: UTCTime
    , creetUserName :: Name
    , creetContent :: Text
    , creetRoars :: Int
    , creetShits :: Int
    , creetTags :: [Tag]
    , creetChildren :: [Creet]
    }
    deriving stock (Eq, Show)