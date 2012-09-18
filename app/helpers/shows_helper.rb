module ShowsHelper
  def randCSSLeft(prevLeft)
    return 0 if prevLeft <= 0
    prevLeft + rand(35..100)
  end
end