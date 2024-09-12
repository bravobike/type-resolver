defmodule TypeResolverTest do
  use ExUnit.Case
  require TypeResolver

  alias TypeResolver.Test.Types2
  alias TypeResolver.Test.Types, as: T
  alias TypeResolver.Types

  @type my_type :: binary()

  @type my_type_there :: binary()
  @type my_type_here :: my_type_there()

  @type my_param(a) :: a | list(a)

  describe "resolve/2" do
    test "resolves any-type directly" do
      assert {:ok, %Types.AnyT{}} == TypeResolver.resolve(any())
    end

    test "resolves any-type remotely" do
      assert {:ok, %Types.AnyT{} |> with_remote(AllTypes, :a)} ==
               TypeResolver.resolve(AllTypes.a())
    end

    test "resolves none-type directly" do
      assert {:ok, %Types.NoneT{}} == TypeResolver.resolve(none())
    end

    test "resolves none-type remotely" do
      assert {:ok, %Types.NoneT{} |> with_remote(AllTypes, :b)} ==
               TypeResolver.resolve(AllTypes.b())
    end

    test "resolves atom-type directly" do
      assert {:ok, %Types.AtomT{}} == TypeResolver.resolve(atom())
    end

    test "resolves atom-type remotely" do
      assert {:ok, %Types.AtomT{} |> with_remote(AllTypes, :c)} ==
               TypeResolver.resolve(AllTypes.c())
    end

    test "resolves simple map-type directly" do
      assert {:ok, %Types.MapAnyT{}} == TypeResolver.resolve(map())
    end

    test "resolves simple map-type remotely" do
      assert {:ok, %Types.MapAnyT{} |> with_remote(AllTypes, :d)} ==
               TypeResolver.resolve(AllTypes.d())
    end

    test "resolves simple float-type directly" do
      assert {:ok, %Types.FloatT{}} == TypeResolver.resolve(float())
    end

    test "resolves simple float-type remotely" do
      assert {:ok, %Types.FloatT{} |> with_remote(AllTypes, :i)} ==
               TypeResolver.resolve(AllTypes.i())
    end

    test "resolves pid-type directly" do
      assert {:ok, %Types.PidT{}} == TypeResolver.resolve(pid())
    end

    test "resolves pid-type remotely" do
      assert {:ok, %Types.PidT{} |> with_remote(AllTypes, :e)} ==
               TypeResolver.resolve(AllTypes.e())
    end

    test "resolves port-type directly" do
      assert {:ok, %Types.PortT{}} == TypeResolver.resolve(port())
    end

    test "resolves port-type remotely" do
      assert {:ok, %Types.PortT{} |> with_remote(AllTypes, :f)} ==
               TypeResolver.resolve(AllTypes.f())
    end

    test "resolves reference-type directly" do
      assert {:ok, %Types.ReferenceT{}} == TypeResolver.resolve(reference())
    end

    test "resolves reference-type remotely" do
      assert {:ok, %Types.ReferenceT{} |> with_remote(AllTypes, :g)} ==
               TypeResolver.resolve(AllTypes.g())
    end

    test "resolves integer-type directly" do
      assert {:ok, %Types.IntegerT{}} == TypeResolver.resolve(integer())
    end

    test "resolves integer-type remotely" do
      assert {:ok, %Types.IntegerT{} |> with_remote(AllTypes, :j)} ==
               TypeResolver.resolve(AllTypes.j())
    end

    test "resolves neg_integer-type directly" do
      assert {:ok, %Types.NegIntegerT{}} == TypeResolver.resolve(neg_integer())
    end

    test "resolves neg_integer-type remotely" do
      assert {:ok, %Types.NegIntegerT{} |> with_remote(AllTypes, :k)} ==
               TypeResolver.resolve(AllTypes.k())
    end

    test "resolves non_neg_integer-type directly" do
      assert {:ok, %Types.NonNegIntegerT{}} == TypeResolver.resolve(non_neg_integer())
    end

    test "resolves non_neg_integer-type remotely" do
      assert {:ok, %Types.NonNegIntegerT{} |> with_remote(AllTypes, :l)} ==
               TypeResolver.resolve(AllTypes.l())
    end

    test "resolves pos_integer-type directly" do
      assert {:ok, %Types.PosIntegerT{}} == TypeResolver.resolve(pos_integer())
    end

    test "resolves pos_integer-type remotely" do
      assert {:ok, %Types.PosIntegerT{} |> with_remote(AllTypes, :m)} ==
               TypeResolver.resolve(AllTypes.m())
    end

    test "resolves list-type directly" do
      assert {:ok, %Types.ListT{inner: %Types.IntegerT{}}} ==
               TypeResolver.resolve(list(integer()))
    end

    test "resolves list-type remotely" do
      assert {:ok, %Types.ListT{inner: %Types.IntegerT{}} |> with_remote(AllTypes, :n)} ==
               TypeResolver.resolve(AllTypes.n())
    end

    test "resolves nonempty list-type directly" do
      assert {:ok, %Types.NonemptyListT{inner: %Types.IntegerT{}}} ==
               TypeResolver.resolve(nonempty_list(integer()))
    end

    test "resolves nonempty list-type remotely" do
      assert {:ok, %Types.NonemptyListT{inner: %Types.IntegerT{}} |> with_remote(AllTypes, :o)} ==
               TypeResolver.resolve(AllTypes.o())
    end

    test "resolves maybe improper list-type directly" do
      assert {:ok,
              %Types.MaybeImproperListT{inner: %Types.IntegerT{}, termination: %Types.IntegerT{}}} ==
               TypeResolver.resolve(maybe_improper_list(integer(), integer()))
    end

    test "resolves maybe improper list-type remotely" do
      assert {:ok,
              %Types.MaybeImproperListT{inner: %Types.IntegerT{}, termination: %Types.IntegerT{}}
              |> with_remote(AllTypes, :p)} ==
               TypeResolver.resolve(AllTypes.p())
    end

    test "resolves nonempty improper list-type directly" do
      assert {:ok,
              %Types.NonemptyImproperListT{
                inner: %Types.IntegerT{},
                termination: %Types.IntegerT{}
              }} ==
               TypeResolver.resolve(nonempty_improper_list(integer(), integer()))
    end

    test "resolves nonempty improper list-type remotely" do
      assert {:ok,
              %Types.NonemptyImproperListT{
                inner: %Types.IntegerT{},
                termination: %Types.IntegerT{}
              }
              |> with_remote(AllTypes, :q)} ==
               TypeResolver.resolve(AllTypes.q())
    end

    test "resolves nonempty maybe improper list-type directly" do
      assert {:ok,
              %Types.NonemptyMaybeImproperListT{
                inner: %Types.IntegerT{},
                termination: %Types.IntegerT{}
              }} ==
               TypeResolver.resolve(nonempty_maybe_improper_list(integer(), integer()))
    end

    test "resolves nonempty maybe improper list-type remotely" do
      assert {:ok,
              %Types.NonemptyMaybeImproperListT{
                inner: %Types.IntegerT{},
                termination: %Types.IntegerT{}
              }
              |> with_remote(AllTypes, :r)} ==
               TypeResolver.resolve(AllTypes.r())
    end

    test "resolves union-type directly" do
      assert {:ok, %Types.UnionT{inner: [%Types.IntegerT{}, %Types.BinaryT{}]}} ==
               TypeResolver.resolve(integer() | binary())
    end

    test "resolves union-type remotely" do
      assert {:ok,
              %Types.UnionT{inner: [%Types.IntegerT{}, %Types.BinaryT{}]}
              |> with_remote(AllTypes, :s)} ==
               TypeResolver.resolve(AllTypes.s())
    end

    test "resolves any tuple-type directly" do
      assert {:ok, %Types.TupleAnyT{}} == TypeResolver.resolve(tuple())
    end

    test "resolves any tuple-type remotely" do
      assert {:ok, %Types.TupleAnyT{} |> with_remote(AllTypes, :h)} ==
               TypeResolver.resolve(AllTypes.h())
    end

    test "resolves an atom literal directly" do
      assert {:ok, %Types.AtomL{value: :hello}} == TypeResolver.resolve(:hello)
    end

    test "resolves an atom literal remotely" do
      assert {:ok, %Types.AtomL{value: :some_atom} |> with_remote(AllTypes, :l_a)} ==
               TypeResolver.resolve(AllTypes.l_a())
    end

    test "resolves nil literal directly" do
      assert {:ok, %Types.NilL{}} == TypeResolver.resolve(nil)
    end

    test "resolves nil literal remotely" do
      assert {:ok, %Types.NilL{} |> with_remote(AllTypes, :l_b)} ==
               TypeResolver.resolve(AllTypes.l_b())
    end

    test "resolves boolean literal directly" do
      assert {:ok, %Types.BooleanL{value: true}} == TypeResolver.resolve(true)
    end

    test "resolves boolean literal remotely" do
      assert {:ok, %Types.BooleanL{value: true} |> with_remote(AllTypes, :l_c)} ==
               TypeResolver.resolve(AllTypes.l_c())
    end

    test "resolves empty bitstring literal directly" do
      assert {:ok, %Types.EmptyBitstringL{}} == TypeResolver.resolve(<<>>)
    end

    test "resolves empty bitstring literal remotely" do
      assert {:ok, %Types.EmptyBitstringL{} |> with_remote(AllTypes, :l_d)} ==
               TypeResolver.resolve(AllTypes.l_d())
    end

    test "resolves sized bitstring literal directly" do
      assert {:ok, %Types.SizedBitstringL{size: 12}} == TypeResolver.resolve(<<_::12>>)
    end

    test "resolves sized bitstring literal remotely" do
      assert {:ok, %Types.SizedBitstringL{size: 12} |> with_remote(AllTypes, :l_e)} ==
               TypeResolver.resolve(AllTypes.l_e())
    end

    test "resolves bitstring with unit literal directly" do
      assert {:ok, %Types.BitstringWithUnitL{unit: 12}} == TypeResolver.resolve(<<_::_*12>>)
    end

    test "resolves bitstring with unit literal remotely" do
      assert {:ok, %Types.BitstringWithUnitL{unit: 12} |> with_remote(AllTypes, :l_f)} ==
               TypeResolver.resolve(AllTypes.l_f())
    end

    test "resolves sized bitstring with unit literal directly" do
      assert {:ok, %Types.SizedBitstringWithUnitL{size: 12, unit: 13}} ==
               TypeResolver.resolve(<<_::12, _::_*13>>)
    end

    test "resolves sized bitstring with unit literal remotely" do
      assert {:ok,
              %Types.SizedBitstringWithUnitL{size: 12, unit: 13} |> with_remote(AllTypes, :l_g)} ==
               TypeResolver.resolve(AllTypes.l_g())
    end

    test "resolves 0 arity fun literal directly" do
      assert {:ok, %Types.FunctionL{arity: 0}} == TypeResolver.resolve((-> binary()))
    end

    test "resolves 0 arity fun literal remotely" do
      assert {:ok, %Types.FunctionL{arity: 0} |> with_remote(AllTypes, :l_h)} ==
               TypeResolver.resolve(AllTypes.l_h())
    end

    test "resolves 2 arity fun literal directly" do
      assert {:ok, %Types.FunctionL{arity: 2}} ==
               TypeResolver.resolve((binary(), integer() -> binary()))
    end

    test "resolves 2 arity fun literal remotely" do
      assert {:ok, %Types.FunctionL{arity: 2} |> with_remote(AllTypes, :l_i)} ==
               TypeResolver.resolve(AllTypes.l_i())
    end

    test "resolves any arity fun literal directly" do
      assert {:ok, %Types.FunctionL{arity: :any}} ==
               TypeResolver.resolve((... -> binary()))
    end

    test "resolves any2 arity fun literal remotely" do
      assert {:ok, %Types.FunctionL{arity: :any} |> with_remote(AllTypes, :l_j)} ==
               TypeResolver.resolve(AllTypes.l_j())
    end

    test "resolves ranges literal directly" do
      assert {:ok, %Types.RangeL{from: 1, to: 10}} == TypeResolver.resolve(1..10)
    end

    test "resolves ranges literal remotely" do
      assert {:ok, %Types.RangeL{from: 1, to: 10} |> with_remote(AllTypes, :l_l)} ==
               TypeResolver.resolve(AllTypes.l_l())
    end

    test "resolves typed list literal remotely" do
      assert {:ok, %Types.ListT{inner: %Types.BinaryT{}} |> with_remote(AllTypes, :l_m)} ==
               TypeResolver.resolve(AllTypes.l_m())
    end

    test "resolves typed list literal directly" do
      assert {:ok, %Types.ListT{inner: %Types.BinaryT{}}} ==
               TypeResolver.resolve([binary()])
    end

    test "resolves empty list literal remotely" do
      assert {:ok, %Types.EmptyListL{} |> with_remote(AllTypes, :l_n)} ==
               TypeResolver.resolve(AllTypes.l_n())
    end

    test "resolves empty list literal directly" do
      assert {:ok, %Types.EmptyListL{}} == TypeResolver.resolve([])
    end

    test "resolves non empty list literal remotely" do
      assert {:ok, %Types.NonemptyListT{inner: %Types.AnyT{}} |> with_remote(AllTypes, :l_o)} ==
               TypeResolver.resolve(AllTypes.l_o())
    end

    test "resolves non empty list literal directly" do
      assert {:ok, %Types.NonemptyListT{inner: %Types.AnyT{}}} ==
               TypeResolver.resolve([...])
    end

    test "resolves empty list with type literal directly" do
      assert {:ok, %Types.NonemptyListT{inner: %Types.BinaryT{}}} ==
               TypeResolver.resolve([..., binary()])
    end

    test "resolves non empty list with type literal remotely" do
      assert {:ok, %Types.NonemptyListT{inner: %Types.BinaryT{}} |> with_remote(AllTypes, :l_p)} ==
               TypeResolver.resolve(AllTypes.l_p())
    end

    test "resolves keyword list literal directly" do
      assert {:ok,
              %Types.ListT{
                inner: [
                  %Types.TupleT{
                    inner: [%Types.AtomL{value: :hello}, %Types.AtomL{value: :world}]
                  },
                  %Types.TupleT{inner: [%Types.AtomL{value: :bla}, %Types.BinaryT{}]}
                ]
              }} ==
               TypeResolver.resolve(hello: :world, bla: binary())
    end

    test "resolves keyword list literal remotely" do
      assert {:ok,
              %Types.ListT{
                inner: %Types.TupleT{
                  inner: [
                    %TypeResolver.Types.AtomL{value: :my_key},
                    %TypeResolver.Types.BinaryT{}
                  ]
                }
              }
              |> with_remote(AllTypes, :l_q)} ==
               TypeResolver.resolve(AllTypes.l_q())
    end

    test "resolves tuple literals directly" do
      assert {:ok,
              %Types.TupleT{
                inner: [%Types.AtomL{value: :a}, %Types.IntegerL{value: 12}, %Types.BinaryT{}]
              }} ==
               TypeResolver.resolve({:a, 12, binary()})
    end

    test "resolves 2-tuple literals directly" do
      assert {:ok,
              %Types.TupleT{
                inner: [%Types.AtomL{value: :a}, %Types.IntegerL{value: 12}]
              }} ==
               TypeResolver.resolve({:a, 12})
    end

    test "resolves tuple literals remotely" do
      assert {:ok,
              %Types.TupleT{inner: [%Types.AtomL{value: :ok}, %Types.AtomT{}]}
              |> with_remote(AllTypes, :l_z)} ==
               TypeResolver.resolve(AllTypes.l_z())
    end

    test "resolves empty map literal remotely" do
      assert {:ok, %Types.EmptyMapL{} |> with_remote(AllTypes, :l_r)} ==
               TypeResolver.resolve(AllTypes.l_r())
    end

    test "resolves empty map literal directly" do
      assert {:ok, %Types.EmptyMapL{}} == TypeResolver.resolve(%{})
    end

    test "resolves typed map literal with atom keys remotely" do
      assert {:ok,
              %Types.MapL{
                inner: [
                  %Types.MapFieldExactL{
                    k: %Types.AtomL{value: :my_key},
                    v: %Types.BinaryT{}
                  },
                  %Types.MapFieldExactL{
                    k: %Types.AtomL{value: :my_other_key},
                    v: %Types.IntegerT{}
                  }
                ]
              }
              |> with_remote(AllTypes, :l_s)} == TypeResolver.resolve(AllTypes.l_s())
    end

    test "resolves typed map literal with atom keys directly" do
      assert {:ok,
              %Types.MapL{
                inner: [
                  %Types.MapFieldExactL{
                    k: %Types.AtomL{value: :my_key},
                    v: %Types.BinaryT{}
                  },
                  %Types.MapFieldExactL{
                    k: %Types.AtomL{value: :my_other_key},
                    v: %Types.IntegerT{}
                  }
                ]
              }} ==
               TypeResolver.resolve(%{my_key: binary(), my_other_key: integer()})
    end

    test "resolves typed map literal remotely" do
      assert {:ok,
              %Types.MapL{
                inner: [
                  %Types.MapFieldExactL{
                    k: %Types.BinaryT{},
                    v: %Types.IntegerT{}
                  },
                  %Types.MapFieldExactL{
                    k: %Types.IntegerT{},
                    v: %Types.BinaryT{}
                  }
                ]
              }
              |> with_remote(AllTypes, :l_t)} == TypeResolver.resolve(AllTypes.l_t())
    end

    test "resolves typed map literal directly" do
      assert {:ok,
              %Types.MapL{
                inner: [
                  %Types.MapFieldExactL{
                    k: %Types.BinaryT{},
                    v: %Types.IntegerT{}
                  },
                  %Types.MapFieldExactL{
                    k: %Types.IntegerT{},
                    v: %Types.BinaryT{}
                  }
                ]
              }} == TypeResolver.resolve(%{binary() => integer(), integer() => binary()})
    end

    test "resolves typed exact map literal remotely" do
      assert {:ok,
              %Types.MapL{
                inner: [
                  %Types.MapFieldExactL{
                    k: %Types.BinaryT{},
                    v: %Types.IntegerT{}
                  },
                  %Types.MapFieldExactL{
                    k: %Types.IntegerT{},
                    v: %Types.BinaryT{}
                  }
                ]
              }
              |> with_remote(AllTypes, :l_u)} == TypeResolver.resolve(AllTypes.l_u())
    end

    test "resolves typed exact map literal directly" do
      assert {:ok,
              %Types.MapL{
                inner: [
                  %Types.MapFieldExactL{
                    k: %Types.BinaryT{},
                    v: %Types.IntegerT{}
                  },
                  %Types.MapFieldExactL{
                    k: %Types.IntegerT{},
                    v: %Types.BinaryT{}
                  }
                ]
              }} ==
               TypeResolver.resolve(%{
                 required(binary()) => integer(),
                 required(integer()) => binary()
               })
    end

    test "resolves typed optional map literal remotely" do
      assert {:ok,
              %Types.MapL{
                inner: [
                  %Types.MapFieldAssocL{
                    k: %Types.BinaryT{},
                    v: %Types.IntegerT{}
                  },
                  %Types.MapFieldAssocL{
                    k: %Types.IntegerT{},
                    v: %Types.BinaryT{}
                  }
                ]
              }
              |> with_remote(AllTypes, :l_v)} == TypeResolver.resolve(AllTypes.l_v())
    end

    test "resolves typed optional map literal directly" do
      assert {:ok,
              %Types.MapL{
                inner: [
                  %Types.MapFieldAssocL{
                    k: %Types.BinaryT{},
                    v: %Types.IntegerT{}
                  },
                  %Types.MapFieldAssocL{
                    k: %Types.IntegerT{},
                    v: %Types.BinaryT{}
                  }
                ]
              }} ==
               TypeResolver.resolve(%{
                 optional(binary()) => integer(),
                 optional(integer()) => binary()
               })
    end

    test "resolves typed optional map with a local type literal directly" do
      assert {
               :ok,
               %TypeResolver.Types.MapL{
                 inner: [
                   %TypeResolver.Types.MapFieldAssocL{
                     k: %TypeResolver.Types.BinaryT{},
                     v: %TypeResolver.Types.IntegerT{}
                   },
                   %TypeResolver.Types.MapFieldAssocL{
                     k: %TypeResolver.Types.IntegerT{},
                     v: %TypeResolver.Types.NamedType{
                       inner: %TypeResolver.Types.NamedType{
                         name: :my_type_there,
                         module: TypeResolverTest,
                         inner: %TypeResolver.Types.BinaryT{}
                       },
                       module: TypeResolverTest,
                       name: :my_type_here
                     }
                   }
                 ]
               }
             } ==
               TypeResolver.resolve(%{
                 optional(binary()) => integer(),
                 optional(integer()) => my_type_here()
               })
    end

    test "resolves struct literal remotely" do
      assert {:ok, %Types.StructL{module: AllTypes} |> with_remote(AllTypes, :l_w)} ==
               TypeResolver.resolve(AllTypes.l_w())
    end

    test "resolves struct literal directly" do
      assert {:ok, %Types.StructL{module: AllTypes}} == TypeResolver.resolve(%AllTypes{})
    end

    test "resolves struct with fields remotely" do
      assert {:ok, %Types.StructL{module: AllTypes} |> with_remote(AllTypes, :l_x)} ==
               TypeResolver.resolve(AllTypes.l_x())
    end

    test "resolves struct with fields literal directly" do
      assert {:ok, %Types.StructL{module: AllTypes}} ==
               TypeResolver.resolve(%AllTypes{my_field: binary()})
    end

    test "resolves a term built in type remotely" do
      assert {:ok, %Types.AnyT{} |> with_remote(AllTypes, :b_a)} ==
               TypeResolver.resolve(AllTypes.b_a())
    end

    test "resolves a term built in type directly" do
      assert {:ok, %Types.AnyT{}} == TypeResolver.resolve(term())
    end

    test "resolves a arity built in type remotely" do
      assert {:ok, %Types.RangeL{from: 0, to: 255} |> with_remote(AllTypes, :b_b)} ==
               TypeResolver.resolve(AllTypes.b_b())
    end

    test "resolves a arity built in type directly" do
      assert {:ok, %Types.RangeL{from: 0, to: 255}} == TypeResolver.resolve(arity())
    end

    test "resolves as boolean built in type remotely" do
      assert {:ok, %Types.IntegerT{} |> with_remote(AllTypes, :b_c)} ==
               TypeResolver.resolve(AllTypes.b_c())
    end

    test "resolves as boolean built in type directly" do
      assert {:ok, %Types.IntegerT{}} == TypeResolver.resolve(as_boolean(integer()))
    end

    test "resolves a bitstring built in type remotely" do
      assert {:ok, %Types.BitstringWithUnitL{unit: 1} |> with_remote(AllTypes, :b_d)} ==
               TypeResolver.resolve(AllTypes.b_d())
    end

    test "resolves a bitstring built in type directly" do
      assert {:ok, %Types.BitstringWithUnitL{unit: 1}} == TypeResolver.resolve(bitstring())
    end

    test "resolves a boolean built in type remotely" do
      assert {:ok, %Types.BooleanT{} |> with_remote(AllTypes, :b_e)} ==
               TypeResolver.resolve(AllTypes.b_e())
    end

    test "resolves a boolean built in type directly" do
      assert {:ok, %Types.BooleanT{}} == TypeResolver.resolve(boolean())
    end

    test "resolves a byte built in type remotely" do
      assert {:ok, %Types.RangeL{from: 0, to: 255} |> with_remote(AllTypes, :b_f)} ==
               TypeResolver.resolve(AllTypes.b_f())
    end

    test "resolves a byte built in type directly" do
      assert {:ok, %Types.RangeL{from: 0, to: 255}} == TypeResolver.resolve(byte())
    end

    test "resolves a char built in type remotely" do
      assert {:ok, %Types.RangeL{from: 0, to: 0x10FFFF} |> with_remote(AllTypes, :b_g)} ==
               TypeResolver.resolve(AllTypes.b_g())
    end

    test "resolves a char built in type directly" do
      assert {:ok, %Types.RangeL{from: 0, to: 0x10FFFF}} == TypeResolver.resolve(char())
    end

    test "resolves a charlist built in type remotely" do
      assert {:ok,
              %Types.ListT{inner: %Types.RangeL{from: 0, to: 0x10FFFF}}
              |> with_remote(AllTypes, :b_h)} ==
               TypeResolver.resolve(AllTypes.b_h())
    end

    test "resolves a charlist built in type directly" do
      assert {:ok, %Types.ListT{inner: %Types.RangeL{from: 0, to: 0x10FFFF}}} ==
               TypeResolver.resolve(charlist())
    end

    test "resolves a nonempty charlist built in type remotely" do
      assert {:ok,
              %Types.NonemptyListT{inner: %Types.RangeL{from: 0, to: 0x10FFFF}}
              |> with_remote(AllTypes, :b_i)} ==
               TypeResolver.resolve(AllTypes.b_i())
    end

    test "resolves a nonempty charlist built in type directly" do
      assert {:ok, %Types.NonemptyListT{inner: %Types.RangeL{from: 0, to: 0x10FFFF}}} ==
               TypeResolver.resolve(nonempty_charlist())
    end

    test "resolves a fun built in type remotely" do
      assert {:ok, %Types.FunctionL{arity: :any} |> with_remote(AllTypes, :b_j)} ==
               TypeResolver.resolve(AllTypes.b_j())
    end

    test "resolves a fun built in type directly" do
      assert {:ok, %Types.FunctionL{arity: :any}} == TypeResolver.resolve(fun())
    end

    test "resolves a function built in type remotely" do
      assert {:ok, %Types.FunctionL{arity: :any} |> with_remote(AllTypes, :b_k)} ==
               TypeResolver.resolve(AllTypes.b_k())
    end

    test "resolves a function built in type directly" do
      assert {:ok, %Types.FunctionL{arity: :any}} == TypeResolver.resolve(function())
    end

    test "resolves a identifier built in type remotely" do
      assert {:ok, %Types.FunctionL{arity: :any} |> with_remote(AllTypes, :b_k)} ==
               TypeResolver.resolve(AllTypes.b_k())
    end

    test "resolves a identifier built in type directly" do
      assert {:ok, %Types.FunctionL{arity: :any}} == TypeResolver.resolve(function())
    end

    test "resolves a iodata built in type remotely" do
      assert {:ok,
              %Types.UnionT{
                inner: [
                  %Types.UnionT{
                    inner: [
                      %Types.MaybeImproperListT{
                        termination: %Types.UnionT{
                          inner: [%Types.BinaryT{}, %Types.EmptyListL{}]
                        },
                        inner: %Types.UnionT{
                          inner: [%Types.RangeL{to: 255, from: 0}, %Types.BinaryT{}]
                        }
                      }
                    ]
                  },
                  %Types.BinaryT{}
                ]
              }
              |> with_remote(AllTypes, :b_m)} == TypeResolver.resolve(AllTypes.b_m())
    end

    test "resolves a iodata built in type directly" do
      assert {:ok,
              %Types.UnionT{
                inner: [
                  %Types.UnionT{
                    inner: [
                      %Types.MaybeImproperListT{
                        termination: %Types.UnionT{
                          inner: [%Types.BinaryT{}, %Types.EmptyListL{}]
                        },
                        inner: %Types.UnionT{
                          inner: [%Types.RangeL{to: 255, from: 0}, %Types.BinaryT{}]
                        }
                      }
                    ]
                  },
                  %Types.BinaryT{}
                ]
              }} == TypeResolver.resolve(iodata())
    end

    test "resolves a iolsit built in type remotely" do
      assert {:ok,
              %Types.UnionT{
                inner: [
                  %Types.MaybeImproperListT{
                    termination: %Types.UnionT{
                      inner: [%Types.BinaryT{}, %Types.EmptyListL{}]
                    },
                    inner: %Types.UnionT{
                      inner: [%Types.RangeL{to: 255, from: 0}, %Types.BinaryT{}]
                    }
                  }
                ]
              }
              |> with_remote(AllTypes, :b_n)} == TypeResolver.resolve(AllTypes.b_n())
    end

    test "resolves a iolist built in type directly" do
      assert {:ok,
              %Types.UnionT{
                inner: [
                  %Types.MaybeImproperListT{
                    termination: %Types.UnionT{
                      inner: [%Types.BinaryT{}, %Types.EmptyListL{}]
                    },
                    inner: %Types.UnionT{
                      inner: [%Types.RangeL{to: 255, from: 0}, %Types.BinaryT{}]
                    }
                  }
                ]
              }} == TypeResolver.resolve(iolist())
    end

    test "resolves a keyword built in type remotely" do
      assert {:ok,
              %Types.ListT{inner: [%Types.TupleT{inner: [%Types.AtomT{}, %Types.AnyT{}]}]}
              |> with_remote(AllTypes, :b_o)} ==
               TypeResolver.resolve(AllTypes.b_o())
    end

    test "resolves a keyword built in type directly" do
      assert {:ok, %Types.ListT{inner: [%Types.TupleT{inner: [%Types.AtomT{}, %Types.AnyT{}]}]}} ==
               TypeResolver.resolve(keyword())
    end

    test "resolves a keyword list built in type remotely" do
      assert {:ok,
              %Types.ListT{inner: [%Types.TupleT{inner: [%Types.AtomT{}, %Types.IntegerT{}]}]}
              |> with_remote(AllTypes, :b_p)} ==
               TypeResolver.resolve(AllTypes.b_p())
    end

    test "resolves a keyword list built in type directly" do
      assert {:ok,
              %Types.ListT{inner: [%Types.TupleT{inner: [%Types.AtomT{}, %Types.IntegerT{}]}]}} ==
               TypeResolver.resolve(keyword(integer()))
    end

    test "resolves a list built in type remotely" do
      assert {:ok, %Types.ListT{inner: [%Types.AnyT{}]} |> with_remote(AllTypes, :b_q)} ==
               TypeResolver.resolve(AllTypes.b_q())
    end

    test "resolves a list built in type directly" do
      assert {:ok, %Types.ListT{inner: [%Types.AnyT{}]}} == TypeResolver.resolve(list())
    end

    test "resolves a nonempty list built in type remotely" do
      assert {:ok, %Types.NonemptyListT{inner: %Types.AnyT{}} |> with_remote(AllTypes, :b_r)} ==
               TypeResolver.resolve(AllTypes.b_r())
    end

    test "resolves a nonempty list built in type directly" do
      assert {:ok, %Types.NonemptyListT{inner: %Types.AnyT{}}} ==
               TypeResolver.resolve(nonempty_list())
    end

    test "resolves a maybe improper list built in type remotely" do
      assert {:ok,
              %Types.MaybeImproperListT{inner: [%Types.AnyT{}]} |> with_remote(AllTypes, :b_s)} ==
               TypeResolver.resolve(AllTypes.b_s())
    end

    test "resolves a maybe improper list built in type directly" do
      assert {:ok, %Types.MaybeImproperListT{inner: [%Types.AnyT{}]}} ==
               TypeResolver.resolve(maybe_improper_list())
    end

    test "resolves a nomepty maybe improper list built in type remotely" do
      assert {:ok,
              %Types.NonemptyMaybeImproperListT{inner: [%Types.AnyT{}]}
              |> with_remote(AllTypes, :b_t)} ==
               TypeResolver.resolve(AllTypes.b_t())
    end

    test "resolves a nomepty maybe improper list built in type directly" do
      assert {:ok, %Types.NonemptyMaybeImproperListT{inner: [%Types.AnyT{}]}} ==
               TypeResolver.resolve(nonempty_maybe_improper_list())
    end

    test "resolves a mfa built in type remotely" do
      assert {:ok,
              %TypeResolver.Types.TupleT{
                inner: [
                  %TypeResolver.Types.AtomT{},
                  %TypeResolver.Types.AtomT{},
                  %TypeResolver.Types.RangeL{to: 255, from: 0}
                ]
              }
              |> with_remote(AllTypes, :b_u)} == TypeResolver.resolve(AllTypes.b_u())
    end

    test "resolves a mfa built in type directly" do
      assert {:ok,
              %TypeResolver.Types.TupleT{
                inner: [
                  %TypeResolver.Types.AtomT{},
                  %TypeResolver.Types.AtomT{},
                  %TypeResolver.Types.RangeL{to: 255, from: 0}
                ]
              }} == TypeResolver.resolve(mfa())
    end

    test "resolves a module built in type remotely" do
      assert {:ok, %Types.AtomT{} |> with_remote(AllTypes, :b_v)} ==
               TypeResolver.resolve(AllTypes.b_v())
    end

    test "resolves a module built in type directly" do
      assert {:ok, %Types.AtomT{}} == TypeResolver.resolve(module())
    end

    test "resolves a no_return built in type remotely" do
      assert {:ok, %Types.NoneT{} |> with_remote(AllTypes, :b_w)} ==
               TypeResolver.resolve(AllTypes.b_w())
    end

    test "resolves a no_return built in type directly" do
      assert {:ok, %Types.NoneT{}} == TypeResolver.resolve(no_return())
    end

    test "resolves a node built in type remotely" do
      assert {:ok, %Types.AtomT{} |> with_remote(AllTypes, :b_x)} ==
               TypeResolver.resolve(AllTypes.b_x())
    end

    test "resolves a node built in type directly" do
      assert {:ok, %Types.AtomT{}} == TypeResolver.resolve(node())
    end

    test "resolves a number built in type remotely" do
      assert {:ok,
              %Types.UnionT{inner: [%Types.IntegerT{}, %Types.FloatT{}]}
              |> with_remote(AllTypes, :b_y)} ==
               TypeResolver.resolve(AllTypes.b_y())
    end

    test "resolves a number built in type directly" do
      assert {:ok, %Types.UnionT{inner: [%Types.IntegerT{}, %Types.FloatT{}]}} ==
               TypeResolver.resolve(number())
    end

    test "resolves a struct built in type remotely" do
      assert {:ok,
              %TypeResolver.Types.MapL{
                inner: [
                  %TypeResolver.Types.MapFieldExactL{
                    v: %TypeResolver.Types.AtomT{},
                    k: %TypeResolver.Types.AtomL{value: :__struct__}
                  },
                  %TypeResolver.Types.MapFieldAssocL{
                    v: %TypeResolver.Types.AnyT{},
                    k: %TypeResolver.Types.AtomT{}
                  }
                ]
              }
              |> with_remote(AllTypes, :b_z)} == TypeResolver.resolve(AllTypes.b_z())
    end

    test "resolves a struct built in type directly" do
      assert {:ok,
              %TypeResolver.Types.MapL{
                inner: [
                  %TypeResolver.Types.MapFieldExactL{
                    v: %TypeResolver.Types.AtomT{},
                    k: %TypeResolver.Types.AtomL{value: :__struct__}
                  },
                  %TypeResolver.Types.MapFieldAssocL{
                    v: %TypeResolver.Types.AnyT{},
                    k: %TypeResolver.Types.AtomT{}
                  }
                ]
              }} == TypeResolver.resolve(struct())
    end

    test "resolves a timeout built in type remotely" do
      assert {:ok,
              %TypeResolver.Types.UnionT{
                inner: [
                  %TypeResolver.Types.AtomL{value: :infinity},
                  %TypeResolver.Types.NonNegIntegerT{}
                ]
              }
              |> with_remote(AllTypes, :b_1)} == TypeResolver.resolve(AllTypes.b_1())
    end

    test "resolves a timeout built in type directly" do
      assert {:ok,
              %TypeResolver.Types.UnionT{
                inner: [
                  %TypeResolver.Types.AtomL{value: :infinity},
                  %TypeResolver.Types.NonNegIntegerT{}
                ]
              }} == TypeResolver.resolve(timeout())
    end

    test "resolves a remote type remotely" do
      assert {:ok, %Types.BinaryT{} |> with_remote(String, :t) |> with_remote(AllTypes, :r_a)} ==
               TypeResolver.resolve(AllTypes.r_a())
    end

    test "resolves a remote type directly" do
      assert {:ok, %Types.BinaryT{} |> with_remote(String, :t)} ==
               TypeResolver.resolve(String.t())
    end

    test "resolves a remote type within another type remotely" do
      assert {:ok,
              %Types.UnionT{
                inner: [
                  %Types.BinaryT{}
                  |> with_remote(Types2, :a)
                  |> with_remote(TypeResolver.Test.Types, :a),
                  %Types.IntegerT{}
                ]
              }
              |> with_remote(AllTypes, :r_b)} ==
               TypeResolver.resolve(AllTypes.r_b())
    end

    test "resolves a remote type within another type directly" do
      assert {:ok,
              %Types.UnionT{
                inner: [
                  %Types.NamedType{
                    module: T,
                    name: :a,
                    inner: %Types.NamedType{
                      inner: %Types.BinaryT{},
                      module: TypeResolver.Test.Types2,
                      name: :a
                    }
                  },
                  %Types.IntegerT{}
                ]
              }} ==
               TypeResolver.resolve(T.a() | integer())
    end

    test "resolve a local remote type remotely" do
      assert {:ok, %Types.AnyT{} |> with_remote(AllTypes, :r_c)} ==
               TypeResolver.resolve(AllTypes.r_c())
    end

    test "resolve a local remote type directly" do
      assert {:ok, %Types.BinaryT{} |> with_remote(TypeResolverTest, :my_type)} ==
               TypeResolver.resolve(my_type())
    end

    test "resolve a indrect local remote type directly" do
      assert {
               :ok,
               %TypeResolver.Types.NamedType{
                 inner: %TypeResolver.Types.NamedType{
                   inner: %TypeResolver.Types.BinaryT{},
                   module: TypeResolverTest,
                   name: :my_type_there
                 },
                 module: TypeResolverTest,
                 name: :my_type_here
               }
             } ==
               TypeResolver.resolve(my_type_here())
    end

    test "resolves a remote type with parameter remotely" do
      assert {:ok,
              %TypeResolver.Types.UnionT{
                inner: [
                  %TypeResolver.Types.BinaryT{},
                  %TypeResolver.Types.ListT{inner: %TypeResolver.Types.BinaryT{}}
                ]
              }
              |> with_remote(AllTypes, :r_d)} == TypeResolver.resolve(AllTypes.r_d(binary()))
    end

    test "resolves a remote type with parameter locally" do
      assert {
               :ok,
               %TypeResolver.Types.NamedType{
                 inner: %TypeResolver.Types.UnionT{
                   inner: [
                     %TypeResolver.Types.BinaryT{},
                     %TypeResolver.Types.ListT{inner: %TypeResolver.Types.BinaryT{}}
                   ]
                 },
                 module: TypeResolverTest,
                 name: :my_param
               }
             } == TypeResolver.resolve(my_param(binary()))
    end

    test "resolve a very complex remote type remotely" do
      assert {
               :ok,
               %TypeResolver.Types.NamedType{
                 name: :r_e,
                 module: AllTypes,
                 inner: %TypeResolver.Types.UnionT{
                   inner: [
                     %TypeResolver.Types.AtomL{value: :hello},
                     %TypeResolver.Types.NamedType{
                       name: :maybe_t,
                       module: TypeResolver.Test.Types,
                       inner: %TypeResolver.Types.UnionT{
                         inner: [
                           %TypeResolver.Types.NamedType{
                             name: :a,
                             module: TypeResolver.Test.Types2,
                             inner: %TypeResolver.Types.BinaryT{}
                           },
                           %TypeResolver.Types.NilL{},
                           %TypeResolver.Types.ListT{
                             inner: %TypeResolver.Types.AtomL{value: :hello}
                           }
                         ]
                       }
                     }
                   ]
                 }
               }
             } == TypeResolver.resolve(AllTypes.r_e(:hello))
    end
  end

  def with_remote(t, module, name) do
    %Types.NamedType{
      module: module,
      name: name,
      inner: t
    }
  end
end
