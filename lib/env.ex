defmodule TypeResolver.Env do
  @moduledoc """
  This module defines the environment that is used to
  resolve types.

  It consists of the following:

  - a target module the currently resolved types resides in
  - a lookup of user types of the current module
  - maybe the args for current the type 
  """
  use TypedStruct

  alias __MODULE__

  typedstruct do
    field(:target_module, module())
    field(:user_types, map())
    field(:args, map() | nil)
    field(:caller, map())
  end

  @spec make(module(), map(), map()) :: Env.t()
  def make(target, user_types, caller \\ %{}) do
    %Env{target_module: target, user_types: user_types, caller: caller}
  end

  @spec with_target_module(Env.t(), module()) :: Env.t()
  def with_target_module(env, module) do
    %Env{env | target_module: module}
  end

  @spec with_user_types(Env.t(), map()) :: Env.t()
  def with_user_types(env, user_types) do
    %Env{env | user_types: user_types}
  end

  @spec get_user_type(Env.t(), atom()) :: nil | any()
  def get_user_type(env, type) do
    env.user_types[type]
  end

  @spec with_args(Env.t(), map()) :: Env.t()
  def with_args(env, params) do
    %Env{env | args: params}
  end

  def clear_user_types(env), do: with_user_types(env, %{})
end
