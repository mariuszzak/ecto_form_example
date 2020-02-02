defmodule TestForm.CreateArticleForm do
  use Ecto.Schema
  import Ecto.Changeset
  alias TestForm.CreateArticleForm.Author

  embedded_schema do
    field(:title, :string)
    field(:body, :string)
    embeds_one(:author, Author)
  end

  @params_required [:title]
  @params_optional [:body]

  def validate(params) do
    case changeset(%__MODULE__{}, params) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      %{valid?: false} = changeset ->
        {:error, render_errors(changeset)}
    end
  end

  defp render_errors(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def changeset(schema, params) do
    schema
    |> cast(params, @params_optional ++ @params_required)
    |> cast_embed(:author)
    |> validate_required(@params_required)
  end
end
