defmodule GaldWeb.PageControllerTest do
  use GaldWeb.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "Gald"
  end
end
