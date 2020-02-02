defmodule TestForm.CreateArticleFormTest do
  use ExUnit.Case
  alias TestForm.CreateArticleForm
  alias TestForm.CreateArticleForm.Author

  @valid_params %{
    "title" => "Cool article",
    "body" => "Lorem ipsum dolor"
  }

  @valid_params_with_author Map.merge(@valid_params, %{
                              "author" => %{
                                "first_name" => "Mariusz",
                                "last_name" => "Zak"
                              }
                            })

  test "returns a tuple with :ok and casted values" do
    assert CreateArticleForm.validate(@valid_params) ==
             {:ok, %CreateArticleForm{title: "Cool article", body: "Lorem ipsum dolor"}}
  end

  test "returns an error if title is not provided" do
    params = Map.drop(@valid_params, ["title"])

    assert CreateArticleForm.validate(params) ==
             {:error, %{title: ["can't be blank"]}}
  end

  test "allows to provide an author" do
    assert CreateArticleForm.validate(@valid_params_with_author) ==
             {:ok,
              %CreateArticleForm{
                title: "Cool article",
                body: "Lorem ipsum dolor",
                author: %Author{first_name: "Mariusz", last_name: "Zak"}
              }}
  end

  test "returns an error if provided author but without first_name" do
    params = pop_in(@valid_params_with_author, ["author", "first_name"]) |> elem(1)

    assert CreateArticleForm.validate(params) ==
             {:error, %{author: %{first_name: ["can't be blank"]}}}
  end

  test "returns multiple errors" do
    params =
      @valid_params_with_author
      |> pop_in(["author", "first_name"])
      |> elem(1)
      |> Map.drop(["title"])

    assert CreateArticleForm.validate(params) ==
             {:error, %{author: %{first_name: ["can't be blank"]}, title: ["can't be blank"]}}
  end
end
