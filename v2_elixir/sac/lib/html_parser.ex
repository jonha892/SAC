defmodule SAC.HTMLParser do
  alias SAC.Util

  def parse_response(%Finch.Response{body: body, headers: _, status: 200}) do
    Floki.parse_document body
  end

  def movies(document) do
    a_elements = Floki.find(document, "a")
    Floki.attribute(a_elements, "href") |> filter_hrefs
  end

  # TODO Logging
  def is_movie_bookable?(document) do
    title = Floki.find(document, "title") |> Floki.text |> Util.transform_title
    #IO.inspect(title)

    playtime = Floki.find(document, "movie-detail-page") |> Floki.find(".playtimes-movie-item-component") |> Floki.find("span") |> Floki.find(".time") |> Floki.text



    single_date = Floki.find(document, "movie-detail-page") |> Floki.find(".date-holder") |> Floki.find(".select-single") |> Floki.text |> String.trim
    multiple_dates = Floki.find(document, "movie-detail-page") |> Floki.find(".date-holder") |> Floki.find("option") |> Enum.map(fn x -> x |> Floki.text |> String.trim end)

    dates = if single_date == "", do: multiple_dates, else: [single_date]
    #IO.inspect(playtime)
    #IO.inspect(dates)

    case playtime do
      "" -> %{bookable: false}
      _ -> %{bookable: true, title: title, first_playtime: playtime, dates: dates}
    end
  end

  defp filter_hrefs(hrefs) do
    # TODO refactor
    Enum.filter(hrefs, fn x -> String.match?(x, ~r/^\/movie\//) end) |> Enum.uniq
  end
end
