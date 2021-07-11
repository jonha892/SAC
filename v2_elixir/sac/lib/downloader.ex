defmodule SAC.Downloader do
  @base_url Application.fetch_env!(:sac, :savoy_base_url)
  @program_url Application.fetch_env!(:sac, :savoy_programm_url)

  def download_preview_page do
    Finch.build(:get, @program_url) |> Finch.request(MyFinch)
  end

  def download_movie_page(movie_path) do
    combined_url = @base_url <> movie_path
    Finch.build(:get, combined_url) |> Finch.request(MyFinch)
  end
end
