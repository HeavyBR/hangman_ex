defmodule B2Web.Live.Game.Figure do
  use B2Web, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  defp hide_if_left_gt(left, level) do
    if left > level, do: "hide-component", else: ""
  end
end
