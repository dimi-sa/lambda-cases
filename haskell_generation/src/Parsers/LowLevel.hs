{-# language LambdaCase #-}

module Parsers.LowLevel where

import Text.Parsec
  ( (<|>), char, string, parserFail, many, many1, lower, try, digit )
import Text.Parsec.String
  ( Parser )

import Helpers
  ( (==>), keywords, seperated2 )

import HaskellTypes.LowLevel
  ( Literal(..), ValueName(..), LiteralOrValueName(..), TupleAbstraction(..)
  , Abstraction(..) )

-- All:
-- integer_p, literal_p, value_name_p, literal_or_value_name_p, tuple_abstraction_p
-- abstraction_p
integer_p =
  let natural_number_string = many1 digit :: Parser String in
  read <$> ((:) <$> char '-' <*> natural_number_string <|> natural_number_string)
  :: Parser Integer

literal_p = integer_p
  :: Parser Literal

value_name_p =
  many1 (lower <|> char '_') >>= \lowers_underscores ->
  elem lowers_underscores keywords ==> \case
    True -> parserFail "keyword"
    _ -> return $ VN lowers_underscores
  :: Parser ValueName 

literal_or_value_name_p =
  Literal <$> literal_p <|> ValueName <$> value_name_p
  :: Parser LiteralOrValueName

tuple_abstraction_p =
  string "(" >> value_name_p >>= \vn1 ->
  string ", " >> value_name_p >>= \vn2 ->
  many (try $ string ", " *> value_name_p) >>= \vns ->
  string ")" >> return (MA vn1 vn2 vns)
  :: Parser TupleAbstraction

abstraction_p =
  string "use_fields" *> return UseFields <|> NameAbstraction <$> value_name_p <|>
  TupleAbstraction <$> tuple_abstraction_p
  :: Parser Abstraction
