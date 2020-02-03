defmodule TestForm.CreateArticleForm do
  use Ecto.Schema
  import Ecto.Changeset
  alias TestForm.FormValidationError
  alias TestForm.CreateArticleForm.Author

  embedded_schema do
    field(:title, :string)
    field(:body, :string)
    embeds_one(:author, Author)
    embeds_one(:author2, Author)
    field(:remarks, :string, default: :undefined)
  end

  @params_required [:title]
  @params_optional [:body, :remarks]

  def validate(params) do
    case changeset(%__MODULE__{}, params) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      %{valid?: false} = changeset ->
        {:error, %FormValidationError{message: render_errors(changeset)}}
    end
  end

  defp render_errors(changeset) do
    traverse_errors(changeset, fn {msg, _opts} ->
      msg
    end)
  end

  def changeset(schema, params) do
    schema
    |> cast(params, @params_optional ++ @params_required, empty_values: [])
    |> cast_embed(:author, required: true)
    |> cast_embed(:author2)
    |> validate_required(@params_required)
    |> validate_optional_but_filled(:remarks)
  end

  defp validate_optional_but_filled(changeset, field) do
    case fetch_change(changeset, field) do
      {:ok, nil} ->
        add_error(changeset, field, "can't be nil if provided")

      {:ok, ""} ->
        add_error(changeset, field, "can't be empty string if provided")

      {:ok, _} ->
        changeset

      :error ->
        changeset
    end
  end
end
