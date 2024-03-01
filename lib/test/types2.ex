defmodule TypeResolver.Test.Types2 do
  @type a :: binary()
  @type b(t) :: integer() | t
end
