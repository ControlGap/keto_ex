defmodule KetoEx do
  @moduledoc """
  Ory Keto REST API client

  https://www.ory.sh/keto/docs/reference/api
  """
  alias KetoEx.{Role,Policy}
  @base "/engines/acp/ory/"
  @flavors [:exact, :regex, :glob, "exact", "regex", "glob"]

  @type flavor :: :exact | :regex | :glob
  @type check_allowed_input :: %{
          action: Strting.t(),
          context: map(),
          resource: Strting.t(),
          subject: Strting.t()
        }

  @spec client(any, nil | maybe_improper_list | map) :: Tesla.Client.t()
  def client(host \\ "localhost", opts \\ [port: 4466, scheme: "http"]) do
    middleware = [
      {Tesla.Middleware.BaseUrl, "#{opts[:scheme]}://#{host}:#{opts[:port]}"},
      {Tesla.Middleware.JSON, engine_opts: [keys: :atoms!]}
    ]

    Tesla.client(middleware)
  end

  @spec policy(
          action :: String.t(),
          resource :: String.t(),
          subject :: String.t(),
          context :: map()
        ) :: check_allowed_input()
  def policy(action, resource, subject, context \\ %{}) do
    %{action: action, resource: resource, subject: subject, context: context}
  end

  @spec allowed?(client :: Tesla.Client.t(), policy :: check_allowed_input(), flavor :: flavor()) ::
          {:error, any} | true | false
  def allowed?(client, policy, flavor \\ :exact) when flavor in @flavors do
    client
    |> Tesla.post(@base <> "#{flavor}/allowed", policy)
    |> handle_response()
  end

  # limit, offset, subject, resource, action
  @spec list_acp(client :: Tesla.Client.t(), flavor :: flavor(), params :: Keyword.t()) ::
          {:error, any} | {:ok, [Policy.t()]}
  def list_acp(client, flavor \\ :exact, params \\ []) when flavor in @flavors do
    client
    |> Tesla.get(@base <> "#{flavor}/policies", query: params)
    |> handle_response(Policy)
  end

  @spec upsert_acp(client :: Tesla.Client.t(), policy :: map(), flavor :: flavor()) ::
          {:error, any} | {:ok, Policy.t()}
  def upsert_acp(client, policy, flavor \\ :exact) when flavor in @flavors do
    client
    |> Tesla.put(@base <> "#{flavor}/policies", policy)
    |> handle_response(Policy)
  end

  @spec get_acp(client :: Tesla.Client.t(), policy_id :: String.t(), flavor :: flavor()) ::
          {:error, any} | {:ok, Policy.t()}
  def get_acp(client, policy_id, flavor \\ :exact) when flavor in @flavors do
    client
    |> Tesla.get(@base <> "#{flavor}/policies/#{policy_id}")
    |> handle_response(Policy)
  end

  @spec delete_acp(client :: Tesla.Client.t(), policy_id :: String.t(), flavor :: flavor()) ::
          {:error, any} | {:ok, any}
  def delete_acp(client, policy_id, flavor \\ :exact) when flavor in @flavors do
    client
    |> Tesla.delete(@base <> "#{flavor}/policies/#{policy_id}")
    |> handle_response()
  end

  # limit, offset, member
  @spec list_acp_roles(client :: Tesla.Client.t(), flavor :: flavor(), params :: Keyword.t()) ::
          {:error, any} | {:ok, [Role.t()]}
  def list_acp_roles(client, flavor \\ :exact, params \\ []) when flavor in @flavors do
    client
    |> Tesla.get(@base <> "#{flavor}/roles", query: params)
    |> handle_response(Role)
  end

  @spec upsert_acp_role(
          client :: Tesla.Client.t(),
          role :: map(),
          flavor :: flavor()
        ) :: {:error, any} | {:ok, Role.t()}
  def upsert_acp_role(client, role, flavor \\ :exact) when flavor in @flavors do
    client
    |> Tesla.put(@base <> "#{flavor}/roles", role)
    |> handle_response(Role)
  end

  @spec get_acp_role(client :: Tesla.Client.t(), role_id :: String.t(), flavor :: flavor()) ::
          {:error, any} | {:ok, Role.t()}
  def get_acp_role(client, role_id, flavor \\ :exact) when flavor in @flavors do
    client
    |> Tesla.get(@base <> "#{flavor}/roles/#{role_id}")
    |> handle_response(Role)
  end

  @spec delete_acp_role(
          client :: Tesla.Client.t(),
          role_id :: String.t(),
          flavor :: flavor()
        ) :: {:error, any} | {:ok, any}
  def delete_acp_role(client, role_id, flavor \\ :exact) when flavor in @flavors do
    client
    |> Tesla.delete(@base <> "#{flavor}/roles/#{role_id}")
    |> handle_response()
  end

  @spec add_member_to_acp_role(
          client :: Tesla.Client.t(),
          role_id :: String.t(),
          body :: map(),
          flavor :: flavor()
        ) :: {:error, any} | {:ok, any}
  def add_member_to_acp_role(client, role_id, body, flavor \\ :exact) when flavor in @flavors do
    client
    |> Tesla.put(@base <> "#{flavor}/roles/#{role_id}/members", body)
    |> handle_response()
  end

  @spec remove_member_from_acp_role(
          client :: Tesla.Client.t(),
          role_id :: String.t(),
          member_id :: String.t(),
          flavor :: flavor()
        ) :: {:error, any} | {:ok, any}
  def remove_member_from_acp_role(client, role_id, member_id, flavor \\ :exact)
      when flavor in @flavors do
    client
    |> Tesla.delete(@base <> "#{flavor}/roles/#{role_id}/members/#{member_id}")
    |> handle_response()
  end

  @spec health_alive(client :: Tesla.Client.t()) :: {:error, any} | {:ok, map()}
  def health_alive(client) do
    client
    |> Tesla.get("/health/alive")
    |> handle_response()
  end

  @spec health_ready(client :: Tesla.Client.t()) :: {:error, any} | {:ok, map()}
  def health_ready(client) do
    client
    |> Tesla.get("/health/ready")
    |> handle_response()
  end

  @spec version(client :: Tesla.Client.t()) :: {:error, any} | {:ok, map()}
  def version(client) do
    client
    |> Tesla.get("/version")
    |> handle_response()
  end

  defp handle_response({:ok, %Tesla.Env{status: 200, body: %{allowed: allowed?}}}), do: allowed?
  defp handle_response({:ok, %Tesla.Env{status: 200, body: body}}), do: {:ok, body}

  defp handle_response({:ok, %Tesla.Env{status: _, body: body}}),
    do: {:error, body}

  # when a struct is passed into this fn, returns a struct,
  defp handle_response({:ok, %Tesla.Env{status: 200, body: body}}, a_struct) when is_list(body),
    do: {:ok, Enum.map(body, &Kernel.struct(a_struct, &1))}

  defp handle_response({:ok, %Tesla.Env{status: 200, body: body}}, a_struct),
    do: {:ok, Kernel.struct(a_struct, body)}

  defp handle_response({:ok, %Tesla.Env{status: _, body: body}}, _a_struct),
    do: {:error, body}
end
