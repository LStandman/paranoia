module MooMoo
  ( 
    cbc_encrypt,
    cbc_encrypt1,
    cbc_decrypt
  )
  where

import Data.Bits
import Data.Word

cbc_encrypt   :: ([Word8] -> [Word8] -> [Word8]) -> [Word8] -> [Word8] -> [Word8] -> Int -> [Word8]
cbc_encrypt1  :: ([Word8] -> [Word8] -> [Word8]) -> [Word8] -> [Word8] -> [Word8] -> Int -> ([Word8], [Word8])
cbc_decrypt   :: ([Word8] -> [Word8] -> [Word8]) -> [Word8] -> [Word8] -> [Word8] -> Int -> [Word8]

cbc_encrypt1 _ iv [] _ _ = ([], iv)

cbc_encrypt1 f iv ptext key block_size = (ctext1 ++ ctext2, iv_out)
  where 
    (ptext1, ptext2)  = splitAt block_size ptext
    ptext1'           = zipWith (xor) ptext1 iv
    ctext1            = f ptext1' key
    (ctext2, iv_out)  = cbc_encrypt1 f ctext1 ptext2 key block_size

cbc_encrypt f iv ptext key block_size = ctext
  where (ctext, _) = cbc_encrypt1 f iv ptext key block_size

cbc_decrypt _ _ [] _ _ = []

cbc_decrypt f iv ctext key block_size = ptext ++ (cbc_decrypt f ctext1 ctext2 key block_size)
  where 
    (ctext1, ctext2)  = splitAt block_size ctext
    ptext'            = f ctext1 key
    ptext             = zipWith (xor) ptext' iv
