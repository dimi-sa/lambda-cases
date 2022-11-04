{-# LANGUAGE LambdaCase #-}

module CodeGenerators.Types where

import Prelude ( (++), concat, map, show, undefined )
import Data.List ( intercalate )

import Helpers ( Haskell, (-->), (.>), parenthesis_comma_sep_g )
import Parsers.Types
  ( TypeName
  , ValueType( AbstractionTypesAndResultType )
  , BaseType( TupleType, ParenthesisType, TypeName )
  , FieldAndType( FieldAndType_ )
  , TupleValue( FieldAndTypeList )
  , TupleType( NameAndTuple )
  )
import CodeGenerators.LowLevel ( value_name_g )

{-
  All:
  TypeName, BaseType, ValueType, FieldAndType, TupleValue, TupleType
-}

-- TypeName

type_name_g = show
  :: TypeName -> Haskell

-- BaseType

base_type_g = ( \case
  TupleType vts -> parenthesis_comma_sep_g value_type_g vts
  ParenthesisType vt -> case vt of
    (AbstractionTypesAndResultType [] bt) -> base_type_g bt
    _ -> "(" ++ value_type_g vt ++ ")"
  TypeName tn -> type_name_g tn
  ) :: BaseType -> Haskell

-- ValueType

value_type_g = ( \(AbstractionTypesAndResultType bts bt) -> 
  bts-->map (base_type_g .> (++ " -> "))-->concat ++ base_type_g bt
  ) :: ValueType -> Haskell

-- FieldAndType

field_and_type_g = ( \(FieldAndType_ vn vt) ->
  "get_" ++ value_name_g vn ++ " :: " ++ value_type_g vt
  ) :: FieldAndType -> Haskell

-- TupleValue

tuple_value_g = ( \(FieldAndTypeList fatl) ->
  "C { " ++ fatl-->map field_and_type_g--> intercalate ", " ++ " }"
  ) :: TupleValue -> Haskell

-- TupleType

tuple_type_g = ( \(NameAndTuple tn tv) ->
  let tn_g = type_name_g tn in
  "data " ++ tn_g ++ " =\n  " ++ tn_g ++ tuple_value_g tv ++ "\n"
  ) :: TupleType -> Haskell