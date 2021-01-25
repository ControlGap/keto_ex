defmodule KetoEx.Role do
  @moduledoc """
  Keto ACP Role
  """

  @enforce_keys [:id, :description, :members]

  @derive Jason.Encoder

  defstruct id: nil, description: "", members: []

  @type t() :: %__MODULE__{
          id: String.t(),
          description: String.t(),
          members: list(String.t())
        }
end
