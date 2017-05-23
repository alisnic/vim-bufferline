function! s:generate_names()
  let names = []
  let i = 0
  let index = 0

  if !exists("w:history") || len(w:history) == 0
    return []
  endif

  let current_buffer = bufnr('%')

  while index < len(w:history)
    let i = w:history[index]

    if bufexists(i) && buflisted(i)
      let modified = ''
      if getbufvar(i, '&mod')
        let modified = g:bufferline_modified
      endif
      let fname = fnamemodify(bufname(i), g:bufferline_fname_mod)
      if g:bufferline_pathshorten != 0
        let fname = pathshorten(fname)
      endif
      let fname = substitute(fname, "%", "%%", "g")

      let skip = 0
      for ex in g:bufferline_excludes
        if match(fname, ex) > -1
          let skip = 1
          break
        endif
      endfor

      if !skip
        let name = ''
        let name .= fname . modified

        if index == w:history_index
          let g:bufferline_status_info.current = name
        else
          let name = g:bufferline_separator . name . g:bufferline_separator
        endif

        call add(names, [i, name])
      endif
    endif
    let index += 1
  endwhile

  if len(names) > 1
    if g:bufferline_rotate == 1
      call bufferline#algos#fixed_position#modify(names)
    endif
  endif

  return names
endfunction

function! bufferline#get_echo_string()
  " check for special cases like help files
  let current = bufnr('%')
  if !bufexists(current) || !buflisted(current)
    return bufname('%')
  endif

  let names = s:generate_names()
  let line = ''
  for val in names
    let line .= val[1]
  endfor

  let index = match(line, '\V'.g:bufferline_status_info.current)
  let g:bufferline_status_info.count = len(names)
  let g:bufferline_status_info.before = strpart(line, 0, index)
  let g:bufferline_status_info.after = strpart(line, index + len(g:bufferline_status_info.current))
  return line
endfunction
