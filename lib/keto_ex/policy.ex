defmodule KetoEx.Policy do
  @moduledoc """
  Keto Access Control Policy
  """

  @enforce_keys [:id, :actions, :conditions, :description, :effect, :resources, :subjects]

  @derive Jason.Encoder

  defstruct id: nil,
            actions: [],
            conditions: %{},
            description: "",
            effect: "",
            resources: [],
            subjects: []

  @type t() :: %__MODULE__{
          id: String.t(),
          actions: list(String.t()),
          conditions: map() | nil,
          description: String.t(),
          effect: String.t(),
          resources: list(String.t()),
          subjects: list(String.t())
        }
end
