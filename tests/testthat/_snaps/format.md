# output

    Code
      commas(character())
    Output
      
    Code
      commas(letters[1])
    Output
      a
    Code
      commas(letters[1:2])
    Output
      a, b
    Code
      commas(letters[1:3])
    Output
      a, b, c
    Code
      commas(letters[seq_len(MAX_COMMAS - 1)])
    Output
      a, b, c, d, e
    Code
      commas(letters[seq_len(MAX_COMMAS)])
    Output
      a, b, c, d, e, f
    Code
      commas(letters[seq_len(MAX_COMMAS + 1)])
    Output
      a, b, c, d, e, ... (7 total)
    Code
      commas(letters[1:4], max_commas = 3)
    Output
      a, b, ... (4 total)
    Code
      commas(letters, capped = TRUE)
    Output
      a, b, c, d, e, ...
    Code
      commas(letters, fun = tick)
    Output
      `a`, `b`, `c`, `d`, `e`, ... (26 total)

