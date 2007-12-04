
match [=[
  subject "Hello World!"
  with foo <- [[ "Hello" {.+} ]] do
    print(foo)
    fallthrough
  with bar <- [[ "Hello Wor" {...} ]] do
    print(bar)
  with _ <- [[ "H" .* ]] do
    print("strike 3")
  default
    print("default")
  end
]=]

