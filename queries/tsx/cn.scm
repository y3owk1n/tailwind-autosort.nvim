(call_expression
  (identifier) @function_name
  (#any-of? @function_name "cn" "clsx" "twMerge")
  (arguments
    (string (string_fragment) @cn_class)
    (ternary_expression
      consequence: (string (string_fragment) @tailwind)
      alternative: (string (string_fragment) @tailwind))
  )
)
