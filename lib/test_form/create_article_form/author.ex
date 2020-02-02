defmodule TestForm.CreateArticleForm.Author do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:first_name, :string)
    field(:last_name, :string)
  end

  @params_required [:first_name]
  @params_optional [:last_name]

  def changeset(schema, params) do
    schema
    |> cast(params, @params_optional ++ @params_required)
    |> validate_required(@params_required)
  end
end
