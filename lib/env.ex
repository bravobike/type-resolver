defmodule TypeResolver.Env do
  use TypedStruct

  alias __MODULE__

  typedstruct do
    field(:target_module, module())
    field(:caller_module, module())
    field(:user_types, map())
    field(:args, map())
  end

  @spec make(module(), module(), map()) :: Env.t()
  def make(target, current, user_types) do
    %Env{target_module: target, caller_module: current, user_types: user_types}
  end

  @spec with_target_module(Env.t(), module()) :: Env.t()
  def with_target_module(env, module) do
    %Env{env | target_module: module}
  end

  @spec with_caller_module(Env.t(), module()) :: Env.t()
  def with_caller_module(env, module) do
    %Env{env | caller_module: module}
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
end
