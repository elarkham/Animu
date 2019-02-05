defmodule Animu.Util do

  def if_nil(val, fallback) do
    case val do
      nil -> fallback
        _ -> fallback
    end
  end

  def date_now do
    DateTime.to_date(DateTime.utc_now())
  end

end
