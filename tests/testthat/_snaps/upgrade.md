# error message for non-dm object

    Code
      dm_get_def(structure(list(table = "a"), class = "bogus"))
    Condition
      Error in `abort_is_not_dm()`:
      ! Required class `dm` but instead is `bogus`.

# can upgrade from v1

    Code
      def <- dm_get_def(dm_v1, quiet = TRUE)
      def <- dm_get_def(dm_v1)
    Message
      Upgrading dm object created with dm <= 0.2.1.
      Upgrading dm object created with dm <= 0.2.4.
      Upgrading dm object created with dm <= 0.3.0.
      Upgrading dm object created with dm <= 1.0.4.
    Code
      dm <- new_dm3(def)
      dm_validate(dm)
      is_zoomed(dm)
    Output
      [1] FALSE

# can upgrade zoomed from v1

    Code
      def <- dm_get_def(dm_v1_zoomed, quiet = TRUE)
      def <- dm_get_def(dm_v1_zoomed)
    Message
      Upgrading dm object created with dm <= 0.2.1.
      Upgrading dm object created with dm <= 0.2.4.
      Upgrading dm object created with dm <= 0.3.0.
      Upgrading dm object created with dm <= 1.0.4.
    Code
      dm <- new_dm3(def, zoomed = TRUE)
      dm_validate(dm)
      is_zoomed(dm)
    Output
      [1] TRUE

# can upgrade from v2

    Code
      def <- dm_get_def(dm_v2, quiet = TRUE)
      def <- dm_get_def(dm_v2)
    Message
      Upgrading dm object created with dm <= 0.2.4.
      Upgrading dm object created with dm <= 0.3.0.
      Upgrading dm object created with dm <= 1.0.4.
    Code
      dm <- new_dm3(def)
      dm_validate(dm)
      is_zoomed(dm)
    Output
      [1] FALSE

# can upgrade zoomed from v2

    Code
      def <- dm_get_def(dm_v2_zoomed, quiet = TRUE)
      def <- dm_get_def(dm_v2_zoomed)
    Message
      Upgrading dm object created with dm <= 0.2.4.
      Upgrading dm object created with dm <= 0.3.0.
      Upgrading dm object created with dm <= 1.0.4.
    Code
      dm <- new_dm3(def, zoomed = TRUE)
      dm_validate(dm)
      is_zoomed(dm)
    Output
      [1] TRUE

# can upgrade from v3

    Code
      def <- dm_get_def(dm_v3, quiet = TRUE)
      def <- dm_get_def(dm_v3)
    Message
      Upgrading dm object created with dm <= 0.3.0.
      Upgrading dm object created with dm <= 1.0.4.
    Code
      dm <- new_dm3(def)
      dm_validate(dm)
      is_zoomed(dm)
    Output
      [1] FALSE

# can upgrade zoomed from v3

    Code
      def <- dm_get_def(dm_v3_zoomed, quiet = TRUE)
      def <- dm_get_def(dm_v3_zoomed)
    Message
      Upgrading dm object created with dm <= 0.3.0.
      Upgrading dm object created with dm <= 1.0.4.
    Code
      dm <- new_dm3(def, zoomed = TRUE)
      dm_validate(dm)
      is_zoomed(dm)
    Output
      [1] TRUE

# can upgrade to v4

    Code
      def <- dm_get_def(dm_v4, quiet = TRUE)
      def <- dm_get_def(dm_v4)
    Message
      Upgrading dm object created with dm <= 1.0.4.
    Code
      dm <- new_dm3(def)
      dm_validate(dm)
      is_zoomed(dm)
    Output
      [1] FALSE

# can upgrade zoomed to v4

    Code
      def <- dm_get_def(dm_v4_zoomed, quiet = TRUE)
      def <- dm_get_def(dm_v4_zoomed)
    Message
      Upgrading dm object created with dm <= 1.0.4.
    Code
      dm <- new_dm3(def, zoomed = TRUE)
      dm_validate(dm)
      is_zoomed(dm)
    Output
      [1] TRUE

