# KetoEx

[ORY Keto](https://www.ory.sh/keto/) HTTP Client built with Tesla

## Example

```elixir
# create a client instance
client = KetoEx.client()

# list access control policies
{:ok, []} = KetoEx.list_acp(client)

# upsert a new policy
policy = %{
  subjects: ["user1"],
  actions: ["read"],
  resources: ["posts"],
  description: "user1 is allowed to read posts",
  effect: "allow"
}

{:ok, %KetoEx.Policy{}} = KetoEx.upsert_acp(client, policy)

# Check if a request is allowed
req = KetoEx.request("user1", "read", "posts")
true = KetoEx.allowed?(client, req)

req2 = KetoEx.request("user2", "read", "posts")
false = KetoEx.allowed?(client, req2)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `keto_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:keto_ex, "~> 0.1.0"}
  ]
end
```

## Configuration

Configure Tesla with an adapter of your choice.

```elixir
import Config

config :tesla, :adapter, {Tesla.Adapter.Finch, name: KetoEx.Finch}
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/keto_ex](https://hexdocs.pm/keto_ex).
