module KDF
  ( 
    hmac,
    hmac1,
    pbkdf2,
    pbkdf2'
  )
  where

import Data.Bits
import Data.Word

type Prf = [Word8] -> Int -> [Word8] -> Int -> [Word8]

hmac    :: [Word8] -> Int -> [Word8] -> Int -> ([Word8] -> Int -> [Word8]) -> Int -> Int -> [Word8]
hmac1   :: [Word8] -> [Word8] -> ([Word8] -> Int -> [Word8]) -> Int -> Int -> [Word8]
pbkdf2  :: Prf -> Int -> [Word8] -> Int -> [Word8] -> Int -> Int -> Int -> [Word8]
pbkdf2' :: Prf -> Int -> [Word8] -> [Word8] -> Int -> Int -> [Word8]

div1 :: Integral a => a -> a -> a

a `div1` b = (a + b - 1) `div` b

hmac k k_size text text_size h b l = ohash
  where
    (k', k_size')
      | k_size > b  = (h k k_size, l)
      | otherwise   = (k, k_size)
    k''   = k' ++ (take (b - k_size') $ repeat 0)
    ipad  = take b $ repeat 0x36
    opad  = take b $ repeat 0x5C
    ihash = h ((zipWith (xor) k'' ipad) ++ text) (b + text_size)
    ohash = h ((zipWith (xor) k'' opad) ++ ihash) (b + l)

hmac1 k text h b l = hmac k (length k) text (length text) (h) b l

pbkdf2 h h_len p p_size s s_size c dk_len 
  | (toInteger $ dk_len `div1` h_len) > (4294967295::Integer) = errorWithoutStackTrace "KDF.pbkdf2: derived key too long"
  | otherwise                                                 = take dk_len $ concat [f i | i <- [1..l]]
  where 
    g n   = [ fromIntegral k :: Word8 | k <- [n `shiftR` 24, n `shiftR` 16, n `shiftR` 8, n]]
    u1 j  = h p p_size (s ++ (g j)) (s_size + 4)
    f j   = foldl1 (zipWith (xor)) $ take c $ iterate (\ v -> h p p_size v h_len) (u1 j)
    l     = dk_len `div1` h_len

pbkdf2' h h_len p s c dk_len = pbkdf2 h h_len p (length p) s (length s) c dk_len
