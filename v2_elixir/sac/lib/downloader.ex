defmodule SAC.Downloader do
  @movie_base_url Application.fetch_env!(:sac, :savoy_movie_base_url)
  @program_url Application.fetch_env!(:sac, :savoy_programm_url)

  def download_preview_page do
    Finch.build(:get, @program_url) |> Finch.request(MyFinch)
  end

  def download_movie_page(movie_title) do
    combined_url = @movie_base_url <> movie_title
    Finch.build(:get, combined_url) |> Finch.request(MyFinch)
  end
end


# SAC.Checking.handle_movie("/film/the-father")
# SAC.Checking.handle_movie("/film/the-green-knight")
