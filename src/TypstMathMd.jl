module TypstMathMd

  using Markdown
  using Pandoc

  export @typstmd_str

  function convert_typst_multi(content::AbstractString)
    trimmed_content = String(strip(content, ['`', ' ']))
    is_inline = trimmed_content[1] != '\n'

    processed = run(Pandoc.Converter(; input = string('$', trimmed_content, '$'), from="typst", to="markdown"))

    bstart, bend = if is_inline
      (" ``", "`` ") 
    else 
      ("\```math\n", "\n```")
    end
    replacement = string(bstart, strip(processed, ['$', ' ', '\n']), bend)
  end

  macro typstmd_str(str)
	  str_expr = Meta.parse("\"\"\"$str\"\"\"")
	  quote
	  	let
        interpolated = $(str_expr)
  		  pattern = r"``(.+?)``"s  # 's' flag for dotall mode (. matches newlines)
    		processed = replace(interpolated, pattern => s -> convert_typst_multi(s))
    		Markdown.parse(processed)
		  end
	  end
  end
end
