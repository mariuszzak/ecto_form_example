defmodule TestForm.CreateArticleFormTest do
  use ExUnit.Case
  alias TestForm.CreateArticleForm
  alias TestForm.CreateArticleForm.Author
  alias TestForm.FormValidationError

  @valid_params %{
    "title" => "Cool article",
    "body" => "Lorem ipsum dolor",
    "author" => %{
      "first_name" => "Mariusz",
      "last_name" => "Zak"
    }
  }

  @valid_params_with_second_author Map.merge(@valid_params, %{
                                     "author2" => %{
                                       "first_name" => "Jan",
                                       "last_name" => "Kowalski"
                                     }
                                   })

  test "returns a tuple with :ok and casted values" do
    assert CreateArticleForm.validate(@valid_params) ==
             {:ok,
              %CreateArticleForm{
                title: "Cool article",
                body: "Lorem ipsum dolor",
                author: %Author{first_name: "Mariusz", last_name: "Zak"}
              }}
  end

  test "returns an error if title is not provided" do
    params = Map.drop(@valid_params, ["title"])

    assert CreateArticleForm.validate(params) ==
             {:error, %FormValidationError{message: %{title: ["can't be blank"]}}}
  end

  test "returns an error if author is not provided" do
    params = Map.drop(@valid_params, ["author"])

    assert CreateArticleForm.validate(params) ==
             {:error, %FormValidationError{message: %{author: ["can't be blank"]}}}
  end

  test "allows to provide the second author" do
    assert CreateArticleForm.validate(@valid_params_with_second_author) ==
             {:ok,
              %CreateArticleForm{
                title: "Cool article",
                body: "Lorem ipsum dolor",
                author: %Author{first_name: "Mariusz", last_name: "Zak"},
                author2: %Author{first_name: "Jan", last_name: "Kowalski"}
              }}
  end

  test "returns an error if provided author but without first_name" do
    params = pop_in(@valid_params, ["author", "first_name"]) |> elem(1)

    assert CreateArticleForm.validate(params) ==
             {:error, %FormValidationError{message: %{author: %{first_name: ["can't be blank"]}}}}
  end

  test "returns an error if provided author2 but without first_name" do
    params = pop_in(@valid_params_with_second_author, ["author2", "first_name"]) |> elem(1)

    assert CreateArticleForm.validate(params) ==
             {:error,
              %FormValidationError{message: %{author2: %{first_name: ["can't be blank"]}}}}
  end

  test "returns multiple errors" do
    params =
      @valid_params_with_second_author
      |> pop_in(["author", "first_name"])
      |> elem(1)
      |> pop_in(["author2", "first_name"])
      |> elem(1)
      |> Map.drop(["title"])

    assert CreateArticleForm.validate(params) ==
             {:error,
              %FormValidationError{
                message: %{
                  title: ["can't be blank"],
                  author: %{first_name: ["can't be blank"]},
                  author2: %{first_name: ["can't be blank"]}
                }
              }}
  end

  test "returns ok if provided valid remarks" do
    params = Map.put(@valid_params, "remarks", "Foo bar remarks")

    assert CreateArticleForm.validate(params) ==
             {:ok,
              %CreateArticleForm{
                author: %Author{
                  first_name: "Mariusz",
                  last_name: "Zak"
                },
                author2: nil,
                body: "Lorem ipsum dolor",
                remarks: "Foo bar remarks",
                title: "Cool article"
              }}
  end

  test "returns an error if provided remarks key but with nil value" do
    params = Map.put(@valid_params, "remarks", nil)

    assert CreateArticleForm.validate(params) ==
             {:error, %FormValidationError{message: %{remarks: ["can't be nil if provided"]}}}
  end

  test "returns an error if provided remarks key but with empty value" do
    params = Map.put(@valid_params, "remarks", "")

    assert CreateArticleForm.validate(params) ==
             {:error,
              %FormValidationError{message: %{remarks: ["can't be empty string if provided"]}}}
  end
end
