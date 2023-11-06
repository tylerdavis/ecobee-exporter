defmodule EcobeeWeb.SessionLiveTest do
  use EcobeeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ecobee.AuthenticationFixtures

  @create_attrs %{pin: "some pin"}
  @update_attrs %{pin: "some updated pin"}
  @invalid_attrs %{pin: nil}

  defp create_session(_) do
    session = session_fixture()
    %{session: session}
  end

  describe "Index" do
    setup [:create_session]

    test "lists all sessions", %{conn: conn, session: session} do
      {:ok, _index_live, html} = live(conn, ~p"/sessions")

      assert html =~ "Listing Sessions"
      assert html =~ session.pin
    end

    test "saves new session", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/sessions")

      assert index_live |> element("a", "New Session") |> render_click() =~
               "New Session"

      assert_patch(index_live, ~p"/sessions/new")

      assert index_live
             |> form("#session-form", session: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#session-form", session: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/sessions")

      html = render(index_live)
      assert html =~ "Session created successfully"
      assert html =~ "some pin"
    end

    test "updates session in listing", %{conn: conn, session: session} do
      {:ok, index_live, _html} = live(conn, ~p"/sessions")

      assert index_live |> element("#sessions-#{session.id} a", "Edit") |> render_click() =~
               "Edit Session"

      assert_patch(index_live, ~p"/sessions/#{session}/edit")

      assert index_live
             |> form("#session-form", session: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#session-form", session: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/sessions")

      html = render(index_live)
      assert html =~ "Session updated successfully"
      assert html =~ "some updated pin"
    end

    test "deletes session in listing", %{conn: conn, session: session} do
      {:ok, index_live, _html} = live(conn, ~p"/sessions")

      assert index_live |> element("#sessions-#{session.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#sessions-#{session.id}")
    end
  end

  describe "Show" do
    setup [:create_session]

    test "displays session", %{conn: conn, session: session} do
      {:ok, _show_live, html} = live(conn, ~p"/sessions/#{session}")

      assert html =~ "Show Session"
      assert html =~ session.pin
    end

    test "updates session within modal", %{conn: conn, session: session} do
      {:ok, show_live, _html} = live(conn, ~p"/sessions/#{session}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Session"

      assert_patch(show_live, ~p"/sessions/#{session}/show/edit")

      assert show_live
             |> form("#session-form", session: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#session-form", session: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/sessions/#{session}")

      html = render(show_live)
      assert html =~ "Session updated successfully"
      assert html =~ "some updated pin"
    end
  end
end
