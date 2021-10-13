# error message for non-dm object

    Code
      dm_get_def(structure(list(table = "a"), class = "bogus"))
    Error <dm_error_is_not_dm>
      Required class `dm` but instead is `bogus`.

# can upgrade from v1

    Code
      def <- dm_get_def(dm_v1, quiet = TRUE)
      def <- dm_get_def(dm_v1)
    Message <simpleMessage>
      Upgrading dm object created with dm <= 0.2.1.
      Upgrading dm object created with dm <= 0.2.4.
    Code
      dm <- new_dm3(def)
      validate_dm(dm)
      is_zoomed(dm)
    Output
      [1] FALSE

# can upgrade zoomed from v1

    Code
      def <- dm_get_def(dm_v1_zoomed, quiet = TRUE)
      def <- dm_get_def(dm_v1_zoomed)
    Message <simpleMessage>
      Upgrading dm object created with dm <= 0.2.1.
      Upgrading dm object created with dm <= 0.2.4.
    Code
      dm <- new_dm3(def, zoomed = TRUE)
      validate_dm(dm)
      is_zoomed(dm)
    Output
      [1] TRUE

# can upgrade from v2

    Code
      def <- dm_get_def(dm_v2, quiet = TRUE)
      def <- dm_get_def(dm_v2)
    Message <simpleMessage>
      Upgrading dm object created with dm <= 0.2.4.
    Code
      dm <- new_dm3(def)
      validate_dm(dm)
      is_zoomed(dm)
    Output
      [1] FALSE

# can upgrade zoomed from v2

    Code
      def <- dm_get_def(dm_v2_zoomed, quiet = TRUE)
      def <- dm_get_def(dm_v2_zoomed)
    Message <simpleMessage>
      Upgrading dm object created with dm <= 0.2.4.
    Code
      dm <- new_dm3(def, zoomed = TRUE)
      validate_dm(dm)
      is_zoomed(dm)
    Output
      [1] TRUE

