defmodule TypeResolver.Types do
  use TypedStruct

  typedstruct module: AnyT do
  end

  typedstruct module: NoneT do
  end

  typedstruct module: AtomT do
  end

  typedstruct module: MapAnyT do
  end

  typedstruct module: EmptyMapL do
  end

  typedstruct module: TupleAnyT do
  end

  typedstruct module: PidT do
  end

  typedstruct module: PortT do
  end

  typedstruct module: ReferenceT do
  end

  typedstruct module: TupleT do
    field(:inner, list())
  end

  typedstruct module: UnionT do
    field(:inner, list())
  end

  typedstruct module: FloatT do
  end

  typedstruct module: IntegerT do
  end

  typedstruct module: BinaryT do
  end

  typedstruct module: NonNegIntegerT do
  end

  typedstruct module: NegIntegerT do
  end

  typedstruct module: PosIntegerT do
  end

  typedstruct module: BooleanT do
  end

  typedstruct module: ListT do
    field(:inner, any())
  end

  typedstruct module: MapL do
    field(:inner, any())
  end

  typedstruct module: MapFieldExactL do
    field(:k, any())
    field(:v, any())
  end

  typedstruct module: MapFieldAssocL do
    field(:k, any())
    field(:v, any())
  end

  typedstruct module: NonemptyListT do
    field(:inner, any)
  end

  typedstruct module: MaybeImproperListT do
    field(:inner, any())
    field(:termination, any())
  end

  typedstruct module: NonemptyImproperListT do
    field(:inner, any())
    field(:termination, any())
  end

  typedstruct module: NonemptyMaybeImproperListT do
    field(:inner, any())
    field(:termination, any())
  end

  typedstruct module: AtomL do
    field(:value, atom())
  end

  typedstruct module: NilL do
  end

  typedstruct module: BooleanL do
    field(:value, boolean())
  end

  typedstruct module: EmptyBitstringL do
  end

  typedstruct module: SizedBitstringL do
    field(:size, non_neg_integer())
  end

  typedstruct module: BitstringWithUnitL do
    field(:unit, 1..256)
  end

  typedstruct module: SizedBitstringWithUnitL do
    field(:unit, 1..256)
    field(:size, non_neg_integer())
  end

  typedstruct module: IntegerL do
    field(:value, integer())
  end

  typedstruct module: FunctionL do
    field(:arity, integer() | :any)
  end

  typedstruct module: RangeL do
    field(:from, integer())
    field(:to, integer())
  end

  typedstruct module: EmptyListL do
  end

  typedstruct module: StructL do
    field(:module, atom())
  end
end
