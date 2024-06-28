defmodule AllTypes do
  use TypeResolver.TypeExporter
  use TypedStruct
  alias TypeResolver.Test.Types

  typedstruct do
    field(:my_field, atom())
  end

  # the top type, the set of all terms
  @type a :: any()
  # the bottom type, contains no terms
  @type b :: none()
  @type c :: atom()
  # any map
  @type d :: map()
  # process identifier
  @type e :: pid()
  # port identifier
  @type f :: port()
  @type g :: reference()
  # tuple of any size
  @type h :: tuple()

  ## Numbers
  @type i :: float()
  @type j :: integer()
  # ..., -3, -2, -1
  @type k :: neg_integer()
  # 0, 1, 2, 3, ...
  @type l :: non_neg_integer()
  # 1, 2, 3, ...
  @type m :: pos_integer()

  ## Lists
  # proper list ([]-terminated)
  @type n :: list(integer())
  # non-empty proper list
  @type o :: nonempty_list(integer())
  # proper or improper list
  @type p :: maybe_improper_list(integer(), integer())
  # improper list
  @type q :: nonempty_improper_list(integer(), integer())
  @type r :: nonempty_maybe_improper_list(integer(), integer())

  @type s :: integer() | binary()

  # LITERALS

  @type l_a :: :some_atom
  @type l_b :: nil
  @type l_c :: true
  @type l_d :: <<>>
  # size is a non neg integer
  @type l_e :: <<_::12>>
  # size between 0 and 255 
  @type l_f :: <<_::_*12>>
  @type l_g :: <<_::12, _::_*13>>

  @type l_h :: (-> binary())
  @type l_i :: (binary(), integer() -> atom())
  # any arity
  @type l_j :: (... -> binary())

  @type l_k :: 1
  @type l_l :: 1..10

  @type l_m :: [binary()]
  @type l_n :: []
  @type l_o :: [...]
  @type l_p :: [binary(), ...]
  @type l_q :: [my_key: binary()]

  @type l_r :: %{}
  @type l_s :: %{my_key: binary(), my_other_key: integer()}
  @type l_t :: %{binary() => integer(), integer() => binary()}
  @type l_u :: %{required(binary()) => integer(), required(integer()) => binary()}
  @type l_v :: %{optional(binary()) => integer(), optional(integer()) => binary()}
  @type l_w :: %__MODULE__{}
  @type l_x :: %__MODULE__{my_field: atom()}

  @type l_y :: {}
  @type l_z :: {:ok, atom()}

  # Built in types

  @type b_a :: term()
  @type b_b :: arity()
  @type b_c :: as_boolean(integer())
  @type b_d :: bitstring()
  @type b_e :: boolean()
  @type b_f :: byte()
  @type b_g :: char()
  @type b_h :: charlist()
  @type b_i :: nonempty_charlist()
  @type b_j :: fun()
  @type b_k :: function()
  @type b_l :: identifier()
  @type b_m :: iodata()
  @type b_n :: iolist()
  @type b_o :: keyword()
  @type b_p :: keyword(integer())
  @type b_q :: list()
  @type b_r :: nonempty_list()
  @type b_s :: maybe_improper_list()
  @type b_t :: nonempty_maybe_improper_list()
  @type b_u :: mfa()
  @type b_v :: module()
  @type b_w :: no_return()
  @type b_x :: node()
  @type b_y :: number()
  @type b_z :: struct()
  @type b_1 :: timeout()

  # remote types:

  @type r_a :: String.t()
  @type r_b :: Types.a() | integer()
  @type r_c :: a()

  @type r_d(a) :: a | list(a)
  @type r_e(a) :: a | Types.maybe_t(list(a))
end
