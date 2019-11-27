let g:smooth_scroll_duration = 6

command! -nargs=1 -count=1 SmoothScrollUpHalf call smooth_scroll#up_half(<args>)
command! -nargs=1 -count=1 SmoothScrollDownHalf call smooth_scroll#down_half(<args>)
command! -nargs=1 -count=1 SmoothScrollUpFull call smooth_scroll#up_full(<args>)
command! -nargs=1 -count=1 SmoothScrollDownFull call smooth_scroll#down_full(<args>)
