module TypstMathMd

  using Markdown
  using Pandoc

  export @typstmd_str

  function convert_typst_multi(content::AbstractString)
    trimmed_content = String(strip(content, ['%', ' ']))
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
    pattern = r"%%(.+?)%%"s  # 's' flag for dotall mode (. matches newlines)
    processed = replace(str, pattern => s -> convert_typst_multi(s))
    return :(Markdown.parse($processed))
  end

end
