(call_expression
  (identifier) @function_name
  (#any-of? @function_name "cva")
  (arguments
        [
    (string (string_fragment) @cva_class)
    (object
      (pair
        value: (object
          (pair
            value: (object
          (pair
              (string (string_fragment) @variant_class)
            )
            )
          )
        )
      )
    )
        ]
  )
)
