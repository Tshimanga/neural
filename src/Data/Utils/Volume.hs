{-# OPTIONS_HADDOCK show-extensions #-}

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

{-|
Module      : Data.Utils.Volume
Description : fixed-size volumes
Copyright   : (c) Lars Brünjes, 2016
License     : MIT
Maintainer  : brunjlar@gmail.com
Stability   : experimental
Portability : portable

This module defines fixed-size /volumes/ and some basic typeclass instances and operations for them.
A 'Volume' is a 'Matrix' with 'Vector' entries, i.e. a three-dimensional array.
-}

module Data.Utils.Volume
    ( Volume(..) 
    , slice
    , vgenerate
    ) where

import GHC.TypeLits
import Data.MyPrelude
import Data.Utils.Matrix
import Data.Utils.Vector

-- | @'Volume' m n d a@ is the type of /volumes/ with @m@ rows, @n@ columns, depth @d@ and entries of type @a@.
--
newtype Volume (m :: Nat) (n :: Nat) (d :: Nat) a = Volume (Matrix m n (Vector d a))
    deriving (Eq, Show, Functor, Foldable, Traversable, NFData)

instance (KnownNat m, KnownNat n, KnownNat d) => Applicative (Volume m n d) where

    pure x = Volume $ pure (pure x)

    Volume fs <*> Volume xs = Volume $ (<*>) <$> fs <*> xs

-- | @'slice' v i@ gives the matrix "at depth @i@" of volume @v@ (or 'Nothing' if @i@ is invalid).
--
-- >>> :set -XDataKinds
-- >>> slice (pure True :: Volume 2 2 3 Bool) 2
-- Just (Matrix [[True,True],[True,True]])
--
-- >>> slice (pure True :: Volume 2 2 3 Bool) 3
-- Nothing
--
slice :: Volume m n d a -> Int -> Maybe (Matrix m n a)
slice (Volume m) i = sequenceA $ (!? i) <$> m 

-- | Generates a 'Volume' by applying the given function to each index (row, column, slice).
--
-- >>> :set -XDataKinds
-- >>> vgenerate id :: Volume 1 2 3 (Int, Int, Int)
-- Volume (Matrix [[[(0,0,0),(0,0,1),(0,0,2)],[(0,1,0),(0,1,1),(0,1,2)]]])
--
vgenerate :: (KnownNat m, KnownNat n, KnownNat d) => ((Int, Int, Int) -> a) -> Volume m n d a
vgenerate f = Volume $ mgenerate (\(i, j) -> generate (\k -> f (i, j, k)))
