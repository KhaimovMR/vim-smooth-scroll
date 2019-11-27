" ==============================================================================
" File: smooth_scroll.vim
" Author: Terry Ma
" Description: Scroll the screen smoothly to retain better context. Useful for
" replacing Vim's default scrolling behavior with CTRL-D, CTRL-U, CTRL-B, and
" CTRL-F
" Last Modified: April 04, 2013
" ==============================================================================

let s:save_cpo = &cpo
set cpo&vim

" ==============================================================================
" Global Functions
" ==============================================================================

function! smooth_scroll#up_half(count)
  if (line('.') == 1)
    return
  endif

  call smooth_scroll#up(&scroll * (a:count ? a:count : 1), g:smooth_scroll_duration, 1)
endfunction


function! smooth_scroll#down_half(count)
"  if line('$') < (line('w0') + &scroll + &scroll/1.5)
"    echom "EOF reached"
"    return
"  endif

  call smooth_scroll#down(&scroll * (a:count ? a:count : 1), g:smooth_scroll_duration, 1)
endfunction


function! smooth_scroll#up_full(count)
  if (line('.') == 1)
    return
  endif

  call smooth_scroll#up(&scroll * 2 * (a:count ? a:count : 1), g:smooth_scroll_duration, 1)
endfunction


function! smooth_scroll#down_full(count)
"  if line('$') < (line('w0') + &scroll + &scroll/1.5)
"    echom "EOF reached"
"    return
"  endif

  call smooth_scroll#down(&scroll * 2 * (a:count ? a:count : 1), g:smooth_scroll_duration, 1)
endfunction


" Scroll the screen up
function! smooth_scroll#up(dist, duration, speed)
  call s:smooth_scroll('u', a:dist, a:duration, a:speed)
endfunction

" Scroll the screen down
function! smooth_scroll#down(dist, duration, speed)
  call s:smooth_scroll('d', a:dist, a:duration, a:speed)
endfunction

" ==============================================================================
" Functions
" ==============================================================================

" Scroll the scroll smoothly
" dir: Direction of the scroll. 'd' is downwards, 'u' is upwards
" dist: Distance, or the total number of lines to scroll
" duration: How long should each scrolling animation last. Each scrolling
" animation will take at least this long. It could take longer if the scrolling
" itself by Vim takes longer
" speed: Scrolling speed, or the number of lines to scroll during each scrolling
" animation
function! s:smooth_scroll(dir, dist, duration, speed)
  let l:total_steps = a:dist/a:speed " Total steps
  let l:et = 0 " Ease time
  let l:f = 30 " fraction from i
  let l:up_move_cmd = a:speed."k"
  let l:down_move_cmd = a:speed."j"
  let l:up_scroll_cmd = a:speed."\<C-y>"
  let l:down_scroll_cmd = a:speed."\<C-e>"
  let l:move_cmd = ""
  let l:scroll_cmd = ""
  let l:dx = 27*0.86
  let l:dx_step = 27/l:total_steps
  let l:sign = -1
  let l:i = 0

  let l:cmd = ""
  let l:scroll_further = 0

  if a:dir ==# 'u'
    let l:move_cmd = l:up_move_cmd
    let l:scroll_cmd = l:up_scroll_cmd
    let l:moving_half = 0
  else
    let l:move_cmd = l:down_move_cmd
    let l:scroll_cmd = l:down_scroll_cmd
    let l:moving_half = 1
  endif

  for i in range(l:total_steps)
    if l:scroll_further == 0
      let l:upper_half = line('.') < (line('w0') + &scroll)

      if l:upper_half == l:moving_half
        let l:cmd = l:move_cmd
      else
        let l:cmd = l:scroll_cmd.l:move_cmd
        let l:scroll_further = 1
      endif
    endif

    if a:dir ==# 'd'
      if line('$') < (line('w0') + &scroll + &scroll/1.5)
        if line('.') == line('$')
          echom "EOF reached"
          return
        endif

        let l:cmd = l:move_cmd
      endif

    endif

    exec "normal! ".l:cmd
    redraw

    if str2float(i) / l:total_steps > 0.3
      let l:sign = 1
    endif

    let l:et = float2nr(pow(l:dx/l:f + 0, 4))
    let l:dx = l:dx + l:sign * l:dx_step
    exec "sleep " . (a:duration + l:et) . "m"
  endfor
endfunction
