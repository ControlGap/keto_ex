defmodule KetoEx do
  @moduledoc """
  Ory Keto REST API client

  https://www.ory.sh/keto/docs/reference/api
  """

  alias KetoEx.{Role, Policy}
  @base "/engines/acp/ory/"
  @flavors [:exact, :glob, :regex]

  @default_flavor :glob

  @type flavor :: :exact | :glob | :regex
  @type check_allowed_input :: %{
          subject: Strting.t(),
          action: Strting.t(),
          resource: Strting.t(),
          context: map()
        }

  @doc """
  Create a tesla client to be passed into all the other functions
  """
  @spec client(any, nil | maybe_improper_list | map) :: Tesla.Client.t()
  def client(host \\ "localhost", opts \\ [port: 4466, scheme: "http"]) do
    port = opts[:port] || 4466
    scheme = opts[:scheme] || "http"

    middleware = [
      {Tesla.Middleware.BaseUrl, "#{scheme}://#{host}:#{port}"},
      {Tesla.Middleware.JSON, engine_opts: [keys: :atoms!]}
    ]

    Tesla.client(middleware)
  end

  @doc """
  Generate a request map (subject, action, resource) with an optional context
  """
  @spec request(
          subject :: String.t(),
          action :: String.t(),
          resource :: String.t(),
          context :: map()
        ) :: check_allowed_input()
  def request(subject, action, resource, context \\ %{}) do
    %{subject: subject, action: action, resource: resource, context: context}
  end

  @doc """
  Check if a request is allowed

  https://www.ory.sh/keto/docs/reference/api#check-if-a-request-is-allowed
  """
  @spec allowed?(client :: Tesla.Client.t(), policy :: check_allowed_input(), flavor :: flavor()) ::
          {:error, any} | true | false
  def allowed?(client, policy, flavor \\ @default_flavor) when flavor in @flavors do
    client
    |> Tesla.post(@base <> "#{flavor}/allowed", policy)
    |> handle_response()
  end

  @doc """
  List Access Control Policies (ACP)

  Optional params: `limit`, `offset`, `subject`, `resource`, `action`

  https://www.ory.sh/keto/docs/reference/api#listoryaccesscontrolpolicies
  """
  @spec list_acp(client :: Tesla.Client.t(), flavor :: flavor(), params :: Keyword.t()) ::
          {:error, any} | {:ok, [Policy.t()]}
  def list_acp(client, flavor \\ @default_flavor, params \\ []) when flavor in @flavors do
    client
    |> Tesla.get(@base <> "#{flavor}/policies", query: params)
    |> handle_response(Policy)
  end

  @doc """
  Upsert an ACP

  https://www.ory.sh/keto/docs/reference/api#upsertoryaccesscontrolpolicy
  """
  @spec upsert_acp(client :: Tesla.Client.t(), policy :: map(), flavor :: flavor()) ::
          {:error, any} | {:ok, Policy.t()}
  def upsert_acp(client, policy, flavor \\ @default_flavor) when flavor in @flavors do
    client
    |> Tesla.put(@base <> "#{flavor}/policies", policy)
    |> handle_response(Policy)
  end

  @doc """
  Fetch ACP via ID

  https://www.ory.sh/keto/docs/reference/api#getoryaccesscontrolpolicy
  """
  @spec get_acp(client :: Tesla.Client.t(), policy_id :: String.t(), flavor :: flavor()) ::
          {:error, any} | {:ok, Policy.t()}
  def get_acp(client, policy_id, flavor \\ @default_flavor) when flavor in @flavors do
    client
    |> Tesla.get(@base <> "#{flavor}/policies/#{policy_id}")
    |> handle_response(Policy)
  end

  @doc """
  Delete ACP via ID

  https://www.ory.sh/keto/docs/reference/api#deleteoryaccesscontrolpolicy
  """
  @spec delete_acp(client :: Tesla.Client.t(), policy_id :: String.t(), flavor :: flavor()) ::
          {:error, any} | {:ok, any}
  def delete_acp(client, policy_id, flavor \\ @default_flavor) when flavor in @flavors do
    client
    |> Tesla.delete(@base <> "#{flavor}/policies/#{policy_id}")
    |> handle_response()
  end

  @doc """
  List Access Control Policy Roles

  Optional params: `limit`, `offset`, `member`

  https://www.ory.sh/keto/docs/reference/api#list-ory-access-control-policy-roles
  """
  @spec list_acp_roles(client :: Tesla.Client.t(), flavor :: flavor(), params :: Keyword.t()) ::
          {:error, any} | {:ok, [Role.t()]}
  def list_acp_roles(client, flavor \\ @default_flavor, params \\ []) when flavor in @flavors do
    client
    |> Tesla.get(@base <> "#{flavor}/roles", query: params)
    |> handle_response(Role)
  end

  @doc """
  Upsert an ACP Role

  https://www.ory.sh/keto/docs/reference/api#upsert-an-ory-access-control-policy-role
  """
  @spec upsert_acp_role(
          client :: Tesla.Client.t(),
          role :: map(),
          flavor :: flavor()
        ) :: {:error, any} | {:ok, Role.t()}
  def upsert_acp_role(client, role, flavor \\ @default_flavor) when flavor in @flavors do
    client
    |> Tesla.put(@base <> "#{flavor}/roles", role)
    |> handle_response(Role)
  end

  @doc """
  Fetch ACP Role via ID

  https://www.ory.sh/keto/docs/reference/api#get-an-ory-access-control-policy-role
  """
  @spec get_acp_role(client :: Tesla.Client.t(), role_id :: String.t(), flavor :: flavor()) ::
          {:error, any} | {:ok, Role.t()}
  def get_acp_role(client, role_id, flavor \\ @default_flavor) when flavor in @flavors do
    client
    |> Tesla.get(@base <> "#{flavor}/roles/#{role_id}")
    |> handle_response(Role)
  end

  @doc """
  Delete ACP Role via ID

  https://www.ory.sh/keto/docs/reference/api#delete-an-ory-access-control-policy-role
  """
  @spec delete_acp_role(
          client :: Tesla.Client.t(),
          role_id :: String.t(),
          flavor :: flavor()
        ) :: {:error, any} | {:ok, any}
  def delete_acp_role(client, role_id, flavor \\ @default_flavor) when flavor in @flavors do
    client
    |> Tesla.delete(@base <> "#{flavor}/roles/#{role_id}")
    |> handle_response()
  end

  @doc """
  Add a member to an ACP Role

  https://www.ory.sh/keto/docs/reference/api#add-a-member-to-an-ory-access-control-policy-role
  """
  @spec add_member_to_acp_role(
          client :: Tesla.Client.t(),
          role_id :: String.t(),
          body :: map(),
          flavor :: flavor()
        ) :: {:error, any} | {:ok, any}
  def add_member_to_acp_role(client, role_id, body, flavor \\ @default_flavor)
      when flavor in @flavors do
    client
    |> Tesla.put(@base <> "#{flavor}/roles/#{role_id}/members", body)
    |> handle_response(Role)
  end

  @doc """
  Remove a member from an ACP Role

  https://www.ory.sh/keto/docs/reference/api#remove-a-member-from-an-ory-access-control-policy-role
  """
  @spec remove_member_from_acp_role(
          client :: Tesla.Client.t(),
          role_id :: String.t(),
          member_id :: String.t(),
          flavor :: flavor()
        ) :: {:error, any} | {:ok, any}
  def remove_member_from_acp_role(client, role_id, member_id, flavor \\ @default_flavor)
      when flavor in @flavors do
    client
    |> Tesla.delete(@base <> "#{flavor}/roles/#{role_id}/members/#{member_id}")
    |> handle_response()
  end

  @doc """
  Alive health check

  https://www.ory.sh/keto/docs/reference/api#health
  """
  @spec health_alive(client :: Tesla.Client.t()) :: {:error, any} | {:ok, map()}
  def health_alive(client) do
    client
    |> Tesla.get("/health/alive")
    |> handle_response()
  end

  @doc """
  Ready health check

  https://www.ory.sh/keto/docs/reference/api#health
  """
  @spec health_ready(client :: Tesla.Client.t()) :: {:error, any} | {:ok, map()}
  def health_ready(client) do
    client
    |> Tesla.get("/health/ready")
    |> handle_response()
  end

  @doc """
  Fetch version number
  """
  @spec version(client :: Tesla.Client.t()) :: {:error, any} | {:ok, map()}
  def version(client) do
    client
    |> Tesla.get("/version")
    |> handle_response()
  end

  # if this is an allowed? response - just return the boolean.
  defp handle_response({:ok, %Tesla.Env{status: status, body: %{allowed: allowed?}}})
       when status in [200, 403],
       do: allowed?

  # all other cases return a error/success tuple.
  defp handle_response({:ok, %Tesla.Env{status: 200, body: body}}), do: {:ok, body}
  defp handle_response({:ok, %Tesla.Env{status: 204}}), do: :ok
  defp handle_response({:ok, %Tesla.Env{status: 404, body: _body}}), do: {:error, "not found"}

  defp handle_response({:ok, %Tesla.Env{status: _, body: body}}),
    do: {:error, body}

  defp handle_response({:error, :econnrefused}) do
    {:error, "Connection to Keto Refused - ensure `client/2` is called with the correct hostname"}
  end

  defp handle_response(err), do: err

  # when a struct is passed into this fn, returns a struct,
  defp handle_response({:ok, %Tesla.Env{status: 200, body: body}}, a_struct) when is_list(body),
    do: {:ok, Enum.map(body, &Kernel.struct(a_struct, &1))}

  defp handle_response({:ok, %Tesla.Env{status: 200, body: body}}, a_struct),
    do: {:ok, Kernel.struct(a_struct, body)}

  defp handle_response({:ok, %Tesla.Env{status: 404, body: _body}}, _a_struct),
    do: {:error, "not found"}

  defp handle_response({:ok, %Tesla.Env{status: 500, body: _body}}, _a_struct) do
    {:error, "Server error"}
  end

  defp handle_response({:ok, %Tesla.Env{status: _, body: body}}, _a_struct) do
    {:error, body}
  end

  defp handle_response({:error, :econnrefused}, _a_struct) do
    {:error, "Connection to Keto Refused - ensure `client/2` is called with the correct hostname"}
  end

  defp handle_response(err, _struct), do: err
end
