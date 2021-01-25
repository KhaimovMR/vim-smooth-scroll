
" ==============================================================================
" File: smooth_scroll.vim
" Author: Terry Ma
" Description: Scroll the screen smoothly to retain better context. Useful for
" replacing Vim's default scrolling behavior with CTRL-D, CTRL-U, CTRL-B, and
" CTRL-F
" Last Modified: April 04, 2013
" ==============================================================================

let s:save_cpo = &cpo
let s:total_steps = 0
let s:dx_step = 0
let s:et = 0
let s:f = 0
let s:dx = 0
let s:sign = -1
let s:cmd = ""
let s:move_cmd = ""
let s:scroll_cmd = ""
let s:moving_half = ""
let s:scroll_further = 1
let s:dir = ""
let s:duration = 0
let s:current_step = 0
let s:current_timer = 0
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
  let s:total_steps = a:dist/a:speed " Total steps
  let s:dx_step = 27/s:total_steps
  let s:et = 0 " Ease time
  let s:f = 30 " fraction from i
  let s:dx = 27*0.86
  let s:move_cmd = ""
  let s:scroll_cmd = ""
  let s:sign = -1
  let s:cmd = ""
  let s:move_cmd = ""
  let s:scroll_cmd = ""
  let s:moving_half = ""
  let s:scroll_further = 0
  let l:up_move_cmd = a:speed."k"
  let l:down_move_cmd = a:speed."j"
  let l:up_scroll_cmd = a:speed."\<C-y>"
  let l:down_scroll_cmd = a:speed."\<C-e>"
  let l:i = 0


  if a:dir ==# 'u'
    let s:move_cmd = l:up_move_cmd
    let s:scroll_cmd = l:up_scroll_cmd
    let s:moving_half = 0
  else
    let s:move_cmd = l:down_move_cmd
    let s:scroll_cmd = l:down_scroll_cmd
    let s:moving_half = 1
  endif

  let s:dir = a:dir
  let s:duration = a:duration
  let s:current_step = 0
  call timer_stop(s:current_timer)
  let s:current_timer = timer_start(s:duration, function("s:smooth_scroll_step"))
endfunction


function! s:smooth_scroll_step(timer_id)
  if s:scroll_further == 0
    let l:upper_half = line('.') < (line('w0') + &scroll)

    if l:upper_half == s:moving_half
      let s:cmd = s:move_cmd
    else
      let s:cmd = s:scroll_cmd.s:move_cmd
      let s:scroll_further = 1
    endif
  endif

  if s:dir ==# 'd'
    if line('$') < (line('w0') + &scroll + &scroll/1.5)
      if line('.') == line('$')
        echom "EOF reached"
        return
      endif

      let s:cmd = s:move_cmd
    endif

  endif

  exec "normal! ".s:cmd
  redraw

  if str2float(s:current_step) / s:total_steps > 0.3
    let s:sign = 1
  endif

  let s:et = float2nr(pow(s:dx/s:f + 0, 4))
  let s:dx = s:dx + s:sign * s:dx_step

  if s:current_step < s:total_steps
    let s:current_step = s:current_step + 1
    let s:current_timer = timer_start(s:duration, function("s:smooth_scroll_step"))
  endif
endfunction
