defmodule TypeResolver.Test.Types do
  alias TypeResolver.Test.Types2
  @type a :: Types2.a()
  @type b(t) :: integer() | t

  @type maybe_t(something) :: a() | nil | something
end
