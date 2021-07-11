defmodule SACTest do
  use ExUnit.Case
  doctest SAC

  test "test mail" do
    email = SAC.Email.test_mail()
    IO.inspect(email)
  end

  @tag :wip
  test "process single movie page" do
    assert true
  end
end
