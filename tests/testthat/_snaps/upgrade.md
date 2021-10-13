# can upgrade from v1

    Code
      def <- dm_get_def(dm_v1, quiet = TRUE)
      def <- dm_get_def(dm_v1)
    Message <simpleMessage>
      Upgrading dm object created with dm <= 0.2.1.
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
    Code
      dm <- new_dm3(def, zoomed = TRUE)
      validate_dm(dm)
      is_zoomed(dm)
    Output
      [1] TRUE

