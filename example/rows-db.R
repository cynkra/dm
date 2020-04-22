data <- memdb_frame(a = 1:3, b = letters[c(1:2, NA)], c = 0.5 + 0:2)

try(rows_insert(data, a = 4, b = "z"))
rows_insert(data, a = 4, b = "z", .copy = TRUE)
rows_update(data, a = 2:3, b = "w", .copy = TRUE, .persist = FALSE)

rows_insert(data, memdb_frame(a = 4, b = "z"), .persist = TRUE)
data
rows_update(data, memdb_frame(a = 2:3, b = "w"), .persist = TRUE)
data
