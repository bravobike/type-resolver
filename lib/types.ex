defmodule TypeResolver.Types do
  @moduledoc """
  This modules defines a struct based representation of spec types.
  """
  use TypedStruct

  typedstruct module: AnyT do
    @moduledoc """
    Representation of the spec of an any-type, e.g. `any()`
    """
  end

  typedstruct module: NoneT do
    @moduledoc """
    Representation of the spec of a none-type, e.g. `none()`
    """
  end

  typedstruct module: AtomT do
    @moduledoc """
    Representation of the spec of an atom-type, e.g. `atom()`
    """
  end

  typedstruct module: MapAnyT do
    @moduledoc """
    Representation of the spec of an arbitrary map-type, e.g. `map()`
    """
  end

  typedstruct module: EmptyMapL do
    @moduledoc """
    Representation of the spec of an arbitrary empty map-literal, e.g. `%{}`
    """
  end

  typedstruct module: TupleAnyT do
    @moduledoc """
    Representation of the spec of an arbitrary tuple-type, e.g. `tuple()`
    """
  end

  typedstruct module: PidT do
    @moduledoc """
    Representation of the spec of a pid-type, e.g. `pid()`
    """
  end

  typedstruct module: PortT do
    @moduledoc """
    Representation of the spec of a port-type, e.g. `port()`
    """
  end

  typedstruct module: ReferenceT do
    @moduledoc """
    Representation of the spec of a reference-type, e.g. `reference()`
    """
  end

  typedstruct module: TupleT do
    @moduledoc """
    Representation of the spec of a reference-type, e.g. `{atom(), integer()}`

    It consists of the following:
    - a list of the types of the tuple's elements
    """
    field(:inner, TypeResolver.Types.t())
  end

  typedstruct module: UnionT do
    @moduledoc """
    Representation of the spec of an union-type, e.g. `atom() | integer()`

    It consists of the following:
    - a list of the types of the union's elements
    """
    field(:inner, list())
  end

  typedstruct module: FloatT do
    @moduledoc """
    Representation of the spec of a float-type, e.g. `float()`
    """
  end

  typedstruct module: IntegerT do
    @moduledoc """
    Representation of the spec of a integer-type, e.g. `integer()`
    """
  end

  typedstruct module: BinaryT do
    @moduledoc """
    Representation of the spec of a binary-type, e.g. `binary()`
    """
  end

  typedstruct module: NonNegIntegerT do
    @moduledoc """
    Representation of the spec of a non negative integer-type, e.g. `non_neg_integer()`
    """
  end

  typedstruct module: NegIntegerT do
    @moduledoc """
    Representation of the spec of a negative integer-type, e.g. `neg_integer()`
    """
  end

  typedstruct module: PosIntegerT do
    @moduledoc """
    Representation of the spec of a positive integer-type, e.g. `pos_integer()`
    """
  end

  typedstruct module: BooleanT do
    @moduledoc """
    Representation of the spec of a boolean-type, e.g. `boolean()`
    """
  end

  typedstruct module: ListT do
    @moduledoc """
    Representation of the spec of a list-type, e.g. `list(integer())`

    It consists of the following:
    - the type of the list elements
    """
    field(:inner, any())
  end

  typedstruct module: MapL do
    @moduledoc """
    Representation of the spec of a map-literal, e.g. `%{a: integer(), b: binary()}`

    It consists of the following:
    - a list of types of inner elements
    """
    field(:inner, TypeResolver.Types.inner_map_t())
  end

  typedstruct module: MapFieldExactL do
    @moduledoc """
    Representation of the spec of a required field in a map-literal, e.g. `%{required(:a) => integer()}`

    It consists of the following:
    - a key
    - a value
    """
    field(:k, any())
    field(:v, any())
  end

  typedstruct module: MapFieldAssocL do
    @moduledoc """
    Representation of the spec of an optional field in a map-literal, e.g. `%{:a => integer()}`

    It consists of the following:
    - a key
    - a value
    """
    field(:k, any())
    field(:v, any())
  end

  typedstruct module: NonemptyListT do
    @moduledoc """
    Representation of the spec of a non empty list-type, e.g. `nonempty_list()` or `nonempty_list(integer())`

    It consists of the following:
    - the type of the non empty list's elements
    """
    field(:inner, TypeResolver.Types.t())
  end

  typedstruct module: MaybeImproperListT do
    @moduledoc """
    Representation of the spec of a maybe improper list-type, e.g. `maybe_improper_list(integer() integer())`

    It consists of the following:
    - the type of the non empty list's elements
    - the termination type
    """
    field(:inner, TypeResolver.Types.t())
    field(:termination, TypeResolver.Types.t())
  end

  typedstruct module: NonemptyImproperListT do
    @moduledoc """
    Representation of the spec of a maybe improper list-type, e.g. `non_empty_improper_list(integer() integer())`

    It consists of the following:
    - the type of the non empty list's elements
    - the termination type
    """
    field(:inner, TypeResolver.Types.t())
    field(:termination, TypeResolver.Types.t())
  end

  typedstruct module: NonemptyMaybeImproperListT do
    @moduledoc """
    Representation of the spec of a non empty maybe improper list-type, e.g. `non_empty_maybe_improper_list(integer() integer())`

    It consists of the following:
    - the type of the non empty list's elements
    - the termination type
    """
    field(:inner, TypeResolver.Types.t())
    field(:termination, TypeResolver.Types.t())
  end

  typedstruct module: AtomL do
    @moduledoc """
    Representation of the spec of an atom-literal, e.g. `:hello`
    """
    field(:value, atom())
  end

  typedstruct module: NilL do
    @moduledoc """
    Representation of the spec of a nil-literal, e.g. `nil`
    """
  end

  typedstruct module: BooleanL do
    @moduledoc """
    Representation of the spec of a boolean-literal, e.g. `true`

    It consists of the following:
    - the value of the literal, either `true` or `false`
    """
    field(:value, boolean())
  end

  typedstruct module: EmptyBitstringL do
    @moduledoc """
    Representation of the spec of an empty bitstring-literal, e.g. `<<>>`
    """
  end

  typedstruct module: SizedBitstringL do
    @moduledoc """
    Representation of the spec of an sized bitstring-literal, e.g. `<<_::12>>`

    It consists of the following:
    - the size of the bitstring
    """
    field(:size, non_neg_integer())
  end

  typedstruct module: BitstringWithUnitL do
    @moduledoc """
    Representation of the spec of an bitstring-literal with unit, e.g. `<<_::_*12>>`

    It consists of the following:
    - the unit of the bitstring
    """
    field(:unit, 1..256)
  end

  typedstruct module: SizedBitstringWithUnitL do
    @moduledoc """
    Representation of the spec of an sized bitstring-literal with unit, e.g. `<<_::12, _::_*12>>`

    It consists of the following:
    - the unit of the bitstring
    - the size of the bitstring
    """
    field(:unit, 1..256)
    field(:size, non_neg_integer())
  end

  typedstruct module: IntegerL do
    @moduledoc """
    Representation of the spec of an integer-literal, e.g. `12`
    """
    field(:value, integer())
  end

  typedstruct module: FunctionL do
    @moduledoc """
    Representation of the spec of an function-literal, e.g. `(binary(), integer()) -> binary()`

    It consists of the following:

    - the arity of the function
    """
    field(:arity, integer() | :any)
  end

  typedstruct module: RangeL do
    @moduledoc """
    Representation of the spec of a range-literal, e.g. `1..12`

    It consists of the following:

    - the lower limit of the range
    - the upper limit of the range
    """
    field(:from, integer())
    field(:to, integer())
  end

  typedstruct module: EmptyListL do
    @moduledoc """
    Representation of the spec of an empty list-literal, e.g. `[]`
    """
  end

  typedstruct module: StructL do
    @moduledoc """
    Representation of the spec of an struct literal, e.g. `%MyStruct{}`

    It consists of the following:

    - the module, the struct is defined in
    """
    field(:module, atom())
  end

  @type t ::
          AnyT.t()
          | NoneT.t()
          | AtomT.t()
          | MapAnyT.t()
          | EmptyMapL.t()
          | TupleAnyT.t()
          | PidT.t()
          | PortT.t()
          | ReferenceT.t()
          | TupleT.t()
          | UnionT.t()
          | FloatT.t()
          | IntegerT.t()
          | BinaryT.t()
          | NonNegIntegerT.t()
          | NegIntegerT.t()
          | PosIntegerT.t()
          | BooleanT.t()
          | ListT.t()
          | MapL.t()
          | MapFieldExactL.t()
          | MapFieldAssocL.t()
          | NonemptyListT.t()
          | NonemptyImproperListT.t()
          | NonemptyMaybeImproperListT.t()
          | AtomL.t()
          | NilL.t()
          | BooleanL.t()
          | EmptyBitstringL.t()
          | SizedBitstringL.t()
          | SizedBitstringL.t()
          | BitstringWithUnitL.t()
          | SizedBitstringWithUnitL.t()
          | IntegerL.t()
          | FunctionL.t()
          | RangeL.t()
          | EmptyListL.t()
          | StructL.t()

  @type inner_map_t :: MapFieldExactL.t() | MapFieldAssocL.t()
end
