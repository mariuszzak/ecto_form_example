defmodule TestFormTest do
  use ExUnit.Case
  doctest TestForm

  test "greets the world" do
    assert TestForm.hello() == :world
  end
end
